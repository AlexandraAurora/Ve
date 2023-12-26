//
//  VeDetailListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../../../Manager/LogManager.h"
#import "VeAttachmentListController.h"
#import "../Cells/VeDetailCell.h"
#import "../Cells/VeAttachmentCell.h"

NSUserDefaults* preferences;
NSMutableArray* pfBlockedSenders;

@interface VeDetailListController : PSListController
@property(nonatomic)UIButton* removeButton;
@property(nonatomic)UIBarButtonItem* item;
@property(nonatomic)Log* log;
@end
