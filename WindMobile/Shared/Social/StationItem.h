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
    
}

@property ( readwrite,retain) NSString *displayName;
@property ( readwrite,retain) NSString *identifier;

+ (StationItem *)itemWithId:(NSString *)i displayName:(NSString *)n;

@end
