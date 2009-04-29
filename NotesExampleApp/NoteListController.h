//
//  NoteListController.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSYSyncDelegate.h"
#import "CollectionViewController.h"

@interface NoteListController : CollectionViewController <OSYSyncDelegate> {
	NSMutableArray *notes;
}

@property(nonatomic, retain) NSMutableArray *notes;

@end
