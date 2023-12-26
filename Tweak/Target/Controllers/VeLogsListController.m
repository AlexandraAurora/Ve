//
//  VeLogsListController.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeLogsListController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation VeLogsListController
- (void)viewDidLoad {
    [super viewDidLoad];

    load_preferences();

    [self setSearchController:[[UISearchController alloc] init]];
    [[[self searchController] searchBar] setDelegate:self];
    [[self searchController] setObscuresBackgroundDuringPresentation:NO];
    [[self navigationItem] setSearchController:[self searchController]];

    [self setPullToRefreshControl:[[UIRefreshControl alloc] init]];
    [[self pullToRefreshControl] addTarget:self action:@selector(handlePullToRefresh) forControlEvents:UIControlEventValueChanged];
    [[self pullToRefreshControl] setTintColor:[UIColor labelColor]];
    [[self table] setRefreshControl:[self pullToRefreshControl]];

    [self setBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    [self setBlurView:[[UIVisualEffectView alloc] initWithEffect:[self blurEffect]]];
    [[self blurView] setFrame:[[self view] bounds]];
    [[self blurView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self blurView] setAlpha:1];
    [[self blurView] setHidden:YES];
    [[self view] addSubview:[self blurView]];

    if (pfUseBiometricProtection) {
        [[self blurView] setHidden:NO];
        [self checkBiometrics];
    }

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    [self reloadSpecifiers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setFilterButton:[[UIButton alloc] init]];
    [[self filterButton] setImage:[[UIImage systemImageNamed:@"line.3.horizontal.decrease.circle"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:23 weight:UIImageSymbolWeightRegular]] forState:UIControlStateNormal];
    [[self filterButton] setTintColor:[UIColor systemBlueColor]];

    UIAction* applicationSortingAction = [UIAction actionWithTitle:kPreferenceKeySortingApplication image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
        pfSorting = kPreferenceKeySortingApplication;
        [preferences setObject:pfSorting forKey:kPreferenceKeySorting];
        [self reloadSpecifiers];
    }];
    UIAction* dateSortingAction = [UIAction actionWithTitle:kPreferenceKeySortingDate image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
        pfSorting = kPreferenceKeySortingDate;
        [preferences setObject:pfSorting forKey:kPreferenceKeySorting];
        [self reloadSpecifiers];
    }];

    UIMenu* menu = [UIMenu menuWithTitle:@"" children:@[applicationSortingAction, dateSortingAction]];

    [[self filterButton] setMenu:menu];
    [[self filterButton] setShowsMenuAsPrimaryAction:YES];

    [self setItem:[[UIBarButtonItem alloc] initWithCustomView:[self filterButton]]];
    [[self navigationItem] setRightBarButtonItem:[self item]];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (pfUseBiometricProtection) {
        [[self blurView] setHidden:NO];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (pfUseBiometricProtection) {
        [self checkBiometrics];
    }

    // The filter button is overridden by the default edit button again when the app enters the foreground.
    [[self navigationItem] setRightBarButtonItem:[self item]];
}

- (void)checkBiometrics {
    LAContext* laContext = [[LAContext alloc] init];
    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Vē needs to make sure you're permitted to view the notification logs." reply:^(BOOL success, NSError* _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [[self blurView] setAlpha:0];
                } completion:^(BOOL finished) {
                    [[self blurView] setAlpha:1];
                    [[self blurView] setHidden:YES];
                }];
            } else {
                [[self navigationController] popViewControllerAnimated:YES];
            }
        });
    }];
}

- (void)handlePullToRefresh {
    [self reloadSpecifiers];
    [[self pullToRefreshControl] endRefreshing];

    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [[self pullToRefreshControl] setAlpha:0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [[self pullToRefreshControl] setAlpha:1];
        } completion:nil];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self reloadSpecifiers];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // The search bar's text is actually cleared by default when the cancel button is clicked.
    // However, it's not cleared before the specifiers are reloaded, so the search results are still shown.
    [[[self searchController] searchBar] setText:@""];
    [self reloadSpecifiers];
}

- (NSArray *)specifiers {
    _specifiers = [[NSMutableArray alloc] init];

    if ([self searchController] && ![[[[self searchController] searchBar] text] isEqualToString:@""]) {
        [_specifiers addObjectsFromArray:[self getSpecifiersForSorting:kPreferenceKeySortingSearch withObject:[[[self searchController] searchBar] text]]];
    } else {
        [_specifiers addObjectsFromArray:[self getSpecifiersForSorting:pfSorting withObject:nil]];
    }

    return _specifiers;
}

- (NSArray *)getSpecifiersForSorting:(NSString *)sorting withObject:(id)object {
    NSArray* specifiers = @[];

    id sorter = nil;
    if ([sorting isEqualToString:kPreferenceKeySortingApplication]) {
        sorter = [[ApplicationSorter alloc] initWithObject:object];
    } else if ([sorting isEqualToString:kPreferenceKeySortingDate]) {
        sorter = [[DateSorter alloc] initWithObject:object];
    } else if ([sorting isEqualToString:kPreferenceKeySortingSearch]) {
        sorter = [[SearchSorter alloc] initWithObject:object];
    }
    specifiers = [sorter getSpecifiers];

    for (PSSpecifier* specifier in specifiers) {
        [specifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
    }

    return specifiers;
}

- (void)removedSpecifier:(PSSpecifier *)specifier {
    AudioServicesPlaySystemSound(1521);
    [[LogManager sharedInstance] removeLog:[specifier propertyForKey:@"log"]];
    [self reloadSpecifiers];
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return NO;
}

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyUseBiometricProtection: @(kPreferenceKeyUseBiometricProtectionDefaultValue),
        kPreferenceKeySorting: kPreferenceKeySortingDefaultValue
    }];

    pfUseBiometricProtection = [[preferences objectForKey:kPreferenceKeyUseBiometricProtection] boolValue];
    pfSorting = [preferences objectForKey:kPreferenceKeySorting];
}
@end
