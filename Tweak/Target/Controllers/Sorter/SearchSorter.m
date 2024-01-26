//
//  SearchSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "SearchSorter.h"

@implementation SearchSorter
/**
 * Returns an array of specifiers sorted with a search term.
 *
 * @return The specifiers array.
 */
- (NSArray *)getSpecifiers {
    NSMutableArray* specifiers = [[NSMutableArray alloc] init];
    NSMutableDictionary* json = [[LogManager sharedInstance] getJson];
    NSMutableArray* logs = [[LogManager sharedInstance] getLogsFromJson:json];

    [specifiers addObject:[PSSpecifier groupSpecifierWithName:@"Search Results"]];

    for (NSDictionary* dictionary in logs) {
        Log* log = [Log logFromDictionary:dictionary];

        if ([[[log title] lowercaseString] containsString:[[self object] lowercaseString]] ||
            [[[log content] lowercaseString] containsString:[[self object] lowercaseString]]
        ) {
            [specifiers addObject:[self createSpecifierForLog:log]];
        }
    }

    return specifiers;
}
@end
