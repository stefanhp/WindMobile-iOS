//
//  HTTPDataSource.h
//  MiniChatter
//
//  Created by David on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatViewDatasource.h"
#import "StationViewDatasource.h"

//#define REST_SERVER @"10.1.3.148"
//#define REST_PORT 8080

//#define REST_SERVER @"windmobile.vol-libre-suchet.ch"
//#define REST_PORT 1588

@interface HTTPDataSource : NSObject <ChatViewDatasource,StationViewDatasource> {  
@private

}



- (NSDate *)formatDate:(NSString *)rfc3339DateTimeString;
- (NSArray *)parseItemsResult:(NSArray *)jsonObjects;

@end
