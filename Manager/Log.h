//
//  Log.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Foundation/Foundation.h>

static NSString* const kLogsKeyLogs = @"logs";
static NSString* const kLogsKeyLastIdentifier = @"last_identifier";
static NSString* const kLogsKeyLastHousekeepingDate = @"last_housekeeping_date";
static NSString* const kLogKeyIdentifier = @"identifier";
static NSString* const kLogKeyBundleIdentifier = @"bundle_identifier";
static NSString* const kLogKeyTitle = @"title";
static NSString* const kLogKeyContent = @"content";
static NSString* const kLogKeyDate = @"date";
static NSString* const kLogInternalDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";

@interface Log : NSObject
@property(nonatomic, assign)NSUInteger identifier;
@property(nonatomic)NSString* bundleIdentifier;
@property(nonatomic)NSString* title;
@property(nonatomic)NSString* content;
@property(nonatomic)NSDate* date;
- (instancetype)initWithIdentifier:(NSUInteger)identifier bundleIdentifier:(NSString *)bundleIdentifier title:(NSString *)title content:(NSString *)content andDate:(NSDate *)date;
+ (Log *)logFromDictionary:(NSDictionary *)dictionary;
- (NSString *)getDisplayName;
@end
