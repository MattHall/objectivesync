//
//  PersonEditController.h
//  objectivesync
//
//  Created by Justin Cunningham on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

@interface PersonEditController : UIViewController {
	IBOutlet UITextField *name;
	Person *person;
}

@property (nonatomic, retain) Person *person;

@end
