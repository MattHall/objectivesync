//
//  OSYSync.m
//  objectivesync
//
//  Created by vickeryj on 1/30/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYSync.h"
#import "OSYSyncDelegate.h"
#import "OSYLog.h"
#import "ObjectiveResource.h"
#import "SQLitePersistentObject.h"

@interface OSYSync()

-(BOOL)syncCreated;
-(BOOL)syncUpdated;
-(BOOL)syncDeleted;

@end


@implementation OSYSync

-(BOOL)syncNeeded {
	return ([[OSYLog newlyCreated] count] > 0 ||
			[[OSYLog newlyUpdated] count] > 0 ||
			[[OSYLog newlyDeleted] count] > 0);
}

-(BOOL)runSync {
	return ([self syncCreated] && 
			[self syncUpdated] &&
			[self syncDeleted]);
}

-(BOOL) syncCreated {
	NSArray *logs = [OSYLog newlyCreated];
	for (OSYLog *log in logs) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		if ([obj saveRemote]) {
			[obj saveWithSync:NO];
			[log deleteObject];
		} else {
			return NO;
		}
	}
	return YES;
}

-(BOOL) syncUpdated {
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
		} else if (error.code == 0 || (error.code >= 200 && error.code < 400)) {
			if ([cls instancesRespondToSelector:@selector(updatedAt)]&&
				[[obj performSelector:@selector(updatedAt)] isEqualToDate: [remoteObj performSelector:@selector(updatedAt)]]) {
				// updatedAt exists, and the object on the server hasn't been updated since it was edited on the phone
				if ([obj saveRemote]) {
					[obj saveWithSync:NO];
					[log deleteObject];
				} else {
					return NO;
				}
			} else {
				if ([cls instancesRespondToSelector:@selector(merge:)]) {
					// if the merge function exists, try to merge the two objects and save that
					[obj performSelector:@selector(merge:) withObject:remoteObj];
					if ([obj saveRemote]) {
						[obj saveWithSync:NO];
						[log deleteObject];
					} else {
						return NO;
					}
				} else {
					// it's been updated, and we can't merge, so trash the log and update the object
					[(SQLitePersistentObject *)remoteObj setPk:[obj pk]];
					[remoteObj saveWithSync:NO]; // replaces the local obj with remoteObj in DB
					[log deleteObject];
				}
			}
		} else {
			return NO;
		}
	}
	return YES;
}

-(BOOL) syncDeleted {
	NSArray *deleted = [OSYLog newlyDeleted];
	for (OSYLog *log in deleted) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [[[cls alloc] init] autorelease];
		[obj setRemoteId:log.remoteId];
		
		// we need to set this information so that we can properly handle nested deletes
		if (log.parentFieldName != nil) {
			SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@Id:",log.parentFieldName]);
			[obj performSelector:setter withObject:log.parentId];
		}
		
		if ([obj destroyRemote]) {
			[log deleteObject];
		} else {
			return NO;
		}
	}
	return YES;
}

-(BOOL)runCollectionSyncWithDelegate:(NSObject<OSYSyncDelegate> *)delegate {
	NSError *error = [[[NSError alloc] init] autorelease];
	
	NSArray *local = [delegate collectionFromSQL];
	NSArray *remote = [delegate collectionFromRemoteWithResponse:&error];
	
	if (error.code == 0 || (error.code >= 200 && error.code < 400) && ![self syncNeeded]) {
		
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
		
		return YES;
	} else {
		return NO;
	}
}

@end
