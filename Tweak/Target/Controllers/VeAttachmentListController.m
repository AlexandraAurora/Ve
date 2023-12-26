//
//  VeAttachmentListController.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeAttachmentListController.h"

@implementation VeAttachmentListController
- (void)viewDidLoad {
    [super viewDidLoad];


    // grabber
    [self setGrabber:[[_UIGrabber alloc] init]];
    [[self view] addSubview:[self grabber]];

    [[self grabber] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self grabber] topAnchor] constraintEqualToAnchor:[[self view] topAnchor] constant:12],
        [[[self grabber] centerXAnchor] constraintEqualToAnchor:[[self view] centerXAnchor]]
    ]];
}

- (NSArray *)specifiers { // add the specifiers
    _specifiers = [[NSMutableArray alloc] init];


    PSSpecifier* attachmentSpecifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
    [attachmentSpecifier setProperty:[VeFullAttachmentCell class] forKey:@"cellClass"];
    [attachmentSpecifier setProperty:@(500) forKey:@"height"];
    [attachmentSpecifier setProperty:[self image] forKey:@"image"];
    [_specifiers addObject:attachmentSpecifier];


    // actions
    [_specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Actions" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

    PSSpecifier* copySpecifier = [PSSpecifier preferenceSpecifierNamed:@"Copy to Clipboard" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [copySpecifier setButtonAction:@selector(copyAttachment)];
    [_specifiers addObject:copySpecifier];

    PSSpecifier* saveSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Save to Photo Library" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [saveSpecifier setButtonAction:@selector(saveAttachment)];
    [_specifiers addObject:saveSpecifier];

	return _specifiers;
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return NO;
}

- (void)copyAttachment {
    [[UIPasteboard generalPasteboard] setImage:[self image]];
}

- (void)saveAttachment {
    UIImageWriteToSavedPhotosAlbum([self image], nil, nil, nil);
}
@end
