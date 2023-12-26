//
//  VeBlockedSendersListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../../Manager/LogManager.h"

NSUserDefaults* preferences;
NSMutableArray* pfBlockedSenders;

@interface VeBlockedSendersListController : PSEditableListController
- (void)removedSpecifier:(PSSpecifier *)specifier;
@end
