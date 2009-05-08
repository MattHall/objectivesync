//
//  OSYLog.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYLog.h"
#import "ORCDataChangedDelegate.h"

@interface OSYLog()

+(NSArray *)findByAction:(ORCActionTypes)action;

@end


@implementation OSYLog

@synthesize loggedClassName, loggedPk, loggedAction, loggedAt, remoteId, parentId, parentFieldName;

+(NSArray *)findByAction:(ORCActionTypes)action {
	return [self findByCriteria:[NSString stringWithFormat:@"WHERE logged_action=%d",action]];
}

+(NSArray *)newlyCreated {
	return [self findByAction:CreatedAction];
}
+(NSArray *)newlyUpdated {
	return [self findByAction:UpdatedAction];
}
+(NSArray *)newlyDeleted {
	return [self findByAction:DeletedAction];
}

+(void) logAction:(ORCActionTypes)action toDBWithClass:(Class)loggedClass 
	  andRemoteId:(NSString *)loggedRemoteId andPk:(int)loggedPk 

{
	[self logAction:action toDBWithClass:loggedClass andRemoteId:loggedRemoteId andPk:loggedPk
		andParentId:nil andParentClass:nil];
}

+(void) logAction:(ORCActionTypes)action toDBWithClass:(Class)loggedClass 
	  andRemoteId:(NSString *)loggedRemoteId andPk:(int)loggedPk andParentId:(NSString *)loggedParentId
	  andParentClass:(NSString *)loggedParentFieldName
{
	OSYLog *log = [[[OSYLog alloc] init] autorelease];
	log.loggedAction = action;
	log.loggedClassName = [loggedClass className];
	log.loggedPk = loggedPk;
	log.loggedAt = [NSDate date];
	log.parentId = loggedParentId;
	log.parentFieldName = loggedParentFieldName;
	log.remoteId = loggedRemoteId;
	[log save];
}


#pragma mark cleanup
- (void) dealloc
{
	[loggedClassName release];
	[loggedAt release];
	[remoteId release];
	[parentId release];
	[parentFieldName release];
	[super dealloc];
}


@end
