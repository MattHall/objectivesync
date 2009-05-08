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
	// sleep(5); // we intentionally block the main thread while the data is reloaded
	if ([status boolValue]) {
		self.collection = [[self collectionFromSQL] mutableCopy];
		[self.tableView reloadData];
	}
	[self.loadingView stopAnimating:[status boolValue]];
}

- (void) loadCollection {
	[self loadStarted];
	[[ConnectionManager sharedInstance] runJob:@selector(asyncLoadCollection) onTarget:self];
}

- (void) asyncLoadCollection {
	// this syncs local reads, writes, and updates, then gets the newest data from the server
	// and merges it with the local data
	if ([[OSYService instance] runCollectionSync]) {
		[self performSelectorOnMainThread:@selector(loadCompleted:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
	} else {
		[self performSelectorOnMainThread:@selector(loadCompleted:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
	}
}

- (NSArray *) collectionFromSQL {
	if (self.parent==nil) {
		return [[self classRepresented] findByCriteria:@""];
	} else {
		NSString *findByCriteria = [NSString stringWithFormat:@"WHERE %@ = '%@'",[[parent getRemoteClassIdName] underscore],[parent getRemoteId]];
		return [[self classRepresented] findByCriteria:findByCriteria];
	}
}

- (NSArray *) collectionFromRemoteWithResponse:(NSError **)error {
	if (self.parent==nil) {
		return [[self classRepresented] findAllRemoteWithResponse:error];
	} else {
		NSString *remoteFind = [NSString stringWithFormat:@"%@/%@",[parent getRemoteId],[[self classRepresented] getRemoteCollectionName]];
		return [[self.parent class] findRemote:remoteFind withResponse:error];
	}
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
	
	self.collection = [[self collectionFromSQL] mutableCopy];
	[self.tableView reloadData];
	
	[self loadCollection];
	
	// Always ensure the current view controller is responsible for the OSYService
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
		[self loadCollection];
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

