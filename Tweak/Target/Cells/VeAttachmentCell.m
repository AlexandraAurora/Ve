//
//  VeAttachmentCell.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeAttachmentCell.h"

@implementation VeAttachmentCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[self setImage:[specifier propertyForKey:@"image"]];


		// image view
		[self setAttachmentImageView:[[UIImageView alloc] init]];
		[[self attachmentImageView] setImage:[self image]];
		[[self attachmentImageView] setContentMode:UIViewContentModeScaleAspectFill];
		[[self attachmentImageView] setClipsToBounds:YES];
		[[[self attachmentImageView] layer] setCornerRadius:6];
		[self addSubview:[self attachmentImageView]];

		[[self attachmentImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self attachmentImageView] topAnchor] constraintEqualToAnchor:[self topAnchor] constant:8],
			[[[self attachmentImageView] leadingAnchor] constraintEqualToAnchor:[self leadingAnchor] constant:8],
			[[[self attachmentImageView] bottomAnchor] constraintEqualToAnchor:[self bottomAnchor] constant:-8],
			[[[self attachmentImageView] widthAnchor] constraintEqualToConstant:90]
		]];


		// title label
		[self setAttachmentTitleLabel:[[UILabel alloc] init]];
		[[self attachmentTitleLabel] setText:@"Image"];
		[[self attachmentTitleLabel] setTextColor:[UIColor labelColor]];
		[[self attachmentTitleLabel] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium]];
		[self addSubview:[self attachmentTitleLabel]];

		[[self attachmentTitleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self attachmentTitleLabel] leadingAnchor] constraintEqualToAnchor:[[self attachmentImageView] trailingAnchor] constant:12],
			[[[self attachmentTitleLabel] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-16],
			[[[self attachmentTitleLabel] centerYAnchor] constraintEqualToAnchor:[[self attachmentImageView] centerYAnchor] constant:-11]
		]];


		// size label
		[self setAttachmentSizeLabel:[[UILabel alloc] init]];
		[[self attachmentSizeLabel] setText:[NSString stringWithFormat:@"Width: %.0fpx Height: %.0fpx", [self image].size.width, [self image].size.height]];
		[[self attachmentSizeLabel] setTextColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
		[[self attachmentSizeLabel] setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightRegular]];
		[self addSubview:[self attachmentSizeLabel]];

		[[self attachmentSizeLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self attachmentSizeLabel] leadingAnchor] constraintEqualToAnchor:[[self attachmentImageView] trailingAnchor] constant:12],
			[[[self attachmentSizeLabel] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-16],
			[[[self attachmentSizeLabel] centerYAnchor] constraintEqualToAnchor:[[self attachmentImageView] centerYAnchor] constant:11]
		]];
	}

	return self;
}
@end
