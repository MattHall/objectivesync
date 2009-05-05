//
//  PersonListController.m
//  objectivesync
//
//  Created by Justin Cunningham on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PersonListController.h"
#import "Person.h"
#import "PersonEditController.h"
#import "PersonViewController.h"

@implementation PersonListController

- (Class) classRepresented {
	return [Person class];
}

- (void) addButtonPressed {
	PersonEditController *editor = [[[PersonEditController alloc] initWithNibName:@"PersonEdit" bundle:nil] autorelease];
	editor.person = [[[Person alloc] init] autorelease];
	[collection addObject:editor.person];
	[self.navigationController pushViewController:editor animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"People";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.text = [[collection objectAtIndex:indexPath.row] name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PersonViewController *view = [[[PersonViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	view.person = (Person *)[collection objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:view animated:YES];	
}


- (void)dealloc {
    [super dealloc];
}


@end

