#import "VeToggle.h"

// control center toggle
BOOL isLoggingTemporarilyDisabled = NO;

// protection
BOOL biometricProtectionSwitch = NO;

@implementation VeToggle

- (id)init { // register the preferences

    self = [super init];

    self.preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.vepreferences"];
    [[self preferences] registerBool:&isLoggingTemporarilyDisabled default:NO forKey:@"isLoggingTemporarilyDisabled"];
    [[self preferences] registerBool:&biometricProtectionSwitch default:NO forKey:@"biometricProtection"];

    return self;

}

- (UIImage *)iconGlyph { // set the icon

    return [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];

}

- (UIColor *)selectedColor { // set the selectec color

    return [UIColor colorWithRed:0.58 green:0.45 blue:0.94 alpha:1];

}

- (BOOL)isSelected { // check if the toggle is selected

    return isLoggingTemporarilyDisabled;

}

- (void)setSelected:(BOOL)selected { // do something when the toggle was selected

    if (biometricProtectionSwitch) {
        LAContext* laContext = [LAContext new];
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Vé needs to make sure that you are permitted to take this action." reply:^(BOOL success, NSError* _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [[self preferences] setBool:![self isSelected] forKey:@"isLoggingTemporarilyDisabled"];
                    [super refreshState];
                    [self iconGlyph];
                }
            });
        }];
    } else {
        [[self preferences] setBool:![self isSelected] forKey:@"isLoggingTemporarilyDisabled"];
        [self iconGlyph];
    }

}

@end
