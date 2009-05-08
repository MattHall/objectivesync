//
//  LoadingView.m
//  BulletproofTiger
//
//  Created by Justin Cunningham on 4/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView
@synthesize label, indicator, updatedLabel;

- (id)initWithLoadingView {
	NSLog(@"Create loading view");
	
	if (self = [super initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0,0,200,25)]]) {
		self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 0, 25, 25)];
		[indicator sizeToFit];
		indicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									  UIViewAutoresizingFlexibleRightMargin |
									  UIViewAutoresizingFlexibleTopMargin |
									  UIViewAutoresizingFlexibleBottomMargin);
		
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 75, 20)];
		label.text = @"";
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont systemFontOfSize:16];
		label.shadowColor = [UIColor grayColor];
		label.adjustsFontSizeToFitWidth = YES;
		
		self.updatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
		updatedLabel.text = @"";
		updatedLabel.backgroundColor = [UIColor clearColor];
		updatedLabel.textColor = [UIColor whiteColor];
		updatedLabel.font = [UIFont systemFontOfSize:16];
		updatedLabel.shadowColor = [UIColor grayColor];
		updatedLabel.textAlignment = UITextAlignmentCenter;
		updatedLabel.adjustsFontSizeToFitWidth = YES;
		
		[self.customView addSubview:indicator];
		[self.customView addSubview:label];
		[self.customView addSubview:updatedLabel];
	}
	
	return self;
}

- (void)startAnimating {
	updatedLabel.text = nil;
	label.text = @"Updating...";
	[indicator startAnimating];
}

- (void)stopAnimating:(BOOL)status {
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	label.text = nil;
	if (status) {
		updatedLabel.text = [[NSString stringWithString:@"Updated "] stringByAppendingString:[dateFormatter stringFromDate:today]];
	} else {
		updatedLabel.text = @"Update Failed";
	}
	[indicator stopAnimating];
}


- (void)dealloc {
	NSLog(@"deallocing loading view");
	[label release];
	[indicator release];
	[updatedLabel release];
    [super dealloc];
}


@end