//
//  VeRootListController.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#include "VeRootListController.h"

@implementation VeRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    if ([[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyEnabled]) {
		[self respringPrompt];
    }

	if ([[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyUseBiometricProtection]) {
		LAContext* laContext = [[LAContext alloc] init];
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Vē needs to make sure you're permitted to toggle biometric protection." reply:^(BOOL success, NSError* _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
					NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];
					[userDefaults setBool:![[userDefaults objectForKey:kPreferenceKeyUseBiometricProtection] boolValue] forKey:kPreferenceKeyUseBiometricProtection];
                    [self reloadSpecifiers];
                }
            });
        }];
	}
}

- (void)respringPrompt {
    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"Vē" message:@"This option requires a respring to apply. Do you want to respring now?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self respring];
	}];

	UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:yesAction];
	[resetAlert addAction:noAction];

	[self presentViewController:resetAlert animated:YES completion:nil];
}

- (void)respring {
	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath:ROOT_PATH_NS(@"/usr/bin/killall")];
	[task setArguments:@[@"backboardd"]];
	[task launch];
}

- (void)resetPrompt {
    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"Vē" message:@"Are you sure you want to reset your preferences?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self resetPreferences];
	}];

	UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:yesAction];
	[resetAlert addAction:noAction];

	[self presentViewController:resetAlert animated:YES completion:nil];
}

- (void)resetPreferences {
	NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];
	for (NSString* key in [userDefaults dictionaryRepresentation]) {
		[userDefaults removeObjectForKey:key];
	}

	[self reloadSpecifiers];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kNotificationKeyPreferencesReload, nil, nil, YES);
}
@end
