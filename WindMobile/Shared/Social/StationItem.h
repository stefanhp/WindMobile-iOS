//
//  StationItem.h
//  NanoChatter
//
//  Created by David on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StationItem : NSObject {
@private
    NSString *displayName;
    NSString *identifier;
    NSString *altitude;
    NSString *maintenanceStatus;
    
}

@property ( readwrite,retain) NSString *displayName;
@property ( readwrite,retain) NSString *identifier;
@property ( readwrite,retain) NSString *altitude;
@property ( readwrite,retain) NSString *maintenanceStatus;

+ (StationItem *)itemWithId:(NSString *)i displayName:(NSString *)n;
+ (StationItem *)itemWithId:(NSString *)i displayName:(NSString *)n altitude:(NSString*)a maintenanceStatus:(NSString*)m;

@end
