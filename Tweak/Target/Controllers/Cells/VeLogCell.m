//
//  VeLogCell.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeLogCell.h"
#import "../../../../Manager/Log.h"
#import "../../../../PrivateHeaders.h"

@implementation VeLogCell
/**
 * Initializes the log cell.
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
		[self setLog:[specifier propertyForKey:@"log"]];

		[self setIconImageView:[[UIImageView alloc] init]];
		[[self iconImageView] setImage:[UIImage _applicationIconImageForBundleIdentifier:[[self log] bundleIdentifier] format:1 scale:2]];
		[[self iconImageView] setContentMode:UIViewContentModeScaleAspectFit];
		[[self iconImageView] setClipsToBounds:YES];
		[[[self iconImageView] layer] setCornerRadius:7];
		[[[self iconImageView] layer] setBorderWidth:0.5];
		[[[self iconImageView] layer] setBorderColor:[[[UIColor labelColor] colorWithAlphaComponent:0.1] CGColor]];
		[self addSubview:[self iconImageView]];

		[[self iconImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self iconImageView] leadingAnchor] constraintEqualToAnchor:[self leadingAnchor] constant:16],
			[[[self iconImageView] centerYAnchor] constraintEqualToAnchor:[self centerYAnchor]],
			[[[self iconImageView] heightAnchor] constraintEqualToConstant:30],
			[[[self iconImageView] widthAnchor] constraintEqualToConstant:30]
		]];

		[self setLogTitleLabel:[[UILabel alloc] init]];
		NSString* title = [[[self log] title] isEqualToString:@""] ? [[self log] getDisplayName] : [[self log] title];
		[[self logTitleLabel] setText:title];
		[[self logTitleLabel] setTextColor:[UIColor labelColor]];
		[[self logTitleLabel] setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
		[self addSubview:[self logTitleLabel]];

		[[self logTitleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self logTitleLabel] topAnchor] constraintEqualToAnchor:[self topAnchor] constant:10],
			[[[self logTitleLabel] leadingAnchor] constraintEqualToAnchor:[[self iconImageView] trailingAnchor] constant:10],
			[[[self logTitleLabel] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-32]
		]];

		[self setLogContentLabel:[[UILabel alloc] init]];
		NSString* content = [[[self log] content] isEqualToString:@""] ? @"N/A" : [[self log] content];
		[[self logContentLabel] setText:content];
		[[self logContentLabel] setTextColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
		[[self logContentLabel] setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightRegular]];
		[self addSubview:[self logContentLabel]];

		[[self logContentLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self logContentLabel] topAnchor] constraintEqualToAnchor:[[self logTitleLabel] bottomAnchor] constant:2],
			[[[self logContentLabel] leadingAnchor] constraintEqualToAnchor:[[self iconImageView] trailingAnchor] constant:10],
			[[[self logContentLabel] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-32]
		]];
	}

	return self;
}
@end
