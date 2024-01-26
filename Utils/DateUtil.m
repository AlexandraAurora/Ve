//
//  DateUtil.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "DateUtil.h"

@implementation DateUtil
/**
 * Formats a given date to a string with the specified format.
 *
 * @param date The date to format.
 * @param format The format to use.
 *
 * @return The formatted date string.
 */
+ (NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

/**
 * Formats a given string to a date with the specified format.
 *
 * @param string The string to format.
 * @param format The format to use.
 *
 * @return The formatted date.
 */
+ (NSDate *)getDateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}

/**
 * Checks whether a date is older than a given amount of days.
 *
 * @param date The date to format.
 * @param days The amount of days to check.
 *
 * @return Whether the date is older than the specified amount of days.
 */
+ (BOOL)isDate:(NSDate *)date olderThanDays:(NSUInteger)days {
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];

    // Calculate the difference between now and the given date.
    NSDateComponents* components = [calendar components:NSCalendarUnitDay fromDate:date toDate:now options:0];

    return [components day] > days;
}

/**
 * Checks whether a date is on the same day as another date.
 *
 * @param date1 The date to check.
 * @param date2 The date to check against.
 *
 * @return Whether the dates are on the same day.
 */
+ (BOOL)isDate:(NSDate *)date1 inDate:(NSDate *)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];

    NSDateComponents* date1Components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date1];
    NSDateComponents* date2Components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date2];

    return [date1Components day] == [date2Components day] && [date1Components month] == [date2Components month] && [date1Components year] == [date2Components year];
}

/**
 * Checks whether a date is today.
 *
 * @param date The date to check.
 *
 * @return Whether the date is today.
 */
+ (BOOL)isDateInToday:(NSDate *)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    return [calendar isDateInToday:date];
}

/**
 * Checks whether a date is yesterday.
 *
 * @param date The date to check.
 *
 * @return Whether the date is yesterday.
 */
+ (BOOL)isDateInYesterday:(NSDate *)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    return [calendar isDateInYesterday:date];
}
@end
