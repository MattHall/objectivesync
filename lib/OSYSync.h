//
//  OSYSync.h
//  objectivesync
//
//  Created by vickeryj on 1/30/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OSYSync : NSObject {
}

-(void)runSync;
-(NSMutableArray *)runCollectionSyncWithLocal:(NSArray *)local andRemote:(NSArray *)remote withError:(NSError *)error status:(NSNumber **)status;

@end
