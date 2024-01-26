//
//  ApplicationSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "ApplicationSorter.h"

@implementation ApplicationSorter
/**
 * Returns an array of specifiers sorted alphabetically by application.
 *
 * @return The specifiers array.
 */
- (NSArray *)getSpecifiers {
    NSMutableArray* specifiers = [[NSMutableArray alloc] init];
    NSMutableDictionary* json = [[LogManager sharedInstance] getJson];
    NSMutableArray* logs = [[LogManager sharedInstance] getLogsFromJson:json];

    for (NSString* displayName in [self getUniqueDisplayNamesForLogs:logs]) {
        [specifiers addObject:[PSSpecifier groupSpecifierWithName:displayName]];

        for (NSDictionary* dictionary in logs) {
            Log* log = [Log logFromDictionary:dictionary];

            if ([displayName isEqualToString:[log getDisplayName]]) {
                [specifiers addObject:[self createSpecifierForLog:log]];
            }
        }
    }

    return specifiers;
}

/**
 * Returns a unique array of all display names from logs.
 *
 * Logs that return "SpringBoard" as their display name are added at the bottom.
 *
 * @param logs The logs from which to get the display names from.
 *
 * @return The array of unique display names.
 */
- (NSArray *)getUniqueDisplayNamesForLogs:(NSMutableArray *)logs {
    NSMutableArray* displayNames = [[NSMutableArray alloc] init];
    BOOL isUnknownPresent = NO;

    for (NSDictionary* dictionary in logs) {
        Log* log = [Log logFromDictionary:dictionary];
        NSString* displayName = [log getDisplayName];

        if (![displayNames containsObject:displayName]) {
            if ([displayName isEqualToString:@"SpringBoard"]) {
                isUnknownPresent = YES;
            } else {
                [displayNames addObject:displayName];
            }
        }
    }

    // Sort the display names alphabetically.
    NSMutableArray* sortedDisplayNames = [[displayNames sortedArrayUsingSelector:@selector(compare:)] mutableCopy];

    // Unknown apps should always be at the bottom of the list.
    if (isUnknownPresent) {
        [sortedDisplayNames addObject:@"SpringBoard"];
    }

    return [NSMutableArray arrayWithArray:sortedDisplayNames];
}
@end
