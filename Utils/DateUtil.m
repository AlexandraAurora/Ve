//
//  DateUtil.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "DateUtil.h"

@implementation DateUtil
+ (NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)getDateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}

+ (BOOL)isDate:(NSDate *)date olderThanDays:(NSUInteger)days {
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];

    // Calculate the difference between now and the given date.
    NSDateComponents* components = [calendar components:NSCalendarUnitDay fromDate:date toDate:now options:0];

    return [components day] > days;
}

+ (BOOL)isDate:(NSDate *)date1 inDate:(NSDate *)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];

    NSDateComponents* date1Components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date1];
    NSDateComponents* date2Components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date2];

    return [date1Components day] == [date2Components day] && [date1Components month] == [date2Components month] && [date1Components year] == [date2Components year];
}
@end
