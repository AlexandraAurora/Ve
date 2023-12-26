//
//  VeFullAttachmentCell.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "VeFullAttachmentCell.h"

@implementation VeFullAttachmentCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[self setImage:[specifier propertyForKey:@"image"]];

		// attachment
		[self setAttachmentImageView:[[UIImageView alloc] init]];
		[[self attachmentImageView] setImage:[self image]];
		[[self attachmentImageView] setContentMode:UIViewContentModeScaleAspectFill];
		[self addSubview:[self attachmentImageView]];

		[[self attachmentImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self attachmentImageView] topAnchor] constraintEqualToAnchor:[self topAnchor]],
			[[[self attachmentImageView] leadingAnchor] constraintEqualToAnchor:[self leadingAnchor]],
			[[[self attachmentImageView] trailingAnchor] constraintEqualToAnchor:[self trailingAnchor]],
			[[[self attachmentImageView] bottomAnchor] constraintEqualToAnchor:[self bottomAnchor]]
		]];
	}

	return self;
}
@end
