//
//  CollectionViewController.h
//  BulletproofTiger
//
//  Created by Justin Cunningham on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSYSyncDelegate.h"
#import "LoadingView.h"
#import "SQLitePersistentObject.h"

@interface CollectionViewController : UITableViewController <OSYSyncDelegate> {
	NSArray *toolbarItems;
	LoadingView *loadingView;
	NSMutableArray *collection;
	SQLitePersistentObject *parent;
}

@property (nonatomic, retain) NSArray *toolbarItems;
@property (retain) LoadingView *loadingView;
@property (nonatomic, retain) NSMutableArray *collection;
@property (nonatomic, retain) SQLitePersistentObject *parent;

- (void) loadStarted;
- (void) loadCompleted:(NSNumber *)status;
- (void) loadCollection;
- (void) asyncLoadCollection;
- (NSArray *) setupToolbarItems;
- (Class) classRepresented;

@end
