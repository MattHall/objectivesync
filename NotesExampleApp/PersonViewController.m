//
//  PersonViewController.m
//  objectivesync
//
//  Created by Justin Cunningham on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PersonViewController.h"
#import "PersonEditController.h"
#import "NoteListController.h"
#import "Person.h"


@implementation PersonViewController
@synthesize person;

- (void) viewDidLoad {
	[super viewDidLoad];
	self.title = person.name;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void) editButtonPressed {
	PersonEditController *editor = [[[PersonEditController alloc] initWithNibName:@"PersonEdit" bundle:nil] autorelease];
	editor.person = self.person;
	[self.navigationController pushViewController:editor animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section) {
		case 0:
			cell.text = person.name;
			break;
		case 1:
			cell.text = @"View Notes";
			break;
		default:
			break;
	}

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  	return [[NSArray arrayWithObjects:@"Name",@"View Notes", nil] 
			objectAtIndex:section];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) {
		return indexPath;
	}
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
		NoteListController *viewController = [[NoteListController alloc] initWithStyle:UITableViewStylePlain];
		viewController.parent = self.person;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end

