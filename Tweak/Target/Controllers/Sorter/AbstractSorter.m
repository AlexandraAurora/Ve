//
//  AbstractSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "AbstractSorter.h"
#import "../VeDetailListController.h"
#import "../../Controllers/Cells/VeLogCell.h"

@implementation AbstractSorter
/**
 * Initializes the sorter.
 *
 * Any object can be passed that may be used to sort logs.
 * e.g. the search sorter uses the search string to sort logs based on the content.
 *
 * @param object The object that's used to sort logs with.
 *
 * @return The sorter.
 */
- (instancetype)initWithObject:(id)object {
    self = [super init];

    if (self) {
        [self setObject:object];
    }

    return self;
}

/**
 * Creates a specifier for a given log.
 *
 * @param log The log from which to create the specifier from.
 *
 * @return The specifier.
 */
- (PSSpecifier *)createSpecifierForLog:(Log *)log {
    PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:nil target:nil set:nil get:nil detail:[VeDetailListController class] cell:PSLinkCell edit:nil];
    [specifier setProperty:[VeLogCell class] forKey:@"cellClass"];
    [specifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
    [specifier setProperty:@(YES) forKey:@"enabled"];
    [specifier setProperty:@(60) forKey:@"height"];
    [specifier setProperty:log forKey:@"log"];
    return specifier;
}
@end
