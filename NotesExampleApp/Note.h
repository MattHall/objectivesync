//
//  Note.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"
#import "ObjectiveResource.h"

@interface Note : SQLitePersistentObject {

	NSString *noteText;
	NSString *noteId;
	NSString *personId;
	NSDate *updatedAt;
	NSDate *createdAt;
	
}

@property(nonatomic, retain) NSString *noteText;
@property(nonatomic, retain) NSString *noteId;
@property(nonatomic, retain) NSString *personId;
@property(nonatomic, retain) NSDate *createdAt;
@property(nonatomic, retain) NSDate *updatedAt;

-(void)merge:(Note *)with;
-(NSString *) nestedPath;

@end
