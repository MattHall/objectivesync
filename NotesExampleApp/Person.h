//
//  Person.h
//  objectivesync
//
//  Created by Justin Cunningham on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"


@interface Person : SQLitePersistentObject {
	NSString *personId;
	NSString *name;
	NSDate *updatedAt;
	NSDate *createdAt;
}

@property (nonatomic, retain) NSString *personId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;

@end
