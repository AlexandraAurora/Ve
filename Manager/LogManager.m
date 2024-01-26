//
//  LogManager.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "LogManager.h"
#import "Log.h"
#import "../Utils/ImageUtil.h"
#import "../Utils/StringUtil.h"
#import "../Utils/DateUtil.h"
#import "../Preferences/NotificationKeys.h"
#import "../Preferences/PreferenceKeys.h"
#import "../PrivateHeaders.h"

@implementation LogManager
/**
 * Creates the shared instance.
 */
+ (instancetype)sharedInstance {
    static LogManager* sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [LogManager alloc];
        sharedInstance->_fileManager = [NSFileManager defaultManager];
    });

    return sharedInstance;
}

/**
 * Creates the manager using the shared instance.
 */
- (instancetype)init {
    return [LogManager sharedInstance];
}

- (void)addLogForBulletin:(BBBulletin *)bulletin {
    NSMutableDictionary* json = [self getJson];
    NSUInteger lastIdentifier = [self getLastIdentifierFromJson:json];
    NSMutableArray* logs = [self getLogsFromJson:json];

    NSUInteger identifier = lastIdentifier + 1;
    NSString* bundleIdentifier = [bulletin sectionID] ?: @"com.apple.springboard";
    NSString* title = [bulletin title] ?: @"";
    NSString* content = [bulletin message] ?: @"";
    NSDate* date = [bulletin date] ?: [NSDate date];
    Log* log = [[Log alloc] initWithIdentifier:identifier bundleIdentifier:bundleIdentifier title:title content:content andDate:date];

    // Unseen notifications will be sent again after a respring.
    // We check by date if the notification has been logged already.
    if ([self isLogAlreadyLogged:log inLogs:logs]) {
        return;
    }

    [logs insertObject:@{
        kLogKeyIdentifier: @(identifier),
        kLogKeyBundleIdentifier: [log bundleIdentifier],
        kLogKeyTitle: [log title],
        kLogKeyContent: [log content],
        kLogKeyDate: [DateUtil getStringFromDate:[log date] withFormat:kLogInternalDateFormat]
    } atIndex:0];

    if ([self saveLocalAttachments]) {
        [self saveLocalAttachmentsForLog:log fromBulletin:bulletin];
    }

    if ([self saveRemoteAttachments]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveRemoteAttachmentsForLog:log];
        });
    }

    // Remove the oldest logs if the logs count exceeds the set limit.
    while ([logs count] > [self logLimit]) {
        [logs removeLastObject];
    }

    json[kLogsKeyLogs] = logs;
    json[kLogsKeyLastIdentifier] = @(identifier);

    [self setJsonFromDictionary:json];

    // if ([self automaticallyDeleteLogs]) {
    //     [self removeOverdueLogsFromLogs:logs];
    // }
}

- (void)removeLog:(Log *)log {
    NSMutableDictionary* json = [self getJson];
    NSMutableArray* logs = [self getLogsFromJson:json];

    for (NSDictionary* dictionary in logs) {
        Log* _log = [Log logFromDictionary:dictionary];
        if ([log identifier] == [_log identifier]) {
            [logs removeObject:dictionary];
            break;
        }
    }

    json[kLogsKeyLogs] = logs;

    [self setJsonFromDictionary:json];
}

- (void)removeOverdueLogsFromLogs:(NSMutableArray *)logs {
    NSMutableDictionary* json = [self getJson];
    NSDate* now = [NSDate date];
    NSDate* lastHouseholdDate = [DateUtil getDateFromString:[self getLastHousekeepingDateFromJson:json] withFormat:kLogInternalDateFormat];

    if ([DateUtil isDate:lastHouseholdDate inDate:now]) {
        return;
    }
    json[kLogsKeyLastHousekeepingDate] = [DateUtil getStringFromDate:now withFormat:kLogInternalDateFormat];
    [self setJsonFromDictionary:json];

    for (Log* log in logs) {
        if ([DateUtil isDate:[log date] olderThanDays:7]) {
            [self removeLog:log];
        }
    }
}

- (void)saveLocalAttachmentsForLog:(Log *)log fromBulletin:(BBBulletin *)bulletin {
    NSURL* attachmentsURL = [[[bulletin primaryAttachment] URL] URLByDeletingLastPathComponent];
    NSString* attachmentsDirectoryPath = [[attachmentsURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSArray* attachmentsDirectoryContents = [_fileManager contentsOfDirectoryAtPath:attachmentsDirectoryPath error:nil];

    for (NSUInteger i = 0; i < [attachmentsDirectoryContents count]; i++) {
        NSString* fileName = attachmentsDirectoryContents[i];
        NSString* filePath = [NSString stringWithFormat:@"%@%@", attachmentsDirectoryPath, fileName];
        UIImage* image = [UIImage imageWithContentsOfFile:filePath];

        if (image) {
            [self saveAttachmentImage:image forLog:log];
        }
    }
}

- (void)saveRemoteAttachmentsForLog:(Log *)log {
    NSDataDetector* dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSMutableArray* matches = [[NSMutableArray alloc] init];

    for (NSString* string in @[[log title], [log content]]) {
        NSArray* newMatches = [dataDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        [matches addObjectsFromArray:newMatches];
    }

    for (NSTextCheckingResult* match in matches) {
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[match URL]]];
        if (image) {
            [self saveAttachmentImage:image forLog:log];
        }
    }
}

- (void)saveAttachmentImage:(UIImage *)image forLog:(Log *)log {
    NSString* directoryPath = [NSString stringWithFormat:@"%@%lu/", kLogsAttachmentPath, [log identifier]];
    if (![_fileManager fileExistsAtPath:directoryPath]) {
        [_fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    if ([ImageUtil imageHasAlpha:image]) {
        NSData* attachmentData = UIImagePNGRepresentation(image);
        [attachmentData writeToFile:[NSString stringWithFormat:@"%@%@.png", directoryPath, [StringUtil getRandomStringWithLength:32]] atomically:YES];
    } else {
        NSData* attachmentData = UIImageJPEGRepresentation(image, 1);
        [attachmentData writeToFile:[NSString stringWithFormat:@"%@%@.jpg", directoryPath, [StringUtil getRandomStringWithLength:32]] atomically:YES];
    }
}

- (NSArray *)getAttachmentsForLog:(Log *)log {
    NSString* directoryPath = [NSString stringWithFormat:@"%@%lu/", kLogsAttachmentPath, [log identifier]];
    NSArray* directoryContents = [_fileManager contentsOfDirectoryAtPath:directoryPath error:nil];

    NSMutableArray* attachments = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [directoryContents count]; i++) {
        NSString* fileName = directoryContents[i];
        NSString* filePath = [NSString stringWithFormat:@"%@%@", directoryPath, fileName];
        [attachments addObject:[UIImage imageWithContentsOfFile:filePath]];
    }

    return attachments;
}

- (BOOL)isLogAlreadyLogged:(Log *)log inLogs:(NSMutableArray *)logs {
    NSString* logDateString = [DateUtil getStringFromDate:[log date] withFormat:kLogInternalDateFormat];

    for (NSDictionary* existingLogDictionary in logs) {
        Log* existingLog = [Log logFromDictionary:existingLogDictionary];
        NSString* existingLogDateString = [DateUtil getStringFromDate:[existingLog date] withFormat:kLogInternalDateFormat];
        if ([existingLogDateString isEqualToString:logDateString]) {
            return YES;
        }
    }

    return NO;
}

- (NSMutableArray *)getLogsFromJson:(NSMutableDictionary *)json {
    return json[kLogsKeyLogs] ?: [[NSMutableArray alloc] init];
}

- (NSUInteger)getLastIdentifierFromJson:(NSMutableDictionary *)json {
    return [json[kLogsKeyLastIdentifier] ?: @(0) unsignedIntegerValue];
}

- (NSString *)getLastHousekeepingDateFromJson:(NSMutableDictionary *)json {
    NSString* dateString = json[kLogsKeyLastHousekeepingDate];

    if (!dateString) {
        dateString = [DateUtil getStringFromDate:[NSDate date] withFormat:kLogInternalDateFormat];
        json[kLogsKeyLastHousekeepingDate] = dateString;
        [self setJsonFromDictionary:json];
    }

    return dateString;
}

/**
 * Returns a dictionary from the json containing the logs.
 *
 * @return The dictionary.
 */
- (NSMutableDictionary *)getJson {
    [self ensureResourcesExist];

    NSData* jsonData = [NSData dataWithContentsOfFile:kLogsPath];
    NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

    return json;
}

/**
 * Saves the dictionary contents to the json file.
 *
 * @param dictionary The dictionary from which to save the contents from.
 */
- (void)setJsonFromDictionary:(NSMutableDictionary *)dictionary {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [jsonData writeToFile:kLogsPath atomically:YES];
}

/**
 * Creates the json and path for the attachments.
 */
- (void)ensureResourcesExist {
    BOOL isDirectory;
    if (![_fileManager fileExistsAtPath:kLogsAttachmentPath isDirectory:&isDirectory]) {
        [_fileManager createDirectoryAtPath:kLogsAttachmentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    if (![_fileManager fileExistsAtPath:kLogsPath]) {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[[NSMutableDictionary alloc] init] options:NSJSONWritingPrettyPrinted error:nil];
        [jsonData writeToFile:kLogsPath options:NSDataWritingAtomic error:nil];
    }
}
@end
