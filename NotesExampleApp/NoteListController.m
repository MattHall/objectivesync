//
//  NoteListController.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "NoteListController.h"
#import "Note.h"
#import "NoteEditController.h"
#import "OSYSync.h"

@implementation NoteListController

@synthesize notes;

- (void) addButtonPressed {
	NoteEditController *editor = [[[NoteEditController alloc] initWithNibName:@"NoteEdit" bundle:nil] autorelease];
	editor.note = [[[Note alloc] init] autorelease];
	[notes addObject:editor.note];
	[self.navigationController pushViewController:editor animated:YES];
}

- (void) asyncLoadCollection {
	OSYSync *sync = [[OSYSync alloc] init];
	NSError *error = [[NSError alloc] init];
	NSNumber *status = [[NSNumber alloc] init];
	[sync runSync];
	NSArray *remote = [Note findAllRemoteWithResponse:&error];
	self.notes = [sync runCollectionSyncWithLocal:[Note findByCriteria:@""] 
										andRemote:remote
										withError:error
										status:&status];
	NSLog(@"%d", error.code);
	
	[sync release];
	[error release];
	
	[status retain];
	
	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(loadCompleted:) withObject:status waitUntilDone:NO];
}

- (void) loadCompleted:(NSNumber *)status {
	[self.loadingView stopAnimating:status];
}

#pragma mark UIViewController methods
- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Notes";
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notes count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.text = [[notes objectAtIndex:indexPath.row] noteText];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NoteEditController *editor = [[[NoteEditController alloc] initWithNibName:@"NoteEdit" bundle:nil] autorelease];
	editor.note = (Note *)[notes objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:editor animated:YES];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[aTableView beginUpdates];
		
		[aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						  withRowAnimation:YES];		
		Note *note = [notes objectAtIndex:indexPath.row];
		[note deleteObject];
		[notes removeObject:note];
		
		[aTableView endUpdates];
	}
	
}

#pragma mark cleanup
- (void)dealloc {
	[notes release];
    [super dealloc];
}


@end

