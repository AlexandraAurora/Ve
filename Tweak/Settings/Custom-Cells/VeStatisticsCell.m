#import "VeStatisticsCell.h"

@implementation VeStatisticsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier { // style the cell

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];


	// separator
	self.separatorView = [UIView new];
	[[self separatorView] setBackgroundColor:[[UIColor labelColor] colorWithAlphaComponent:0.1]];
	[self addSubview:[self separatorView]];

	[[self separatorView] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.separatorView.topAnchor constraintEqualToAnchor:self.topAnchor],
		[self.separatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
		[self.separatorView.heightAnchor constraintEqualToConstant:75],
		[self.separatorView.widthAnchor constraintEqualToConstant:1]
	]];


	// today
	// title label
	self.todayTitleLabel = [UILabel new];
	[[self todayTitleLabel] setText:@"Total of today"];
	[[self todayTitleLabel] setTextColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
	[[self todayTitleLabel] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
	[self addSubview:[self todayTitleLabel]];

	[[self todayTitleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.todayTitleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
		[self.todayTitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
		[self.todayTitleLabel.trailingAnchor constraintEqualToAnchor:self.separatorView.leadingAnchor]
	]];


	// value label
	self.todayValueLabel = [UILabel new];
	if ([specifier.properties[@"todayValue"] isEqualToString:@"1"]) [[self todayValueLabel] setText:[specifier.properties[@"todayValue"] stringByAppendingString:@" Log"]];
	else [[self todayValueLabel] setText:[specifier.properties[@"todayValue"] stringByAppendingString:@" Logs"]];
	[[self todayValueLabel] setTextColor:[UIColor labelColor]];
	[[self todayValueLabel] setFont:[UIFont systemFontOfSize:34 weight:UIFontWeightRegular]];
	[self addSubview:[self todayValueLabel]];

	[[self todayValueLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.todayValueLabel.topAnchor constraintEqualToAnchor:self.todayTitleLabel.bottomAnchor],
		[self.todayValueLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
		[self.todayValueLabel.trailingAnchor constraintEqualToAnchor:self.separatorView.leadingAnchor]
	]];


	// past seven days
	// title label
	self.pastSevenDaysTitleLabel = [UILabel new];
	[[self pastSevenDaysTitleLabel] setText:@"Past seven days"];
	[[self pastSevenDaysTitleLabel] setTextColor:[[UIColor labelColor] colorWithAlphaComponent:0.6]];
	[[self pastSevenDaysTitleLabel] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
	[self addSubview:[self pastSevenDaysTitleLabel]];

	[[self pastSevenDaysTitleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.pastSevenDaysTitleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
		[self.pastSevenDaysTitleLabel.leadingAnchor constraintEqualToAnchor:self.separatorView.trailingAnchor constant:12],
		[self.pastSevenDaysTitleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12]
	]];

	// value label
	self.pastSevenDaysValueLabel = [UILabel new];
	if ([specifier.properties[@"pastSevenDaysValue"] isEqualToString:@"1"]) [[self pastSevenDaysValueLabel] setText:[specifier.properties[@"pastSevenDaysValue"] stringByAppendingString:@" Log"]];
	else [[self pastSevenDaysValueLabel] setText:[specifier.properties[@"pastSevenDaysValue"] stringByAppendingString:@" Logs"]];
	[[self pastSevenDaysValueLabel] setTextColor:[UIColor labelColor]];
	[[self pastSevenDaysValueLabel] setFont:[UIFont systemFontOfSize:34 weight:UIFontWeightRegular]];
	[self addSubview:[self pastSevenDaysValueLabel]];

	[[self pastSevenDaysValueLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.pastSevenDaysValueLabel.topAnchor constraintEqualToAnchor:self.pastSevenDaysTitleLabel.bottomAnchor],
		[self.pastSevenDaysValueLabel.leadingAnchor constraintEqualToAnchor:self.separatorView.trailingAnchor constant:12],
		[self.pastSevenDaysValueLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12]
	]];


	// total stored
	// image view
	self.totalStoredImageView = [UIImageView new];
	[[self totalStoredImageView] setImage:[[UIImage systemImageNamed:@"tray.and.arrow.down.fill"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:17 weight:UIImageSymbolWeightRegular]]];
	[[self totalStoredImageView] setContentMode:UIViewContentModeScaleAspectFit];
	[[self totalStoredImageView] setTintColor:[UIColor labelColor]];
	[self addSubview:[self totalStoredImageView]];

	[[self totalStoredImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.totalStoredImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
		[self.totalStoredImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12],
		[self.totalStoredImageView.heightAnchor constraintEqualToConstant:20],
		[self.totalStoredImageView.widthAnchor constraintEqualToConstant:20]
	]];

	// label
	self.totalStoredLabel = [UILabel new];
	if ([specifier.properties[@"totalStoredValue"] isEqualToString:@"0"]) [[self totalStoredLabel] setText:@"0 logs have been stored in total."];
	else if ([specifier.properties[@"totalStoredValue"] isEqualToString:@"1"]) [[self totalStoredLabel] setText:@"1 log has been stored in total."];
	else [[self totalStoredLabel] setText:[NSString stringWithFormat:@"%@ logs have been stored in total.", specifier.properties[@"totalStoredValue"]]];

	[[self totalStoredLabel] setTextColor:[UIColor labelColor]];
	[[self totalStoredLabel] setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
	[self addSubview:[self totalStoredLabel]];

	[[self totalStoredLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.totalStoredLabel.leadingAnchor constraintEqualToAnchor:self.totalStoredImageView.trailingAnchor constant:4],
		[self.totalStoredLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
		[self.totalStoredLabel.centerYAnchor constraintEqualToAnchor:self.totalStoredImageView.centerYAnchor]
	]];

	// currently stored
	// image view
	self.currentlyStoredImageView = [UIImageView new];
	[[self currentlyStoredImageView] setImage:[[UIImage systemImageNamed:@"tray.and.arrow.down"] imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:17 weight:UIImageSymbolWeightRegular]]];
	[[self currentlyStoredImageView] setContentMode:UIViewContentModeScaleAspectFit];
	[[self currentlyStoredImageView] setTintColor:[UIColor labelColor]];
	[self addSubview:[self currentlyStoredImageView]];

	[[self currentlyStoredImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.currentlyStoredImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
		[self.currentlyStoredImageView.bottomAnchor constraintEqualToAnchor:self.totalStoredImageView.topAnchor],
		[self.currentlyStoredImageView.heightAnchor constraintEqualToConstant:20],
		[self.currentlyStoredImageView.widthAnchor constraintEqualToConstant:20]
	]];

	// label
	self.currentlyStoredLabel = [UILabel new];
	if ([specifier.properties[@"currentlyStoredValue"] isEqualToString:@"0"]) [[self currentlyStoredLabel] setText:@"0 logs are currently stored (0kb)."];
	else if ([specifier.properties[@"currentlyStoredValue"] isEqualToString:@"1"]) [[self currentlyStoredLabel] setText:[NSString stringWithFormat:@"1 log is currently stored (%@).", [NSByteCountFormatter stringFromByteCount:[[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Library/Preferences/love.litten.ve-logs.plist" error:nil] fileSize] countStyle:NSByteCountFormatterCountStyleFile]]];
	else [[self currentlyStoredLabel] setText:[NSString stringWithFormat:@"%@ logs are currently stored (%@).", specifier.properties[@"currentlyStoredValue"], [NSByteCountFormatter stringFromByteCount:[[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Library/Preferences/love.litten.ve-logs.plist" error:nil] fileSize] countStyle:NSByteCountFormatterCountStyleFile]]];
	[[self currentlyStoredLabel] setTextColor:[UIColor labelColor]];
	[[self currentlyStoredLabel] setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
	[self addSubview:[self currentlyStoredLabel]];

	[[self currentlyStoredLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
	[NSLayoutConstraint activateConstraints:@[
		[self.currentlyStoredLabel.leadingAnchor constraintEqualToAnchor:self.currentlyStoredImageView.trailingAnchor constant:4],
		[self.currentlyStoredLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
		[self.currentlyStoredLabel.centerYAnchor constraintEqualToAnchor:self.currentlyStoredImageView.centerYAnchor]
	]];


	return self;

}

@end