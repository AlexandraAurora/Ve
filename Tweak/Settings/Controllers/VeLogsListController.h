#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "../Custom-Cells/VeStatisticsCell.h"
#import "../Custom-Cells/VeNotificationCell.h"
#import "VeAdvancedListController.h"
#import "VeDetailViewListController.h"
#import <Cephei/HBPreferences.h>

@interface VeLogsListController : PSListController <UISearchBarDelegate>
@property(nonatomic, retain)HBPreferences* preferences;
@property(nonatomic, retain)UIButton* settingsButton;
@property(nonatomic, retain)UIBarButtonItem* item;
@property(nonatomic, retain)UIRefreshControl* pullToRefreshControl;
- (void)presentAdvancedController;
- (void)pullToRefresh;
- (void)expandLog:(PSSpecifier *)specifier;
@end