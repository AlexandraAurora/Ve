//
//  VeAttachmentListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "../Cells/VeFullAttachmentCell.h"
#import "../../../PrivateHeaders.h"

@interface VeAttachmentListController : PSListController
@property(nonatomic)_UIGrabber* grabber;
@property(nonatomic)UIImage* image;
@end
