//
//  Note.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "Note.h"
#import "Person.h"

@implementation Note

@synthesize noteText, noteId, personId, createdAt, updatedAt;

-(void)merge:(Note *)with {
	self.noteText = with.noteText;
	self.createdAt = with.createdAt;
	self.updatedAt = with.updatedAt;
	/*
	 this example merge method essentially just overwrites the local changes
	 with those from the server.  the same could be accomplished without a
	 merge method at all.  in face, if you just want to accept the server changes,
	 you shouldn't implement merge at all.
	 
	 you should perform whatever sort of merge logic you want
	 in this method.
	*/
}

- (SQLitePersistentObject *)parent {
	return [Person findFirstByCriteria:[NSString stringWithFormat:@"WHERE person_id = '%@'", self.personId]];
}

- (NSString *)remoteFindBase {
	return [NSString stringWithFormat:@"%@/%@",self.personId,[Note getRemoteCollectionName]];	
}

- (BOOL)createRemoteWithResponse:(NSError **)aError {
	return [self createRemoteAtPath:[Person getRemoteElementPath:[self nestedPath]] withResponse:aError];
}

- (BOOL)updateRemoteWithResponse:(NSError **)aError {
	return [self updateRemoteAtPath:[Person getRemoteElementPath:[self nestedPath]] withResponse:aError];	
}

- (BOOL)destroyRemoteWithResponse:(NSError **)aError {
	return [self destroyRemoteAtPath:[Person getRemoteElementPath:[self nestedPath]] withResponse:aError];
}

-(NSString *) nestedPath {
	NSString *path = [NSString stringWithFormat:@"%@/%@",self.personId,[[self class] getRemoteCollectionName],nil];
	if(self.noteId) {
		path = [path stringByAppendingFormat:@"/%@",self.noteId,nil];
	}
	return path;
}

#pragma mark cleanup
- (void) dealloc
{
	[createdAt release];
	[updatedAt release];
	[noteText release];
	[noteId release];
	[personId release];
	[super dealloc];
}


@end
