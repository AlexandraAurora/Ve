#import "VeBlockedBundleIdentifiersListController.h"

@implementation VeBlockedBundleIdentifiersListController

- (void)viewDidLoad { // set the title and initialize the plus button

    [super viewDidLoad];

    [self setTitle:@"Blocked Bundle Identifiers"];


    // plus button
    self.plusButton = [UIButton new];
    [[self plusButton] addTarget:self action:@selector(blockBundleIdentifier) forControlEvents:UIControlEventTouchUpInside];
    [[self plusButton] setImage:[[UIImage systemImageNamed:@"plus"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIImageSymbolWeightRegular]] forState:UIControlStateNormal];
    [[self plusButton] setTintColor:[UIColor systemBlueColor]];

    self.item = [[UIBarButtonItem alloc] initWithCustomView:[self plusButton]];

}

- (NSArray *)specifiers {  // list all options

    _specifiers = [NSMutableArray new];
    self.logsDictionary = [[HBPreferences alloc] initWithIdentifier:@"love.litten.ve-logs"];
    NSArray* blockedBundleIdentifiers = [[self logsDictionary] objectForKey:@"blockedBundleIdentifiers"];


    // if there's no blocked bundle identifiers return here
    if ([blockedBundleIdentifiers count] == 0) {
        PSSpecifier* emptyListSpecifier = [PSSpecifier emptyGroupSpecifier];
        [emptyListSpecifier setProperty:@"Vē will not log any notifications sent with blocked bundle identifiers." forKey:@"footerText"];
        [emptyListSpecifier setProperty:@(1) forKey:@"footerAlignment"];
        [_specifiers addObject:emptyListSpecifier];

        return _specifiers;
    }


    // list all blocked bundle identifiers
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Bundle Identifiers"]];

    for (NSString* bundleIdentifier in blockedBundleIdentifiers) {
        PSSpecifier* bundleIdentifierSpecifier = [PSSpecifier preferenceSpecifierNamed:bundleIdentifier target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil];
        [bundleIdentifierSpecifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
        [bundleIdentifierSpecifier setProperty:bundleIdentifier forKey:@"bundleIdentifier"];
        [_specifiers addObject:bundleIdentifierSpecifier];
    }


	return _specifiers;

}

- (BOOL)shouldReloadSpecifiersOnResume { // prevent the controller from reloading the view after inactivity

    return false;

}

- (id)_editButtonBarItem { // override the edit button with the plus button

    return [self item];

}

- (void)removedSpecifier:(PSSpecifier*)specifier { // remove the selected bundle identifier

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray* blockedBundleIdentifiers = [[[self logsDictionary] objectForKey:@"blockedBundleIdentifiers"] mutableCopy];
        [blockedBundleIdentifiers removeObject:specifier.properties[@"bundleIdentifier"]];
        [[self logsDictionary] setObject:blockedBundleIdentifiers forKey:@"blockedBundleIdentifiers"];

        [self reloadSpecifiers];
    });

}

- (void)blockBundleIdentifier { // block a bundle identifier

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Block A Bundle Identifier" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* blockAction = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray* blockedBundleIdentifiers = [NSMutableArray new];
            [blockedBundleIdentifiers addObjectsFromArray:[[self logsDictionary] objectForKey:@"blockedBundleIdentifiers"]];
            [blockedBundleIdentifiers addObject:[[[alertController textFields] firstObject] text]];
            [[self logsDictionary] setObject:blockedBundleIdentifiers forKey:@"blockedBundleIdentifiers"];

            [self reloadSpecifiers];
        });
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:blockAction];
    [alertController addAction:cancelAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        [textField setPlaceholder:@"Example: com.apple.Preferences"];
    }];

    [self presentViewController:alertController animated:YES completion:nil];

}

@end
