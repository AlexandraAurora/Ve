//
//  AbstractSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "AbstractSorter.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AbstractSorter
- (instancetype)initWithObject:(id)object {
    self = [super init];

    if (self) {
        [self setObject:object];
    }

    return self;
}

- (PSSpecifier *)createSpecifierForLog:(Log *)log {
    PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:[VeDetailListController class] cell:PSLinkCell edit:nil];
    [specifier setProperty:[VeLogCell class] forKey:@"cellClass"];
    [specifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
    [specifier setProperty:@(YES) forKey:@"enabled"];
    [specifier setProperty:@(60) forKey:@"height"];
    [specifier setProperty:log forKey:@"log"];
    return specifier;
}

- (void)removedSpecifier:(PSSpecifier *)specifier {
    AudioServicesPlaySystemSound(1521);
}
@end
