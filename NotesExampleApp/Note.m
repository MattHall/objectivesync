//
//  Note.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "Note.h"

@implementation Note

@synthesize noteText, noteId, createdAt, updatedAt;

-(void)merge:(Note *)with {
	self.noteText = with.noteText;
	self.noteId = with.noteId;
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

#pragma mark cleanup
- (void) dealloc
{
	[createdAt release];
	[updatedAt release];
	[noteText release];
	[noteId release];
	[super dealloc];
}


@end
