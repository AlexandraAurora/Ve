//
//  VeCore.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeCore.h"

#pragma mark - BBServer class hooks

static void (* orig_BBServer_publishBulletin_destinations)(BBServer* self, SEL _cmd, BBBulletin* bulletin, unsigned long long destinations);
static void override_BBServer_publishBulletin_destinations(BBServer* self, SEL _cmd, BBBulletin* bulletin, unsigned long long destinations) {
	orig_BBServer_publishBulletin_destinations(self, _cmd, bulletin, destinations);

	if ([pfBlockedSenders containsObject:[bulletin sectionID]]) {
		return;
	}

	if (![bulletin sectionID]) {
		return;
	}

	if (!pfLogWithoutContent && (![bulletin message] || [[bulletin message] isEqualToString:@""])) {
		return;
	}

	[[LogManager sharedInstance] addLogForBulletin:bulletin];
}

#pragma mark - Preferences

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue),
		kPreferenceKeyLogLimit: @(kPreferenceKeyLogLimitDefaultValue),
		kPreferenceKeySaveAttachments: @(kPreferenceKeySaveAttachmentsDefaultValue),
		kPreferenceKeyLogWithoutContent: @(kPreferenceKeyLogWithoutContentDefaultValue),
		kPreferenceKeyAutomaticallyDeleteLogs: @(kPreferenceKeyAutomaticallyDeleteLogsDefaultValue),
		kPreferenceKeyBlockedSenders: kPreferenceKeyBlockedSendersDefaultValue
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
	pfLogLimit = [[preferences objectForKey:kPreferenceKeyLogLimit] intValue];
	pfSaveAttachments = [[preferences objectForKey:kPreferenceKeySaveAttachments] boolValue];
	pfLogWithoutContent = [[preferences objectForKey:kPreferenceKeyLogWithoutContent] boolValue];
	pfAutomaticallyDeleteLogs = [[preferences objectForKey:kPreferenceKeyAutomaticallyDeleteLogs] boolValue];
	pfBlockedSenders = [preferences objectForKey:kPreferenceKeyBlockedSenders];

	[[LogManager sharedInstance] setSaveAttachments:pfSaveAttachments];
	[[LogManager sharedInstance] setLogLimit:pfLogLimit];
	[[LogManager sharedInstance] setAutomaticallyDeleteLogs:pfAutomaticallyDeleteLogs];
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
	load_preferences();

    if (!pfEnabled) {
        return;
    }

	MSHookMessageEx(NSClassFromString(@"BBServer"), @selector(publishBulletin:destinations:), (IMP)&override_BBServer_publishBulletin_destinations, (IMP *)&orig_BBServer_publishBulletin_destinations);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
