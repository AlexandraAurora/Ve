//
//  LogManager.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "LogManager.h"

@implementation LogManager
+ (instancetype)sharedInstance {
    static LogManager* sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [LogManager alloc];
        sharedInstance->_fileManager = [NSFileManager defaultManager];
    });

    return sharedInstance;
}

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

    // unseen notifications will be sent again after a respring
    // we check by date if the notification has been logged already
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

    if ([self saveAttachments]) {
        [self saveAttachmentsForLog:log fromBulletin:bulletin];
    }

    // remove the oldest logs if the logs contain more logs than the set limit
    while ([logs count] > [self logLimit]) {
        [logs removeLastObject];
    }

    json[kLogsKeyLogs] = logs;
    json[kLogsKeyLastIdentifier] = @(identifier);

    [self setJsonFromDictionary:json];

    if ([self automaticallyDeleteLogs]) {
        [self removeOverdueLogsFromLogs:logs];
    }
}

- (void)removeLog:(Log *)log {
    NSMutableDictionary* json = [self getJson];
    NSMutableArray* logs = [self getLogsFromJson:json];

    for (NSDictionary* dictionary in logs) {
        Log* tmpLog = [Log logFromDictionary:dictionary];
        if ([log identifier] == [tmpLog identifier]) {
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

- (void)saveAttachmentsForLog:(Log *)log fromBulletin:(BBBulletin *)bulletin {
    NSURL* attachmentsURL = [[[bulletin primaryAttachment] URL] URLByDeletingLastPathComponent];
    NSString* attachmentsDirectoryPath = [[attachmentsURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSArray* attachmentsDirectoryContents = [_fileManager contentsOfDirectoryAtPath:attachmentsDirectoryPath error:nil];

    for (NSUInteger i = 0; i < [attachmentsDirectoryContents count]; i++) {
        BOOL isDirectory;
        NSString* directoryPath = [NSString stringWithFormat:@"%@%lu/", kLogsAttachmentPath, [log identifier]];
        if (![_fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
            [_fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString* fileName = attachmentsDirectoryContents[i];
        NSString* filePath = [NSString stringWithFormat:@"%@%@", attachmentsDirectoryPath, fileName];
        UIImage* image = [UIImage imageWithContentsOfFile:filePath];

        if ([ImageUtil imageHasAlpha:image]) {
            NSData* attachmentData = UIImagePNGRepresentation(image);
            [attachmentData writeToFile:[NSString stringWithFormat:@"%@%@.png", directoryPath, [StringUtil getRandomStringWithLength:32]] atomically:YES];
        } else {
            NSData* attachmentData = UIImageJPEGRepresentation(image, 1);
            [attachmentData writeToFile:[NSString stringWithFormat:@"%@%@.jpg", directoryPath, [StringUtil getRandomStringWithLength:32]] atomically:YES];
        }
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
    return json[kLogsKeyLastHousekeepingDate] ?: [DateUtil getStringFromDate:[NSDate date] withFormat:kLogInternalDateFormat];
}

- (NSMutableDictionary *)getJson {
    [self ensureResourcesExist];

    NSData* jsonData = [NSData dataWithContentsOfFile:kLogsPath];
    NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

    return json;
}

- (void)setJsonFromDictionary:(NSMutableDictionary *)dictionary {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [jsonData writeToFile:kLogsPath atomically:YES];
}

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
