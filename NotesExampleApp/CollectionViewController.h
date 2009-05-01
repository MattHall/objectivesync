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

@interface CollectionViewController : UITableViewController <OSYSyncDelegate> {
	NSArray *toolbarItems;
	LoadingView *loadingView;
}

@property (nonatomic, retain) NSArray *toolbarItems;
@property (retain) LoadingView *loadingView;

- (void) loadStarted;
- (void) loadCompleted:(NSNumber *)status;
- (void) loadCollection;
- (void) asyncLoadCollection;
- (NSArray *) setupToolbarItems;

@end
