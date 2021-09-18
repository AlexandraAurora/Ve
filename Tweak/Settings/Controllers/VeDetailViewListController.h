#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "../Custom-Cells/VeDetailCell.h"
#import "../Custom-Cells/VeDetailAttachmentCell.h"
#import "VeDetailAttachmentListController.h"
#import "../PrivateHeaders.h"
#import <objc/runtime.h>
#import <Cephei/HBPreferences.h>

@interface VeDetailViewListController : PSListController
@property(nonatomic, assign)NSUInteger notificationID;
@property(nonatomic, assign)NSString* notificationBundleID;
@property(nonatomic, assign)NSString* notificationDisplayName;
@property(nonatomic, assign)NSString* notificationTitle;
@property(nonatomic, assign)NSString* notificationMessage;
@property(nonatomic, assign)NSArray* notificationAttachments;
@property(nonatomic, assign)NSString* dateFormat;
@property(nonatomic, assign)NSString* timeFormat;
@property(nonatomic, assign)NSDate* notificationDate;
@property(nonatomic, retain)_UIGrabber* grabber;
- (void)copyContent:(PSSpecifier *)specifier;
- (void)presentAttachment:(PSSpecifier *)specifier;
- (void)openApplication;
- (void)blockBundleIdentifier;
- (void)deleteLog;
@end