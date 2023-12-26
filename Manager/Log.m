//
//  Log.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "Log.h"

@implementation Log
- (instancetype)initWithIdentifier:(NSUInteger)identifier bundleIdentifier:(NSString *)bundleIdentifier title:(NSString *)title content:(NSString *)content andDate:(NSDate *)date {
    self = [super init];

    if (self) {
        [self setIdentifier:identifier];
        [self setBundleIdentifier:bundleIdentifier];
        [self setTitle:title];
        [self setContent:content];
        [self setDate:date];
    }

    return self;
}

+ (Log *)logFromDictionary:(NSDictionary *)dictionary {
    NSUInteger identifier = [dictionary[kLogKeyIdentifier] unsignedIntegerValue];
    NSString* bundleIdentifier = dictionary[kLogKeyBundleIdentifier];
    NSString* title = dictionary[kLogKeyTitle];
    NSString* content = dictionary[kLogKeyContent];
    NSDate* date = [DateUtil getDateFromString:dictionary[kLogKeyDate] withFormat:kLogInternalDateFormat];

    return [[Log alloc] initWithIdentifier:identifier bundleIdentifier:bundleIdentifier title:title content:content andDate:date];
}

- (NSString *)getDisplayName {
    LSApplicationProxy* applicationProxy = [objc_getClass("LSApplicationProxy") applicationProxyForIdentifier:[self bundleIdentifier]];
    return [applicationProxy localizedName] ?: @"SpringBoard";
}
@end
