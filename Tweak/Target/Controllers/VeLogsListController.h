//
//  VeLogsListController.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "AbstractListController.h"

NSUserDefaults* preferences;
NSString* pfSorting;

@interface VeLogsListController : AbstractListController <UISearchBarDelegate>
@property(nonatomic)UIButton* filterButton;
@property(nonatomic)UIBarButtonItem* item;
@property(nonatomic)UIRefreshControl* pullToRefreshControl;
@property(nonatomic)UISearchController* searchController;
@end
