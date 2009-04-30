//
//  OSYSync.m
//  objectivesync
//
//  Created by vickeryj on 1/30/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYSync.h"
#import "OSYLog.h"
#import "ObjectiveResource.h"

@interface OSYSync()

-(void)syncCreated;
-(void)syncUpdated;
-(void)syncSaved:(NSArray *)logs;
-(void)syncDeleted;

@end


@implementation OSYSync

-(void)runSync {
	[self syncCreated];
	[self syncUpdated];
	[self syncDeleted];
}

-(void) syncCreated {
	[self syncSaved:[OSYLog newlyCreated]];
}

-(void) syncUpdated {
	[self syncSaved:[OSYLog newlyUpdated]];
}

-(void) syncSaved:(NSArray *)logs {
	for (OSYLog *log in logs) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		if ([obj saveRemote]) {
			[obj saveWithSync:NO];
			[log deleteObject];
		}
	}
}

-(void) syncDeleted {
	NSArray *deleted = [OSYLog newlyDeleted];
	for (OSYLog *log in deleted) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [[[cls alloc] init] autorelease];
		[obj setRemoteId:log.remoteId];
		if ([obj destroyRemote]) {
			[log deleteObject];
		}
	}
}

@end
