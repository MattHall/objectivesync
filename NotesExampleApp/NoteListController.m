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

- (Class) classRepresented {
	return [Note class];
}

- (void) addButtonPressed {
	NoteEditController *editor = [[[NoteEditController alloc] initWithNibName:@"NoteEdit" bundle:nil] autorelease];
	editor.note = [[[Note alloc] init] autorelease];
	editor.note.personId = [parent getRemoteId];
	[collection addObject:editor.note];
	[self.navigationController pushViewController:editor animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Notes";
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.text = [[collection objectAtIndex:indexPath.row] noteText];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NoteEditController *editor = [[[NoteEditController alloc] initWithNibName:@"NoteEdit" bundle:nil] autorelease];
	editor.note = (Note *)[collection objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:editor animated:YES];
}

#pragma mark cleanup
- (void)dealloc {
    [super dealloc];
}


@end

