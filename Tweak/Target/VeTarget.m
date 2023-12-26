//
//  VeTarget.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeTarget.h"

#pragma mark - BulletinBoardController class hooks

static void (* orig_BulletinBoardController_viewDidLoad)(BulletinBoardController* self, SEL _cmd);
static void override_BulletinBoardController_viewDidLoad(BulletinBoardController* self, SEL _cmd) {
	orig_BulletinBoardController_viewDidLoad(self, _cmd);

	PSSpecifier* veGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
	[veGroupSpecifier setProperty:@"Lists all Notifications that have been logged by Vē in the past." forKey:@"footerText"];

	PSSpecifier* veButtonSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Notification Logs" target:self set:nil get:nil detail:[VeLogsListController class] cell:PSLinkCell edit:nil];
	[veButtonSpecifier setProperty:@(YES) forKey:@"enabled"];

	[self insertContiguousSpecifiers:@[veGroupSpecifier, veButtonSpecifier] atIndex:0];
}

static BOOL override_BulletinBoardController_shouldReloadSpecifiersOnResume(BulletinBoardController* self, SEL _cmd) {
	return NO;
}

#pragma mark - PSUIPrefsListController class hooks

static void (* orig_PSUIPrefsListController_lazyLoadBundle)(PSUIPrefsListController* self, SEL _cmd, PSSpecifier* specifier);
static void override_PSUIPrefsListController_lazyLoadBundle(PSUIPrefsListController* self, SEL _cmd, PSSpecifier* specifier) {
	orig_PSUIPrefsListController_lazyLoadBundle(self, _cmd, specifier);

	if ([[specifier identifier] isEqualToString:@"NOTIFICATIONS_ID"]) {
		// enable the remaining hooks when the notifications pane is loaded
		MSHookMessageEx(NSClassFromString(@"BulletinBoardController"), @selector(viewDidLoad), (IMP)&override_BulletinBoardController_viewDidLoad, (IMP *)&orig_BulletinBoardController_viewDidLoad);
		MSHookMessageEx(NSClassFromString(@"BulletinBoardController"), @selector(shouldReloadSpecifiersOnResume), (IMP)&override_BulletinBoardController_shouldReloadSpecifiersOnResume, nil);
  	}
}

#pragma mark - Preferences

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue)
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
	load_preferences();

    if (!pfEnabled) {
        return;
    }

	MSHookMessageEx(NSClassFromString(@"PSUIPrefsListController"), @selector(lazyLoadBundle:), (IMP)&override_PSUIPrefsListController_lazyLoadBundle, (IMP *)&orig_PSUIPrefsListController_lazyLoadBundle);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
