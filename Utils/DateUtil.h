//
//  DateUtil.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject
+ (NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSDate *)getDateFromString:(NSString *)string withFormat:(NSString *)format;
+ (BOOL)isDate:(NSDate *)date olderThanDays:(NSUInteger)days;
+ (BOOL)isDate:(NSDate *)date1 inDate:(NSDate *)date2;
@end
