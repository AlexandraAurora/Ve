#import "VeSpringBoard.h"

%group Ve

%hook BBServer

- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2 { // catch incoming notifications

	%orig;

	if (isLoggingTemporarilyDisabled) return;

	BBBulletin* bulletin = arg1;
	HBPreferences* logs = [[HBPreferences alloc] initWithIdentifier:@"love.litten.ve-logs"];

	// return if the notification comes from a blocked bundle identifier or contains an excluded phrase
	NSArray* blockedBundleIdentifiers = [logs objectForKey:@"blockedBundleIdentifiers"];
	NSArray* excludedPhrases = [logs objectForKey:@"excludedPhrases"];
	if ([blockedBundleIdentifiers count] > 0 || [excludedPhrases count] > 0) {
		if ([blockedBundleIdentifiers containsObject:[arg1 sectionID]]) return;

		for (NSString* phrase in excludedPhrases) {
			if ([[bulletin title] localizedCaseInsensitiveContainsString:phrase] || [[bulletin message] localizedCaseInsensitiveContainsString:phrase]) return;
		}
	}

	if ([bulletin sectionID] && [bulletin title]) { // save the incoming notification and its details
		// add all attachments as data to an array
		NSURL* attachmentsURL = [[[bulletin primaryAttachment] URL] URLByDeletingLastPathComponent];
		NSString* attachmentsDirectoryPath = [[attachmentsURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
		NSArray* attachmentsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:attachmentsDirectoryPath error:nil];
		NSMutableArray* attachments = [NSMutableArray new];
		for (int i = 0; i < [attachmentsDirectory count]; i++) {
			NSData* imageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", attachmentsDirectoryPath, [attachmentsDirectory objectAtIndex:i]]], 1);
			if (imageData) [attachments addObject:imageData];
		}

		// save all details
		NSMutableArray* newLogs = [NSMutableArray new];
		[newLogs addObject:@{
			@"identifier" : [NSNumber numberWithUnsignedInteger:(NSUInteger)[[logs objectForKey:@"lastHighestID"] intValue] + 1],
			@"bundleID" : [bulletin sectionID] ?: @"",
			@"displayName" : [[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:[bulletin sectionID]] displayName] ?: @"",
			@"title" : [bulletin title] ?: @"",
			@"message" : [bulletin message] ?: @"",
			@"attachments" : attachments ?: @"",
			@"date" : [NSDate date] ?: @""
		}];
		[newLogs addObjectsFromArray:[logs objectForKey:@"loggedNotifications"]]; // add all other stored logs

		if (entryLimitValue > 1 && [newLogs count] >= entryLimitValue) { // delete all logs that are above the entry limit, if one is set
			while ([newLogs count] > entryLimitValue) {
				[newLogs removeLastObject];
			}
		}

		[logs setObject:newLogs forKey:@"loggedNotifications"];

		NSUInteger totalLoggedNotificationCount = [[logs objectForKey:@"totalLoggedNotificationCount"] intValue];
		NSUInteger lastHighestID = [[logs objectForKey:@"lastHighestID"] intValue];
		[logs setUnsignedInteger:totalLoggedNotificationCount += 1  forKey:@"totalLoggedNotificationCount"];
		[logs setUnsignedInteger:lastHighestID += 1  forKey:@"lastHighestID"];
	}


	// delete entries that are older than 30 days
	if (deleteIfOlderThan30DaysSwitch) {
		if (![[NSCalendar currentCalendar] isDateInToday:[logs objectForKey:@"lastHouseholdDate"]] || ![logs objectForKey:@"lastHouseholdDate"]) { // only do this once a day (or if it's the first time ever), unless no notification comes in that day, then don't
			[logs setObject:[NSDate date] forKey:@"lastHouseholdDate"];
			NSMutableArray* currentlyStoredLogs = [[logs objectForKey:@"loggedNotifications"] mutableCopy];

			// this part runs on the background thread in case there's a ton of logged notifications that need to be looped trough
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
			dispatch_async(queue, ^{
				for (int i = 0; i < [currentlyStoredLogs count]; i++) {
					NSDictionary* log = [currentlyStoredLogs objectAtIndex:i];
					NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
					NSDateComponents* components = [calendar components:NSCalendarUnitDay fromDate:[log objectForKey:@"date"] toDate:[NSDate date] options:0];

					if ([components day] > 30) [currentlyStoredLogs removeObjectAtIndex:i];
				}

				[logs setObject:currentlyStoredLogs forKey:@"loggedNotifications"];
			});
		}
	}

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.vepreferences"];

	[preferences registerBool:&enabled default:NO forKey:@"Enabled"];
	if (!enabled) return;

	// household
	[preferences registerUnsignedInteger:&entryLimitValue default:1 forKey:@"entryLimit"];
	[preferences registerBool:&deleteIfOlderThan30DaysSwitch default:YES forKey:@"deleteIfOlderThan30Days"];

	// control center toggle
	[preferences registerBool:&isLoggingTemporarilyDisabled default:NO forKey:@"isLoggingTemporarilyDisabled"];

	%init(Ve);

}