//
//  BiometricProtectionOverlayView.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "BiometricProtectionOverlayView.h"

@implementation BiometricProtectionOverlayView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setBackgroundColor:[UIColor systemBackgroundColor]];

        [self setIconImageView:[[UIImageView alloc] init]];

        UIImageSymbolConfiguration* configuration = [UIImageSymbolConfiguration configurationWithPointSize:138 weight:UIImageSymbolWeightRegular];
        [[self iconImageView] setImage:[[UIImage systemImageNamed:@"lock.fill"] imageWithConfiguration:configuration]];

        [[self iconImageView] setTintColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
        [[self iconImageView] setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:[self iconImageView]];

        [[self iconImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self iconImageView] centerXAnchor] constraintEqualToAnchor:[self centerXAnchor]],
			[[[self iconImageView] centerYAnchor] constraintEqualToAnchor:[self centerYAnchor] constant:-26]
		]];

        [self setLabel:[[UILabel alloc] init]];
        [[self label] setText:@"Notification Logs\nAre Locked"];
        [[self label] setTextColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
        [[self label] setFont:[UIFont systemFontOfSize:28 weight:UIFontWeightRegular]];
        [[self label] setTextAlignment:NSTextAlignmentCenter];
        [[self label] setNumberOfLines:2];
        [self addSubview:[self label]];

        [[self label] setTranslatesAutoresizingMaskIntoConstraints:NO];
		[NSLayoutConstraint activateConstraints:@[
			[[[self label] centerXAnchor] constraintEqualToAnchor:[self centerXAnchor]],
            [[[self label] topAnchor] constraintEqualToAnchor:[[self iconImageView] bottomAnchor]]
		]];
    }

    return self;
}
@end
