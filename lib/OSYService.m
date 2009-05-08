//
//  OSYService.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYService.h"
#import "OSYDataChangedDelegate.h"
#import "SQLitePersistentObject.h"
#import "OSYSync.h"


static OSYService *__instance;

@implementation OSYService

@synthesize delegate, retries;

+(void)setupWithSyncDelegate:(NSObject<OSYSyncDelegate> *)delegate {
	__instance = [[OSYService alloc] init];
	[__instance setDelegate:delegate];
	__instance.retries = 3;
	OSYDataChangedDelegate *dataChanged = [[OSYDataChangedDelegate alloc] init];
	[SQLitePersistentObject setDataChangedDelegate:dataChanged];
}

+(OSYService *)instance {
	return __instance;
}


-(void)dataChanged {
	NSLog(@"data changed");
	
	//basic, sync immediately strategy
	//OSYSync *sync = [[[OSYSync alloc] init] autorelease];
	//[delegate syncCompleteWithSuccess:[sync runSync]];
	
	// don't sync immediately, just log so we can perform the delete on next server refresh
}

-(BOOL)runCollectionSync {
	NSObject *tmpDelegate = self.delegate;
	OSYSync *sync = [[[OSYSync alloc] init] autorelease];
	
	// try to sync, and keep trying till we run out of retries
	int count = 0;
	while (count < self.retries && [sync syncNeeded]) {
		[sync runSync];
		count++;
	}
	
	// sync the local db with the remote db
	if (![sync syncNeeded]) {
		return [sync runCollectionSyncWithDelegate:tmpDelegate];
	} else {
		return NO;
	}
}

#pragma mark cleanup
- (void) dealloc
{
	[delegate release];
	[super dealloc];
}


@end
