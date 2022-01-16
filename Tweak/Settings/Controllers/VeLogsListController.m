#import "VeLogsListController.h"

// protection
BOOL biometricProtectionSwitch = NO;
BOOL authenticated = NO;

// formats
NSString* timeFormatValue = @"HH:mm";
NSString* dateFormatValue = @"dd.MM.YYYY";

// display settings
NSUInteger threshholdValue = 1;
BOOL hideExcessSwitch = YES;

@implementation VeLogsListController

- (void)viewDidLoad { // add the settings button and pull to refresh, also use biometrics if enabled

    [super viewDidLoad];

    [self setTitle:@"Notification Logs"];


    // settings button
    self.settingsButton = [UIButton new];
    [[self settingsButton] addTarget:self action:@selector(presentAdvancedController) forControlEvents:UIControlEventTouchUpInside];
    [[self settingsButton] setImage:[[UIImage systemImageNamed:@"ellipsis.circle"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIImageSymbolWeightRegular]] forState:UIControlStateNormal];
    [[self settingsButton] setTintColor:[UIColor systemBlueColor]];

    self.item = [[UIBarButtonItem alloc] initWithCustomView:[self settingsButton]];
    [[self navigationItem] setRightBarButtonItem:[self item]];


    // pull to refresh
    self.pullToRefreshControl = [UIRefreshControl new];
    [[self pullToRefreshControl] addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [[self pullToRefreshControl] setTintColor:[UIColor labelColor]];
    [[self table] setRefreshControl:[self pullToRefreshControl]];
    [[[[self pullToRefreshControl] subviews] objectAtIndex:0] setFrame:CGRectMake(0, 60, 0, 0)];


    // biometric protection
    if (biometricProtectionSwitch && !authenticated) {
        LAContext* laContext = [LAContext new];
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Vē needs to make sure that you are permitted to view logs." reply:^(BOOL success, NSError* _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    authenticated = YES;
                    [self reloadSpecifiers];
                } else {
                    [[self navigationController] popViewControllerAnimated:YES];
                }
            });
        }];
    }

}

- (NSArray *)specifiers { // list all logged notifications

    // preferences
    self.preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.vepreferences"];
    [[self preferences] registerBool:&biometricProtectionSwitch default:NO forKey:@"biometricProtection"];
    [[self preferences] registerObject:&timeFormatValue default:@"HH:mm" forKey:@"timeFormat"];
    [[self preferences] registerObject:&dateFormatValue default:@"dd.MM.YYYY" forKey:@"dateFormat"];
    [[self preferences] registerUnsignedInteger:&threshholdValue default:1 forKey:@"threshhold"];
    [[self preferences] registerBool:&hideExcessSwitch default:YES forKey:@"hideExcess"];

    if (biometricProtectionSwitch && !authenticated) { // don't display any specifiers until authenticated, if protection is enabled
        [self removeContiguousSpecifiers:_specifiers animated:NO];
        return nil;
    }


    _specifiers = [NSMutableArray new];
    NSDictionary* logsDictionary = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/love.litten.ve-logs.plist"];
    self.logs = [logsDictionary objectForKey:@"loggedNotifications"];


    // statistics and search bar
    [_specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Statistics & Search"]];

    // statistics cell
    PSSpecifier* statisticsSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
    [statisticsSpecifier setProperty:[VeStatisticsCell class] forKey:@"cellClass"];
    [statisticsSpecifier setProperty:@(YES) forKey:@"enabled"];
    [statisticsSpecifier setProperty:@"150" forKey:@"height"];

    NSUInteger logsFromToday = 0;
    NSUInteger logsFromThePastSevenDays = 0;
    for (NSDictionary* log in [self logs]) {
        if ([[NSCalendar currentCalendar] isDateInToday:[log objectForKey:@"date"]]) logsFromToday += 1;

		NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		NSDateComponents* components = [calendar components:NSCalendarUnitDay fromDate:[log objectForKey:@"date"] toDate:[NSDate date] options:0];
		if ([components day] <= 7) logsFromThePastSevenDays += 1;
    }
    [statisticsSpecifier setProperty:[NSString stringWithFormat:@"%lu", logsFromToday] forKey:@"todayValue"];
    [statisticsSpecifier setProperty:[NSString stringWithFormat:@"%lu", logsFromThePastSevenDays] forKey:@"pastSevenDaysValue"];

    [statisticsSpecifier setProperty:[NSString stringWithFormat:@"%lu", [[self logs] count]] forKey:@"currentlyStoredValue"];
    [statisticsSpecifier setProperty:[NSString stringWithFormat:@"%d", [[logsDictionary objectForKey:@"totalLoggedNotificationCount"] intValue]] forKey:@"totalStoredValue"];
    [_specifiers addObject:statisticsSpecifier];

    // search bar cell
    PSSpecifier* searchBarSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
    [searchBarSpecifier setProperty:[VeSearchBarCell class] forKey:@"cellClass"];
    [searchBarSpecifier setProperty:@(YES) forKey:@"enabled"];
    [searchBarSpecifier setProperty:@"50" forKey:@"height"];

    UISearchBar* searchBar = [UISearchBar new];
    [searchBar setDelegate:self];
    [searchBarSpecifier setProperty:searchBar forKey:@"searchBar"];
    
    [_specifiers addObject:searchBarSpecifier];


    // if no logs are stored yet return here
    if ([[self logs] count] == 0) {
        PSSpecifier* emptyLogsSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    	[emptyLogsSpecifier setProperty:@"No logs have been taken yet." forKey:@"footerText"];
        [emptyLogsSpecifier setProperty:@(1) forKey:@"footerAlignment"];
        [_specifiers addObject:emptyLogsSpecifier];

        return _specifiers;
    }

    // list notifications
    [self createNotificationSpecifiersFromLogs:[self logs] withSearch:nil];
    [_specifiers addObjectsFromArray:[self notificationSpecifiers]];

    return _specifiers;
}

- (BOOL)shouldReloadSpecifiersOnResume { // prevent the controller from reloading the view after inactivity

    return false;

}

- (void)createNotificationSpecifiersFromLogs:(NSArray *)logs withSearch:(NSString *)search {

    self.notificationSpecifiers = [NSMutableArray new];
    NSDateFormatter* dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:[NSString stringWithFormat:@"EEEE, %@ %@", dateFormatValue, timeFormatValue]];
    NSDictionary* log = [[self logs] firstObject];
    NSString* currentTimestamp = [dateFormat stringFromDate:[log objectForKey:@"date"]];
    NSString* previousTimestamp = currentTimestamp;

    for (NSUInteger i = 0, timesFound = 1; i < [[self logs] count]; i++) {
        if (!search || ([[log objectForKey:@"title"] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound || [[log objectForKey:@"message"] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)) {
            NSString* title = [log objectForKey:@"bundleID"]; // this is the fallback and will be overwritten if the title or display name is available
            if (![[log objectForKey:@"title"] isEqualToString:@""]) title = [NSString stringWithFormat:@"%@", [log objectForKey:@"title"]];
            else if ([[log objectForKey:@"title"] isEqualToString:@""] && ![[log objectForKey:@"displayName"] isEqualToString:@""]) title = [log objectForKey:@"displayName"];

            PSSpecifier* logSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            [logSpecifier setProperty:[VeNotificationCell class] forKey:@"cellClass"];
            [logSpecifier setButtonAction:@selector(expandLog:)];
            [logSpecifier setProperty:@(YES) forKey:@"enabled"];
            [logSpecifier setProperty:@"60" forKey:@"height"];
            [logSpecifier setProperty:[log objectForKey:@"identifier"] forKey:@"identifier"];
            [logSpecifier setProperty:[log objectForKey:@"bundleID"] forKey:@"bundleID"];
            [logSpecifier setProperty:[log objectForKey:@"displayName"] forKey:@"displayName"];
            [logSpecifier setProperty:title forKey:@"title"];
            [logSpecifier setProperty:[log objectForKey:@"message"] forKey:@"message"];
            [logSpecifier setProperty:[log objectForKey:@"attachments"] forKey:@"attachments"];
            [logSpecifier setProperty:[log objectForKey:@"date"] forKey:@"date"];
            [logSpecifier setProperty:timeFormatValue forKey:@"timeFormat"];
            [logSpecifier setProperty:dateFormatValue forKey:@"dateFormat"];
            [[self notificationSpecifiers] addObject:logSpecifier];

            // Check if the next notification was in the same minute
            if (!search) {
                log = (i == [[self logs] count] - 1) ? nil : [self logs][i + 1];
                currentTimestamp = log ? [dateFormat stringFromDate:[log objectForKey:@"date"]] : @"";

                if (![previousTimestamp isEqualToString:currentTimestamp]) {
                    if (threshholdValue > 1 && timesFound >= threshholdValue) {
                        NSString* bundleID = [[self logs][i] objectForKey:@"bundleID"];
                        for (NSUInteger j = 1; j <= timesFound; j++) {
                            if (hideExcessSwitch) {
                                PSSpecifier* last = [_specifiers lastObject];
                                NSString* bundle = last.properties[@"bundleID"];
                                if (![bundle isEqualToString:@"com.apple.Preferences"] && ![bundle isEqualToString:bundleID])
                                    bundleID = @"com.apple.Preferences";
                                if (j != timesFound) [_specifiers removeLastObject];
                                else {
                                    // Replace remaining notification with summary
                                    NSString* title = [NSString stringWithFormat:@"%lu notifications hidden", timesFound];
                                    [last setProperty:bundleID forKey:@"bundleID"];
                                    [last setProperty:@"Notification Log" forKey:@"displayName"];
                                    [last setProperty:title forKey:@"title"];
                                }
                            } else {
                                PSSpecifier* k = _specifiers[[_specifiers count] - j];
                                NSString* format = [NSString stringWithFormat:@"%@ (#%lu)", timeFormatValue, j];
                                [k setProperty:format forKey:@"timeFormat"];
                            }
                        }
                    }
                    timesFound = 0;
                }
                previousTimestamp = currentTimestamp;
                timesFound += 1;
            }
        }
    }

    if ([[self notificationSpecifiers] count] > 0) {
        [[self notificationSpecifiers] insertObject:[PSSpecifier groupSpecifierWithName:@"Notifications"] atIndex:0];
    } else {
        PSSpecifier* nothingFoundSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    	[nothingFoundSpecifier setProperty:@"Nothing to be found that matches your search." forKey:@"footerText"];
        [nothingFoundSpecifier setProperty:@(1) forKey:@"footerAlignment"];
        [[self notificationSpecifiers] insertObject:nothingFoundSpecifier atIndex:0];
    }


}

- (void)presentAdvancedController { // present settings

    [[self navigationController] pushViewController:[VeAdvancedListController new] animated:YES];

}

- (void)pullToRefresh { // reload the specifiers with pull to refresh

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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    [self removeContiguousSpecifiers:[self notificationSpecifiers]];
    
    if ([searchText length] > 0) {
        [self createNotificationSpecifiersFromLogs:[self logs] withSearch:searchText];
    } else {
        [self createNotificationSpecifiersFromLogs:[self logs] withSearch:nil];
        [searchBar performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1];
    }
    
    [self insertContiguousSpecifiers:[self notificationSpecifiers] atIndex:[_specifiers count]];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

    [searchBar setShowsCancelButton:YES animated:YES];

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {

    [searchBar setShowsCancelButton:NO animated:YES];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [searchBar resignFirstResponder];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [searchBar resignFirstResponder];

}

- (void)expandLog:(PSSpecifier *)specifier { // expand the selected log

    VeDetailViewListController* detailViewListController = [VeDetailViewListController new];
    [detailViewListController setNotificationID:[specifier.properties[@"identifier"] intValue]];
    [detailViewListController setNotificationBundleID:specifier.properties[@"bundleID"]];
    [detailViewListController setNotificationDisplayName:specifier.properties[@"displayName"]];
    [detailViewListController setNotificationTitle:specifier.properties[@"title"]];
    [detailViewListController setNotificationMessage:specifier.properties[@"message"]];
    [detailViewListController setNotificationAttachments:specifier.properties[@"attachments"]];
    [detailViewListController setDateFormat:dateFormatValue];
    [detailViewListController setTimeFormat:timeFormatValue];
    [detailViewListController setNotificationDate:specifier.properties[@"date"]];
    [self presentViewController:detailViewListController animated:YES completion:nil];

}

@end
