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
	/*
	 this method is used by the sync service to determine what parent information should be saved in the
	 event log so that the record can be deleted if it is nested.  In the event you have a polymorphic design,
	 where the object could potentially have any number of parents, you'll have to add your own logic here
	 so that the sync service will know which parent to use.
	 
	 E.G. In order to delete the note with ID 1, that belongs to parent 4, a delete request would have to be
	 sent to http://host/people/4/notes/1.xml.  Since the object is destroyed locally and then logged,
	 we need to make the parent available to the sync service so that it can track the parentId or 4,
	 along with the remoteId of the record.
	 
	 This method should only be implemented if the model is nested.
	 */
}

- (NSString *)remoteFindBase {
	return [NSString stringWithFormat:@"%@/%@",self.personId,[Note getRemoteCollectionName]];	
}

/*
 You'll want to override the below methods for nested models so that create, update, and delete are
 handled correctly based on your nesting model.  This allows the sync service to be relatively clueless
 about how you have things laid out on the server side.
 
 For delete to function, the above parent method must be set as well, so the parent ID and class name
 will be logged after the record is destroyed locally.
 */

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
