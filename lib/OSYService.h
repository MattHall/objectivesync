//
//  OSYService.h
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSYSyncDelegate.h"


@interface OSYService : NSObject {

	NSObject<OSYSyncDelegate> *delegate;
	int retries;
	
}

@property(nonatomic, retain) NSObject<OSYSyncDelegate> *delegate;
@property int retries;

+(void)setupWithSyncDelegate:(NSObject<OSYSyncDelegate> *)delegate;
+(OSYService *)instance;

-(void)dataChanged;
-(BOOL)runCollectionSync;

@end
