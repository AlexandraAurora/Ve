//
//  VeDetailListController.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeDetailListController.h"

@implementation VeDetailListController
- (void)viewDidLoad {
    [super viewDidLoad];

    load_preferences();

    [self setLog:[[self specifier] propertyForKey:@"log"]];

    [self setRemoveButton:[[UIButton alloc] init]];
    [[self removeButton] setImage:[[UIImage systemImageNamed:@"minus.circle"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:23 weight:UIImageSymbolWeightRegular]] forState:UIControlStateNormal];
    [[self removeButton] setTintColor:[UIColor systemRedColor]];
    [self createMenu];
    [[self removeButton] setShowsMenuAsPrimaryAction:YES];

    [self setItem:[[UIBarButtonItem alloc] initWithCustomView:[self removeButton]]];
    [[self navigationItem] setRightBarButtonItem:[self item]];

    [self loadSpecifiers];
}

- (NSArray *)specifiers {
    _specifiers = [[NSMutableArray alloc] init];
	return _specifiers;
}

- (void)loadSpecifiers {
    NSMutableArray* specifiers = [[NSMutableArray alloc] init];
    NSString* displayName = [[self log] getDisplayName];

    PSSpecifier* detailsSpecifier = [PSSpecifier groupSpecifierWithName:@"Details"];
    [detailsSpecifier setProperty:@"Tap on any cell to copy its contents." forKey:@"footerText"];
    [specifiers addObject:detailsSpecifier];

    PSSpecifier* bundleIDSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [bundleIDSpecifier setProperty:[VeDetailCell class] forKey:@"cellClass"];
    [bundleIDSpecifier setButtonAction:@selector(copyContent:)];
    [bundleIDSpecifier setProperty:@"Bundle Identifier" forKey:@"title"];
    [bundleIDSpecifier setProperty:[[self log] bundleIdentifier] forKey:@"content"];
    [specifiers addObject:bundleIDSpecifier];

    PSSpecifier* displayNameSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [displayNameSpecifier setProperty:[VeDetailCell class] forKey:@"cellClass"];
    [displayNameSpecifier setButtonAction:@selector(copyContent:)];
    [displayNameSpecifier setProperty:@"Application" forKey:@"title"];
    [displayNameSpecifier setProperty:displayName forKey:@"content"];
    [specifiers addObject:displayNameSpecifier];

    if (![[[self log] title] isEqualToString:@""]) {
        PSSpecifier* titleSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [titleSpecifier setProperty:[VeDetailCell class] forKey:@"cellClass"];
        [titleSpecifier setButtonAction:@selector(copyContent:)];
        [titleSpecifier setProperty:@"Title" forKey:@"title"];
        [titleSpecifier setProperty:[[self log] title] forKey:@"content"];
        [specifiers addObject:titleSpecifier];
    }

    if (![[[self log] content] isEqualToString:@""]) {
        PSSpecifier* contentSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [contentSpecifier setProperty:[VeDetailCell class] forKey:@"cellClass"];
        [contentSpecifier setButtonAction:@selector(copyContent:)];
        [contentSpecifier setProperty:@"Message" forKey:@"title"];
        [contentSpecifier setProperty:[[self log] content] forKey:@"content"];
        [specifiers addObject:contentSpecifier];
    }

    PSSpecifier* dateSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [dateSpecifier setProperty:[VeDetailCell class] forKey:@"cellClass"];
    [dateSpecifier setButtonAction:@selector(copyContent:)];
    [dateSpecifier setProperty:@"Date" forKey:@"title"];
    [dateSpecifier setProperty:[DateUtil getStringFromDate:[[self log] date] withFormat:@"dd.MM.yyyy HH:mm:ss"] forKey:@"content"];
    [specifiers addObject:dateSpecifier];

    NSArray* attachments = [[LogManager sharedInstance] getAttachmentsForLog:[self log]];
    if ([attachments count] > 0) {
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Attachments"]];

        for (UIImage* image in attachments) {
            PSSpecifier* attachmentSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            [attachmentSpecifier setProperty:[VeAttachmentCell class] forKey:@"cellClass"];
            [attachmentSpecifier setButtonAction:@selector(presentAttachment:)];
            [attachmentSpecifier setProperty:@(YES) forKey:@"enabled"];
            [attachmentSpecifier setProperty:@(70) forKey:@"height"];
            [attachmentSpecifier setProperty:image forKey:@"image"];
            [specifiers addObject:attachmentSpecifier];
        }
    }

    if (![displayName isEqualToString:@"SpringBoard"]) {
        [specifiers addObject:[PSSpecifier emptyGroupSpecifier]];

        PSSpecifier* openSpecifier = [PSSpecifier preferenceSpecifierNamed:[@"Open " stringByAppendingString:displayName] target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [openSpecifier setButtonAction:@selector(openApplication)];
        [specifiers addObject:openSpecifier];
    }

    [self insertContiguousSpecifiers:specifiers atIndex:0];
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return NO;
}

- (void)copyContent:(PSSpecifier *)specifier {
    [[UIPasteboard generalPasteboard] setString:[specifier propertyForKey:@"content"]];
}

- (void)presentAttachment:(PSSpecifier *)specifier {
    VeAttachmentListController* attachmentListController = [[VeAttachmentListController alloc] init];
    [attachmentListController setImage:[specifier propertyForKey:@"image"]];
    [self presentViewController:attachmentListController animated:YES completion:nil];
}

- (void)openApplication {
    [[objc_getClass("LSApplicationWorkspace") defaultWorkspace] openApplicationWithBundleID:[[self log] bundleIdentifier]];
}

- (void)createMenu {
    NSMutableArray* actions = [[NSMutableArray alloc] init];

    UIAction* removeAction = [UIAction actionWithTitle:@"Remove" image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
        [[LogManager sharedInstance] removeLog:[self log]];
        [[self navigationController] popViewControllerAnimated:YES];
    }];
    [actions addObject:removeAction];

    if ([pfBlockedSenders containsObject:[[self log] bundleIdentifier]]) {
        UIAction* unblockAction = [UIAction actionWithTitle:@"Unblock Sender" image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [pfBlockedSenders removeObject:[[self log] bundleIdentifier]];
            [preferences setObject:pfBlockedSenders forKey:kPreferenceKeyBlockedSenders];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kNotificationKeyPreferencesReload, nil, nil, YES);
            [self createMenu];
        }];
        [actions addObject:unblockAction];
    } else {
        UIAction* blockAction = [UIAction actionWithTitle:@"Block Sender" image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            [pfBlockedSenders addObject:[[self log] bundleIdentifier]];
            [preferences setObject:pfBlockedSenders forKey:kPreferenceKeyBlockedSenders];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kNotificationKeyPreferencesReload, nil, nil, YES);
            [self createMenu];
        }];
        [actions addObject:blockAction];
    }

    UIMenu* menu = [UIMenu menuWithTitle:@"" children:actions];

    [[self removeButton] setMenu:menu];
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
