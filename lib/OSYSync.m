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
#import "SQLitePersistentObject.h"

@interface OSYSync()

-(void)syncCreated;
-(void)syncUpdated;
-(void)syncDeleted;

@end


@implementation OSYSync

-(void)runSync {
	[self syncCreated];
	[self syncUpdated];
	[self syncDeleted];
}

-(void) syncCreated {
	NSArray *logs = [OSYLog newlyCreated];
	for (OSYLog *log in logs) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		if ([obj saveRemote]) {
			[obj saveWithSync:NO];
			[log deleteObject];
		}
	}
}

-(void) syncUpdated {
	NSError *error = [[[NSError alloc] init] autorelease];
	NSArray *logs = [OSYLog newlyUpdated];
	for (OSYLog *log in logs) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		id remoteObj;
		if ([cls instancesRespondToSelector:@selector(parent)]) {
			remoteObj = [cls findRemote:[obj getRemoteId] withResponse:&error andParent:[obj parent]];
		} else {
			remoteObj = [cls findRemote:[obj getRemoteId] withResponse:&error];
		}
		
		if (error.code == 404) {
			// If you ever try to update a record after it's been dropped into a river of molten lava, let 'em go, because man, they're gone.
			[obj deleteObjectWithSync:NO];
			[log deleteObject];
		} else {
			if ([cls instancesRespondToSelector:@selector(updatedAt)]&&
				[[obj performSelector:@selector(updatedAt)] isEqualToDate: [remoteObj performSelector:@selector(updatedAt)]]) {
				// updatedAt exists, and the object on the server hasn't been updated since it was edited on the phone
				if ([obj saveRemote]) {
					[obj saveWithSync:NO];
					[log deleteObject];
				}
			} else {
				if ([cls instancesRespondToSelector:@selector(merge:)]) {
					// if the merge function exists, try to merge the two objects and save that
					[obj performSelector:@selector(merge:) withObject:remoteObj];
					if ([obj saveRemote]) {
						[obj saveWithSync:NO];
						[log deleteObject];
					}
				} else {
					// it's been updated, and we can't merge, so trash the log and update the object
					[(SQLitePersistentObject *)remoteObj setPk:[obj pk]];
					[remoteObj saveWithSync:NO]; // replaces the local obj with remoteObj in DB
					[log deleteObject];
				}
			}
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

-(NSMutableArray *)runCollectionSyncWithLocal:(NSArray *)local andRemote:(NSArray *)remote withError:(NSError *)error status:(NSNumber **)status {
	if (error.code == 0 || (error.code >= 200 && error.code < 400)) {
		NSMutableArray *newCollection = [[NSMutableArray alloc] initWithCapacity:[remote count]];
		
		// this could probably be faster, but at least it's clean
		NSMutableDictionary *localDictionary = [[NSMutableDictionary alloc] initWithCapacity:[local count]];
		NSMutableDictionary *remoteDictionary = [[NSMutableDictionary alloc] initWithCapacity:[remote count]];
		
		for (SQLitePersistentObject *obj in local) [localDictionary setObject:obj forKey:[obj getRemoteId]];
		for (SQLitePersistentObject *obj in remote) [remoteDictionary setObject:obj forKey:[obj getRemoteId]];

		// remove objects that don't exist on server
		NSMutableArray *keysNotOnServer = [NSMutableArray arrayWithArray:[localDictionary allKeys]];
		[keysNotOnServer removeObjectsInArray:[remoteDictionary allKeys]];
		for (NSString *key in keysNotOnServer) [[localDictionary objectForKey:key] deleteObjectWithSync:NO];
		[localDictionary removeObjectsForKeys:keysNotOnServer];
		
		// add objects that have been added on server
		NSMutableArray *keysOnlyOnServer = [NSMutableArray arrayWithArray:[remoteDictionary allKeys]];
		[keysOnlyOnServer removeObjectsInArray:[localDictionary allKeys]];
		for (NSString *key in keysOnlyOnServer) {
			[[remoteDictionary objectForKey:key] saveWithSync:NO];
			[localDictionary setObject:[remoteDictionary objectForKey:key] forKey:key];
		}
		for (id key in localDictionary) {
			[newCollection addObject:[localDictionary objectForKey:key]];
		}
		
		// change objects that have been changed on server
		NSMutableArray *keysOnServerAndClient = [NSMutableArray arrayWithArray:[localDictionary allKeys]];
		[keysOnServerAndClient removeObjectsInArray:keysOnlyOnServer];
		for (NSString *key in keysOnServerAndClient) {
			SQLitePersistentObject *localObject = [localDictionary objectForKey:key];
			SQLitePersistentObject *remoteObject = [remoteDictionary objectForKey:key];
			[remoteObject setPk:localObject.pk];
			[remoteObject saveWithSync:NO];
		}
		
		
		[localDictionary release];
		[remoteDictionary release];
		
		*status = [NSNumber numberWithBool:YES]; 
		
		return newCollection;
	} else {
		*status = [NSNumber numberWithBool:NO]; 
		
		return [NSMutableArray arrayWithArray:local];
	}
}

@end
