//
//  DateSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "DateSorter.h"

@implementation DateSorter
- (NSArray *)getSpecifiers {
    NSMutableArray* specifiers = [[NSMutableArray alloc] init];
    NSMutableDictionary* json = [[LogManager sharedInstance] getJson];
    NSMutableArray* logs = [[LogManager sharedInstance] getLogsFromJson:json];

    for (__strong NSString* dateString in [self getUniqueFormattedDatesForLogs:logs]) {
        NSDate* date = [DateUtil getDateFromString:dateString withFormat:@"dd.MM.yyyy"];

        // Display "Today" or "Yesterday" instead of the date if applicable.
        NSCalendar* calendar = [NSCalendar currentCalendar];
        if ([calendar isDateInToday:date]) {
            dateString = @"Today";
        } else if ([calendar isDateInYesterday:date]) {
            dateString = @"Yesterday";
        }

        [specifiers addObject:[PSSpecifier groupSpecifierWithName:dateString]];

        for (NSDictionary* dictionary in logs) {
            Log* log = [Log logFromDictionary:dictionary];

            if ([DateUtil isDate:[log date] inDate:date]) {
                [specifiers addObject:[self createSpecifierForLog:log]];
            }
        }
    }

    return specifiers;
}

- (NSArray *)getUniqueFormattedDatesForLogs:(NSMutableArray *)logs {
    NSMutableArray* dates = [[NSMutableArray alloc] init];

    for (NSDictionary* dictionary in logs) {
        Log* log = [Log logFromDictionary:dictionary];
        NSString* dateString = [DateUtil getStringFromDate:[log date] withFormat:@"dd.MM.yyyy"];

        if (![dates containsObject:dateString]) {
            [dates addObject:dateString];
        }
    }

    return dates;
}
@end
