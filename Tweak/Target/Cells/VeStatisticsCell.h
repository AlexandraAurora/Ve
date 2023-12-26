//
//  VeStatisticsCell.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>

@interface VeStatisticsCell : PSTableCell
@property(nonatomic)UILabel* todayTitleLabel;
@property(nonatomic)UILabel* todayValueLabel;
@property(nonatomic)UIView* separatorView;
@property(nonatomic)UILabel* pastSevenDaysTitleLabel;
@property(nonatomic)UILabel* pastSevenDaysValueLabel;
@property(nonatomic)UIImageView* currentlyStoredImageView;
@property(nonatomic)UILabel* currentlyStoredLabel;
@property(nonatomic)UIImageView* totalStoredImageView;
@property(nonatomic)UILabel* totalStoredLabel;
@end
