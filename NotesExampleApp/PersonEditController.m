//
//  PersonEditController.m
//  objectivesync
//
//  Created by Justin Cunningham on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PersonEditController.h"
#import "Person.h"


@implementation PersonEditController

@synthesize person;

- (void)viewWillAppear:(BOOL)animated {
	name.text = [person name];
}
- (void)viewDidAppear:(BOOL)animated {
	[name becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
	person.name = name.text;
	[person save];
}



#pragma mark cleanup

- (void)dealloc {
	[person release];
    [super dealloc];
}



@end
