//
//  AbstractListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "../../../PrivateHeaders.h"

@class BiometricProtectionOverlayView;

@interface AbstractListController : PSEditableListController
@property(nonatomic)BOOL wantsAuth;
@property(nonatomic)BiometricProtectionOverlayView* biometricProtectionOverlayView;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
@end
