//
//  Person.m
//  objectivesync
//
//  Created by Justin Cunningham on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Person.h"


@implementation Person
@synthesize personId, name, createdAt, updatedAt;

+ (NSString *)getRemoteCollectionName {
	return @"people";
}

- (void) dealloc
{
	[createdAt release];
	[updatedAt release];
	[personId release];
	[name release];
	[super dealloc];
}

@end
