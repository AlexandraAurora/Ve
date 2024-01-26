//
//  VeDetailCell.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeDetailCell.h"
#import "../../../../PrivateHeaders.h"

@implementation VeDetailCell
/**
 * Initializes the detail cell.
 *
 * @param style
 * @param reuseIdentifier
 * @param specifier
 *
 * @return The cell.
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[self setTitle:[specifier propertyForKey:@"title"]];
		[self setContent:[specifier propertyForKey:@"content"]];

		[self setDetailContentLabel:[[UILabel alloc] init]];
		[[self detailContentLabel] setText:[self content]];
		[[self detailContentLabel] setTextColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
		[[self detailContentLabel] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
		[[self detailContentLabel] setTextAlignment:NSTextAlignmentRight];
		[[self detailContentLabel] setMarqueeEnabled:YES];
		[[self detailContentLabel] setMarqueeRunning:YES];
		[self addSubview:[self detailContentLabel]];

		[[self detailContentLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self detailContentLabel] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-16],
			[[[self detailContentLabel] centerYAnchor] constraintEqualToAnchor:[self centerYAnchor]]
		]];

		[self setDetailTitleLabel:[[UILabel alloc] init]];
		[[self detailTitleLabel] setText:[self title]];
		[[self detailTitleLabel] setTextColor:[UIColor labelColor]];
		[[self detailTitleLabel] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium]];
		[self addSubview:[self detailTitleLabel]];

		[[self detailTitleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self detailTitleLabel] trailingAnchor] constraintEqualToAnchor:[[self detailContentLabel] leadingAnchor] constant:-8],
			[[[self detailTitleLabel] leadingAnchor] constraintEqualToAnchor:[self leadingAnchor] constant:16],
			[[[self detailTitleLabel] centerYAnchor] constraintEqualToAnchor:[self centerYAnchor]]
		]];
	}

	return self;
}
@end
