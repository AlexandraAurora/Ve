#import "VeExcludedPhrasesListController.h"

@implementation VeExcludedPhrasesListController

- (void)viewDidLoad { // set the title and initialize the plus button

    [super viewDidLoad];

    [self setTitle:@"Excluded Phrases"];


    // plus button
    self.plusButton = [UIButton new];
    [[self plusButton] addTarget:self action:@selector(excludePhrase) forControlEvents:UIControlEventTouchUpInside];
    [[self plusButton] setImage:[[UIImage systemImageNamed:@"plus"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIImageSymbolWeightRegular]] forState:UIControlStateNormal];
    [[self plusButton] setTintColor:[UIColor systemBlueColor]];

    self.item = [[UIBarButtonItem alloc] initWithCustomView:[self plusButton]];

}

- (NSArray *)specifiers {  // list all options

    _specifiers = [NSMutableArray new];
    self.logsDictionary = [[HBPreferences alloc] initWithIdentifier:@"love.litten.ve-logs"];
    NSArray* excludedPhrases = [[self logsDictionary] objectForKey:@"excludedPhrases"];


    // if there's no exlusions return here
    if ([excludedPhrases count] == 0) {
        PSSpecifier* emptyListSpecifier = [PSSpecifier emptyGroupSpecifier];
        [emptyListSpecifier setProperty:@"Vē will not log any notifications that include excluded phrases." forKey:@"footerText"];
        [emptyListSpecifier setProperty:@(1) forKey:@"footerAlignment"];
        [_specifiers addObject:emptyListSpecifier];

        return _specifiers;
    }


    // list all excluded phrases
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Excluded Phrases"]];

    for (NSString* excludedPhrase in excludedPhrases) {
        PSSpecifier* excludedPhraseSpecifier = [PSSpecifier preferenceSpecifierNamed:excludedPhrase target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil];
        [excludedPhraseSpecifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
        [excludedPhraseSpecifier setProperty:excludedPhrase forKey:@"excludedPhrase"];
        [_specifiers addObject:excludedPhraseSpecifier];
    }


	return _specifiers;

}

- (BOOL)shouldReloadSpecifiersOnResume { // prevent the controller from reloading the view after inactivity

    return false;

}

- (id)_editButtonBarItem { // override the edit button with the plus button

    return [self item];

}

- (void)removedSpecifier:(PSSpecifier*)specifier { // remove the selected phrase

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray* excludedPhrases = [[[self logsDictionary] objectForKey:@"excludedPhrases"] mutableCopy];
        [excludedPhrases removeObject:specifier.properties[@"excludedPhrase"]];
        [[self logsDictionary] setObject:excludedPhrases forKey:@"excludedPhrases"];

        [self reloadSpecifiers];
    });

}

- (void)excludePhrase { // exclude a phrase

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Exclude a Phrase" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* excludeAction = [UIAlertAction actionWithTitle:@"Exclude" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray* excludedPhrases = [NSMutableArray new];
            [excludedPhrases addObjectsFromArray:[[self logsDictionary] objectForKey:@"excludedPhrases"]];
            [excludedPhrases addObject:[[[alertController textFields] firstObject] text]];
            [[self logsDictionary] setObject:excludedPhrases forKey:@"excludedPhrases"];

            [self reloadSpecifiers];
        });
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:excludeAction];
    [alertController addAction:cancelAction];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        [textField setPlaceholder:@"Example: Hello"];
    }];

    [self presentViewController:alertController animated:YES completion:nil];

}

@end
