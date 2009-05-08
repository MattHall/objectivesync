//
//  OSYSync.h
//  objectivesync
//
//  Created by vickeryj on 1/30/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSYSyncDelegate.h"


@interface OSYSync : NSObject {
}

-(BOOL)runSync;
-(BOOL)syncNeeded;
-(BOOL)runCollectionSyncWithDelegate:(NSObject<OSYSyncDelegate> *)delegate;

@end
