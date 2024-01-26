//
//  PrivateHeaders.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>

@interface BBAttachmentMetadata : NSObject
@property(nonatomic, copy, readonly)NSURL* URL;
@end

@interface BBBulletin : NSObject
@property(nonatomic, copy)NSString* sectionID;
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* message;
@property(nonatomic)NSDate* date;
@property(nonatomic, copy)BBAttachmentMetadata* primaryAttachment;
@end

@interface UIImage (Private)
+ (id)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(NSUInteger)format scale:(CGFloat)scale;
@end

@interface _UIGrabber : UIControl
@end

@interface PSEditableListController : PSListController
@end

@interface PSSpecifier (Private)
+ (id)emptyGroupSpecifier;
- (void)setValues:(NSArray *)values titles:(NSArray *)titles;
- (void)setButtonAction:(SEL)action;
@end

@interface UILabel (Private)
- (void)setMarqueeEnabled:(BOOL)enabled;
- (void)setMarqueeRunning:(BOOL)running;
@end

@interface _LSQueryResult : NSObject
@end

@interface LSResourceProxy : _LSQueryResult
@end

@interface LSBundleProxy : LSResourceProxy
- (NSString *)localizedName;
@end

@interface LSApplicationProxy : LSBundleProxy
+ (LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)identifier;
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)openApplicationWithBundleID:(NSString *)bundleIdentifier;
@end
