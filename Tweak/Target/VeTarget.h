//
//  VeTarget.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import "Controllers/VeLogsListController.h"
#import "../../Preferences/PreferenceKeys.h"
#import "../../Preferences/NotificationKeys.h"

NSUserDefaults* preferences;
BOOL pfEnabled;

@interface PSUIPrefsListController : UIViewController
@end

@interface BulletinBoardController : PSListController
@end
