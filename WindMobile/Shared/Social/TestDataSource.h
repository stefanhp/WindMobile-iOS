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

/*
 * Sime datasource that can be used in a nib to simulate a REST client
 */
@interface TestDataSource : NSObject <ChatViewDatasource,StationViewDatasource> {
    
}

@end
