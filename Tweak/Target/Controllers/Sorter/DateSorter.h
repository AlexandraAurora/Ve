//
//  DateSorter.h
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "AbstractSorter.h"

static NSString* dateFormat = @"dd.MM.yyyy";

NSUserDefaults* preferences;
BOOL pfUseAmericanDateFormat;

@interface DateSorter : AbstractSorter <SorterProtocol>
@end
