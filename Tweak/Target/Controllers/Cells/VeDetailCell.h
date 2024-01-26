//
//  VeDetailCell.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Preferences/PSSpecifier.h>

@interface VeDetailCell : PSTableCell
@property(nonatomic)UILabel* detailTitleLabel;
@property(nonatomic)UILabel* detailContentLabel;
@property(nonatomic)NSString* title;
@property(nonatomic)NSString* content;
@end
