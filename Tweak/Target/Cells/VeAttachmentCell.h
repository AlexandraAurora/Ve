//
//  VeAttachmentCell.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>

@interface VeAttachmentCell : PSTableCell
@property(nonatomic)UIImageView* attachmentImageView;
@property(nonatomic)UILabel* attachmentTitleLabel;
@property(nonatomic)UILabel* attachmentSizeLabel;
@property(nonatomic)UIImage* image;
@end
