//
//  AbstractListController.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "AbstractListController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Views/BiometricProtectionOverlayView.h"

@implementation AbstractListController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBiometricProtectionOverlayView:[[BiometricProtectionOverlayView alloc] initWithFrame:[[self view] bounds]]];
    [[self biometricProtectionOverlayView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:[self biometricProtectionOverlayView]];

    if ([self wantsAuth]) {
        [self checkBiometrics];
    } else {
        [self hideBiometricProtectionOverlay];
    }

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

/**
 * Shows the biometric protection overlay when the app resigns active.
 *
 * @param notification
 */
- (void)applicationWillResignActive:(NSNotification *)notification {
    [self showBiometricProtectionOverlay];
}

/**
 * Notes that a biometric protection check should be performed when the app will enter the foreground.
 *
 * @param notification
 */
- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self setWantsAuth:YES];
}

/**
 * Performs a biometric protection check and applies the filter button when the app entered the foreground.
 *
 * @param notification
 */
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if ([self wantsAuth]) {
        [self setWantsAuth:NO];
        [self checkBiometrics];
    } else if (![[self biometricProtectionOverlayView] isHidden]) {
        // UIApplicationWillEnterForegroundNotification is only fired when the app is in the background,
        // which means wantsAuth isn't set to YES when the app is pushed to the app switcher for example.
        // Since the biometric protection overlay is shown when the app resigns active, it needs to be hidden again.
        [self hideBiometricProtectionOverlay];
    }
}

/**
 * Performs a biometric protection check.
 *
 * If access granted, the biometric protection overlay view will be hidden.
 * Else, it'll pop the controller.
 */
- (void)checkBiometrics {
    LAContext* laContext = [[LAContext alloc] init];
    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Vē needs to make sure you're permitted to view the notification logs." reply:^(BOOL success, NSError* _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self hideBiometricProtectionOverlay];
            } else {
                [[self navigationController] popViewControllerAnimated:YES];
            }
        });
    }];
}

/**
 * Shows the biometric protection overlay.
 */
- (void)showBiometricProtectionOverlay {
    [[self biometricProtectionOverlayView] setHidden:NO];
}

/**
 * Hides the biometric protection overlay.
 */
- (void)hideBiometricProtectionOverlay {
    [[self biometricProtectionOverlayView] setHidden:YES];
}
@end
