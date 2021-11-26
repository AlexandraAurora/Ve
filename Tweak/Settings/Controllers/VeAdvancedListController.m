#import "VeAdvancedListController.h"

@implementation VeAdvancedListController

- (void)viewDidLoad { // set the title and initialize the logs

    [super viewDidLoad];

    [self setTitle:@"Advanced"];

    self.logs = [[HBPreferences alloc] initWithIdentifier:@"love.litten.ve-logs"];

}

- (NSArray *)specifiers {  // list all options

    _specifiers = [NSMutableArray new];


    // present main preferences
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Main Preferences"]];

    PSSpecifier* mainPreferencesSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Go to Main Preferences" target:self set:nil get:nil detail:[VePreferencesListController class] cell:PSLinkCell edit:nil];
    [_specifiers addObject:mainPreferencesSpecifier];


    // blocked bundle identifiers
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Blocked Bundle Identifiers"]];

    PSSpecifier* blockedBundleIdentifiersSpecifier = [PSSpecifier preferenceSpecifierNamed:@"List Blocked Bundle Identifiers" target:self set:nil get:nil detail:[VeBlockedBundleIdentifiersListController class] cell:PSLinkCell edit:nil];
	[blockedBundleIdentifiersSpecifier setProperty:@(YES) forKey:@"enabled"];
    [_specifiers addObject:blockedBundleIdentifiersSpecifier];


    // excluded phrases
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Excluded Phrases"]];

    PSSpecifier* excludedPhrasesSpecifier = [PSSpecifier preferenceSpecifierNamed:@"List Excluded Phrases" target:self set:nil get:nil detail:[VeExcludedPhrasesListController class] cell:PSLinkCell edit:nil];
	[excludedPhrasesSpecifier setProperty:@(YES) forKey:@"enabled"];
    [_specifiers addObject:excludedPhrasesSpecifier];


    // deletion of logs
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Delete Logs"]];

    PSSpecifier* deleteLogWithIdentifierSpecifier = [PSSpecifier deleteButtonSpecifierWithName:@"Delete Log with Identifier" target:self action:@selector(deleteLogByIdentifier)];
    [_specifiers addObject:deleteLogWithIdentifierSpecifier];

    PSSpecifier* deleteAllLogsFromBundleIdentifierSpecifier = [PSSpecifier deleteButtonSpecifierWithName:@"Delete all Logs with Bundle Identifier" target:self action:@selector(deleteLogsWithBundleIdentifier)];
    [_specifiers addObject:deleteAllLogsFromBundleIdentifierSpecifier];

    PSSpecifier* deleteLogsInRangeSpecifier = [PSSpecifier deleteButtonSpecifierWithName:@"Delete Logs in Range" target:self action:@selector(deleteLogsInRange)];
    [_specifiers addObject:deleteLogsInRangeSpecifier];

    PSSpecifier* deleteAllLogsSpecifier = [PSSpecifier deleteButtonSpecifierWithName:@"Delete all Logs" target:self action:@selector(deleteAllLogs)];
    [_specifiers addObject:deleteAllLogsSpecifier];


	return _specifiers;

}

- (BOOL)shouldReloadSpecifiersOnResume { // prevent the controller from reloading the view after inactivity

    return false;

}

- (void)deleteLogByIdentifier { // delete log by identifier

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Delete By Identifier" message:@"The log with the specified identifier will be deleted." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray* storedLogs = [[[self logs] objectForKey:@"loggedNotifications"] mutableCopy];

            for (int i = 0; i < [storedLogs count]; i++) {
                NSDictionary* log = [storedLogs objectAtIndex:i];
                if ([[log objectForKey:@"identifier"] intValue] == [[[[alertController textFields] firstObject] text] intValue]) {
                    [storedLogs removeObjectAtIndex:i];
                    break;
                }
            }

            [[self logs] setObject:storedLogs forKey:@"loggedNotifications"];
        });
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        [textField setPlaceholder:@"Example: 54"];
    }];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)deleteLogsWithBundleIdentifier { // delete all logs from bundle identifier

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Delete With Bundle Identifier" message:@"All logs with the specified bundle identifier will be deleted." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray* storedLogs = [[self logs] objectForKey:@"loggedNotifications"];

            for (int i = 0; i < [storedLogs count]; i++) {
                [self deleteLogWithProvidedBundleIdentifier:[[[alertController textFields] firstObject] text]];
            }
        });
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        [textField setPlaceholder:@"Example: com.apple.Preferences"];
    }];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)deleteLogWithProvidedBundleIdentifier:(NSString *)bundleIdentifier { // delete a log with the provided bundle identifier

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray* storedLogs = [[[self logs] objectForKey:@"loggedNotifications"] mutableCopy];

        for (int i = 0; i < [storedLogs count]; i++) {
            NSDictionary* log = [storedLogs objectAtIndex:i];
            if ([[log objectForKey:@"bundleID"] isEqualToString:bundleIdentifier]) {
                [storedLogs removeObjectAtIndex:i];
                break;
            }
        }

        [[self logs] setObject:storedLogs forKey:@"loggedNotifications"];
    });

}

- (void)deleteLogsInRange { // delete all logs in range

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Delete Logs In Range" message:@"All logs with within the specified range will be deleted." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray* identifiers = [[[[alertController textFields] firstObject] text] componentsSeparatedByString:@"-"];
            NSMutableArray* storedLogs = [[[self logs] objectForKey:@"loggedNotifications"] mutableCopy];

            for (int i = 0; i < [storedLogs count]; i++) {
                [self deleteLogInRange:[identifiers[0] intValue] end:[identifiers[1] intValue]];
            }
        });
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        [textField setPlaceholder:@"Example: 12-34"];
    }];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)deleteLogInRange:(int)start end:(int)end { // delete a log within the provided range

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray* storedLogs = [[[self logs] objectForKey:@"loggedNotifications"] mutableCopy];

        for (int i = 0; i < [storedLogs count]; i++) {
            NSDictionary* log = [storedLogs objectAtIndex:i];
            if ([[log objectForKey:@"identifier"] intValue] >= start && [[log objectForKey:@"identifier"] intValue] <= end) {
                [storedLogs removeObjectAtIndex:i];
                break;
            }
        }

        [[self logs] setObject:storedLogs forKey:@"loggedNotifications"];
    });

}

- (void)deleteAllLogs { // delete all stored logs

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Settings" message:@"It may take a few seconds for all stored logs to be removed and storage recovered." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self logs] removeObjectForKey:@"loggedNotifications"];
        });
	}];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alertController addAction:confirmAction];
	[alertController addAction:cancelAction];

	[self presentViewController:alertController animated:YES completion:nil];

}

@end
