//
//  VeLogCell.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import "../../../Manager/Log.h"

@interface VeLogCell : PSTableCell
@property(nonatomic)UIImageView* iconImageView;
@property(nonatomic)UILabel* logTitleLabel;
@property(nonatomic)UILabel* logContentLabel;
@property(nonatomic)Log* log;
@end
