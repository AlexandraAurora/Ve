//
//  VeRootListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "../PreferenceKeys.h"
#import "../NotificationKeys.h"
#import <rootless.h>

@interface VeRootListController : PSListController
@end

@interface NSTask : NSObject
@property(copy)NSArray* arguments;
@property(copy)NSString* launchPath;
- (void)launch;
@end
