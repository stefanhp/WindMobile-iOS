//
//  TestDataSource.h
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatViewDatasource.h"
#import "StationViewDatasource.h"

@interface TestDataSource : NSObject <ChatViewDatasource,StationViewDatasource> {
    
}

@end
