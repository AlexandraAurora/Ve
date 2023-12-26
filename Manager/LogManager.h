//
//  LogManager.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <rootless.h>
#import <UIKit/UIKit.h>
#import "Log.h"
#import "../Utils/ImageUtil.h"
#import "../Utils/StringUtil.h"
#import "../Utils/DateUtil.h"
#import "../Preferences/NotificationKeys.h"
#import "../Preferences/PreferenceKeys.h"

static NSString* const kLogsPath = ROOT_PATH_NS(@"/var/mobile/Library/codes.aurora.ve/logs.json");
static NSString* const kLogsAttachmentPath = ROOT_PATH_NS(@"/var/mobile/Library/codes.aurora.ve/attachments/");

@interface LogManager : NSObject {
    NSFileManager* _fileManager;
}
@property(nonatomic)BOOL saveAttachments;
@property(nonatomic)NSUInteger logLimit;
@property(nonatomic)BOOL automaticallyDeleteLogs;
+ (instancetype)sharedInstance;
- (void)addLogForBulletin:(BBBulletin *)bulletin;
- (void)removeLog:(Log *)log;
- (NSArray *)getAttachmentsForLog:(Log *)log;
- (NSMutableArray *)getLogsFromJson:(NSMutableDictionary *)json;
- (NSMutableDictionary *)getJson;
@end
