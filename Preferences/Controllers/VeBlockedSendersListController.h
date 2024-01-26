//
//  VeBlockedSendersListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "../../PrivateHeaders.h"

@class PSSpecifier;

NSUserDefaults* preferences;
NSMutableArray* pfBlockedSenders;

@interface VeBlockedSendersListController : PSEditableListController
- (void)removedSpecifier:(PSSpecifier *)specifier;
@end
