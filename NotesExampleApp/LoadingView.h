//
//  LoadingView.h
//  BulletproofTiger
//
//  Created by Justin Cunningham on 4/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIBarButtonItem {
	UIActivityIndicatorView *indicator;
	UILabel *label;
	UILabel *updatedLabel;
}

@property (retain) UIActivityIndicatorView *indicator;
@property (retain) UILabel *label;
@property (retain) UILabel *updatedLabel;

- (void)startAnimating;
- (void)stopAnimating;
- (id)initWithLoadingView;

@end
