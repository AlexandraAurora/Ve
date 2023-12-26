//
//  VeBlockedSendersListController.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeBlockedSendersListController.h"

@implementation VeBlockedSendersListController
- (NSArray *)specifiers {
    load_preferences();

    _specifiers = [[NSMutableArray alloc] init];

    [_specifiers addObject:[PSSpecifier emptyGroupSpecifier]];

    for (NSString* sender in pfBlockedSenders) {
        PSSpecifier* senderSpecifier = [PSSpecifier preferenceSpecifierNamed:sender target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil];
        [senderSpecifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
        [senderSpecifier setProperty:sender forKey:@"blockedSender"];
        [_specifiers addObject:senderSpecifier];
    }

	return _specifiers;
}

- (void)removedSpecifier:(PSSpecifier *)specifier {
    [pfBlockedSenders removeObject:[specifier propertyForKey:@"blockedSender"]];
    [preferences setObject:pfBlockedSenders forKey:kPreferenceKeyBlockedSenders];
    [self reloadSpecifiers];
}

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyBlockedSenders: kPreferenceKeyBlockedSendersDefaultValue
    }];

    pfBlockedSenders = [[preferences objectForKey:kPreferenceKeyBlockedSenders] mutableCopy];
}
@end
