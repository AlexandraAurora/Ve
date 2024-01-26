//
//  VeLogCell.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Preferences/PSSpecifier.h>

@class Log;

@interface VeLogCell : PSTableCell
@property(nonatomic)UIImageView* iconImageView;
@property(nonatomic)UILabel* logTitleLabel;
@property(nonatomic)UILabel* logContentLabel;
@property(nonatomic)Log* log;
@end
