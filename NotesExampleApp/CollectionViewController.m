//
//  CollectionViewController.m
//  BulletproofTiger
//
//  Created by Justin Cunningham on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CollectionViewController.h"
#import "ConnectionManager.h"
#import "SQLitePersistentObject.h"
#import "OSYSync.h"
#import "OSYService.h"
#import "ObjectiveSupport.h"


@implementation CollectionViewController
@synthesize toolbarItems, loadingView, collection, parent;

- (void) loadStarted {
	[self.loadingView startAnimating];
}

- (void) loadCompleted:(NSNumber *)status {
	[self.loadingView stopAnimating:status];
}

- (void) loadCollection {
	[self loadStarted];
	[[ConnectionManager sharedInstance] runJob:@selector(asyncLoadCollection) onTarget:self];
}

- (void) asyncLoadCollection {
	OSYSync *sync = [[OSYSync alloc] init];
	NSError *error = [[NSError alloc] init];
	NSNumber *status = [[[NSNumber alloc] init] autorelease];
	[sync runSync];
	
	if (self.parent==nil) {
		NSArray *remote = [[self classRepresented] findAllRemoteWithResponse:&error];
		self.collection = [sync runCollectionSyncWithLocal:[[self classRepresented] findByCriteria:@""] 
												 andRemote:remote
												 withError:error
													status:&status];
	} else {
		NSString *remoteFind = [NSString stringWithFormat:@"%@/%@",[parent getRemoteId],[[self classRepresented] getRemoteCollectionName]];
		NSString *findByCriteria = [NSString stringWithFormat:@"WHERE %@ = '%@'",[[parent getRemoteClassIdName] underscore],[parent getRemoteId]];
		
		NSArray *remote = [[self.parent class] findRemote:remoteFind withResponse:&error];
		self.collection = [sync runCollectionSyncWithLocal:[[self classRepresented] findByCriteria:findByCriteria] 
												 andRemote:remote
												 withError:error
													status:&status];
	}
	
	[sync release];
	[error release];
	
	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(loadCompleted:) withObject:status waitUntilDone:NO];
}

- (Class) classRepresented {
	return [NSObject class];
}

- (void) syncCompleteWithSuccess:(BOOL)success {
	if (success) {
		[self loadCollection];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	self.toolbarItems = [self setupToolbarItems];
	
	[self loadCollection];
	[OSYService instance].delegate = self;
    
	[super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [collection count];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[aTableView beginUpdates];
		
		[aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						  withRowAnimation:YES];
		
		[(SQLitePersistentObject *)[collection objectAtIndex:indexPath.row] deleteObject];
		[collection removeObject:[collection objectAtIndex:indexPath.row]];
		
		[aTableView endUpdates];
	}
	
}

- (NSArray *)setupToolbarItems {
	self.loadingView = [[[LoadingView alloc] initWithLoadingView] autorelease];
	return [NSArray arrayWithObjects:
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadCollection)],
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
		loadingView,
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)],
		nil];
}

- (void)dealloc {
	[collection release];
	[loadingView release];
	[toolbarItems release];
    [super dealloc];
}


@end

