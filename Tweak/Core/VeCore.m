//
//  VeCore.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeCore.h"
#import <substrate.h>
#import "../../Manager/LogManager.h"
#import "../../Preferences/PreferenceKeys.h"
#import "../../Preferences/NotificationKeys.h"
#import "../../PrivateHeaders.h"

#pragma mark - BBServer class hooks

/**
 * Logs incoming notifications from bullets.
 *
 * @param bulletin The bulletin that's to be logged.
 * @param destinations
 */
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

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue),
		kPreferenceKeyLogLimit: @(kPreferenceKeyLogLimitDefaultValue),
		kPreferenceKeySaveLocalAttachments: @(kPreferenceKeySaveLocalAttachmentsDefaultValue),
		kPreferenceKeySaveRemoteAttachments: @(kPreferenceKeySaveRemoteAttachmentsDefaultValue),
		kPreferenceKeyLogWithoutContent: @(kPreferenceKeyLogWithoutContentDefaultValue),
		kPreferenceKeyAutomaticallyDeleteLogs: @(kPreferenceKeyAutomaticallyDeleteLogsDefaultValue),
		kPreferenceKeyBlockedSenders: kPreferenceKeyBlockedSendersDefaultValue
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
	pfLogLimit = [[preferences objectForKey:kPreferenceKeyLogLimit] intValue];
	pfSaveLocalAttachments = [[preferences objectForKey:kPreferenceKeySaveLocalAttachments] boolValue];
	pfSaveRemoteAttachments = [[preferences objectForKey:kPreferenceKeySaveRemoteAttachments] boolValue];
	pfLogWithoutContent = [[preferences objectForKey:kPreferenceKeyLogWithoutContent] boolValue];
	pfAutomaticallyDeleteLogs = [[preferences objectForKey:kPreferenceKeyAutomaticallyDeleteLogs] boolValue];
	pfBlockedSenders = [preferences objectForKey:kPreferenceKeyBlockedSenders];

	[[LogManager sharedInstance] setSaveLocalAttachments:pfSaveLocalAttachments];
	[[LogManager sharedInstance] setSaveRemoteAttachments:pfSaveRemoteAttachments];
	[[LogManager sharedInstance] setLogLimit:pfLogLimit];
	[[LogManager sharedInstance] setAutomaticallyDeleteLogs:pfAutomaticallyDeleteLogs];
}

#pragma mark - Constructor

/**
 * Initializes the core.
 *
 * First it loads the preferences and continues if Vē is enabled.
 * Secondly it sets up the hooks.
 * Finally it registers the notification callbacks.
 */
__attribute((constructor)) static void initialize() {
	load_preferences();

    if (!pfEnabled) {
        return;
    }

	MSHookMessageEx(NSClassFromString(@"BBServer"), @selector(publishBulletin:destinations:), (IMP)&override_BBServer_publishBulletin_destinations, (IMP *)&orig_BBServer_publishBulletin_destinations);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
