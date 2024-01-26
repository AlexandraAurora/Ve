//
//  AbstractSorter.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "SorterProtocol.h"
#import <Preferences/PSSpecifier.h>
#import "../../../../Manager/LogManager.h"
#import "../../../../Manager/Log.h"

@class PSSpecifier;
@class Log;

@interface AbstractSorter : NSObject
@property(nonatomic)id object;
- (instancetype)initWithObject:(id)object;
- (PSSpecifier *)createSpecifierForLog:(Log *)log;
@end
