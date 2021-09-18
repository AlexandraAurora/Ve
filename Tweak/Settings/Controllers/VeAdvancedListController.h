#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "VePreferencesListController.h"
#import "VeBlockedBundleIdentifiersListController.h"
#import "VeExcludedPhrasesListController.h"
#import "../PrivateHeaders.h"
#import <Cephei/HBPreferences.h>

@interface VeAdvancedListController : PSListController
@property(nonatomic, retain)HBPreferences* logs;
- (void)deleteLogByIdentifier;
- (void)deleteLogsWithBundleIdentifier;
- (void)deleteLogWithProvidedBundleIdentifier:(NSString *)bundleIdentifier;
- (void)deleteLogsInRange;
- (void)deleteLogInRange:(int)start end:(int)end;
- (void)deleteAllLogs;
@end