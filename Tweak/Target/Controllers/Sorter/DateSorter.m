//
//  DateSorter.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "DateSorter.h"
#import "../../../../Utils/DateUtil.h"
#import "../../../../Preferences/PreferenceKeys.h"

@implementation DateSorter
/**
 * @inheritdoc
 */
- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];

    if (self) {
        load_preferences();

        if (pfUseAmericanDateFormat) {
            dateFormat = @"MM.dd.yyyy";
        }
    }

    return self;
}

/**
 * Returns an array of specifiers sorted by date.
 *
 * @return The specifiers array.
 */
- (NSArray *)getSpecifiers {
    NSMutableArray* specifiers = [[NSMutableArray alloc] init];
    NSMutableDictionary* json = [[LogManager sharedInstance] getJson];
    NSMutableArray* logs = [[LogManager sharedInstance] getLogsFromJson:json];

    for (__strong NSString* dateString in [self getUniqueFormattedDatesForLogs:logs]) {
        NSDate* date = [DateUtil getDateFromString:dateString withFormat:dateFormat];

        // Display "Today" or "Yesterday" instead of the date if applicable.
        if ([DateUtil isDateInToday:date]) {
            dateString = @"Today";
        } else if ([DateUtil isDateInYesterday:date]) {
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

/**
 * Returns a unique array of all dates from logs.
 *
 * @param logs The logs from which to get the dates from.
 *
 * @return The array of unique dates.
 */
- (NSArray *)getUniqueFormattedDatesForLogs:(NSMutableArray *)logs {
    NSMutableArray* dates = [[NSMutableArray alloc] init];

    for (NSDictionary* dictionary in logs) {
        Log* log = [Log logFromDictionary:dictionary];
        NSString* dateString = [DateUtil getStringFromDate:[log date] withFormat:dateFormat];

        if (![dates containsObject:dateString]) {
            [dates addObject:dateString];
        }
    }

    return dates;
}

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyUseAmericanDateFormat: kPreferenceKeyUseAmericanDateFormat
    }];

    pfUseAmericanDateFormat = [[preferences objectForKey:kPreferenceKeyUseAmericanDateFormat] boolValue];
}
@end
