//
//  OSYDataChangedDelegate.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYDataChangedDelegate.h"
#import "OSYLog.h"
#import "OSYService.h"

@implementation OSYDataChangedDelegate

- (void) objectOfClass:(Class)cls withPk:(int)pk andRemoteId:(NSString *)remoteId was:(ORCActionTypes)action {
	if (![[cls className] isEqualTo:@"OSYLog"]) {
		[OSYLog logAction:action toDBWithClass:cls andRemoteId:remoteId andPk:pk];
		[[OSYService instance] dataChanged];
	}
}

- (void) objectOfClass:(Class)cls withPk:(int)pk andRemoteId:(NSString *)remoteId andParent:(id)parent was:(ORCActionTypes)action {
	if (![[cls className] isEqualTo:@"OSYLog"]) {
		[OSYLog logAction:action toDBWithClass:cls andRemoteId:remoteId andPk:pk 
			  andParentId:[parent getRemoteId] 
		      andParentClass:[parent className]];
		[[OSYService instance] dataChanged];
	}
}

@end
