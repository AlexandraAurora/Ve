#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

HBPreferences* preferences = nil;
BOOL enabled = NO;

// household
NSUInteger entryLimitValue = 1;
BOOL deleteIfOlderThan30DaysSwitch = YES;

// control center toggle
BOOL isLoggingTemporarilyDisabled = NO;

@interface BBAttachmentMetadata : NSObject
@property(nonatomic, copy, readonly)NSURL* URL;
@end

@interface BBBulletin : NSObject
@property(nonatomic, copy)NSString* sectionID;
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* message;
@property(nonatomic, copy)BBAttachmentMetadata* primaryAttachment;
@end

@interface SBApplication : NSObject
@property(nonatomic, readonly)NSString* displayName;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end