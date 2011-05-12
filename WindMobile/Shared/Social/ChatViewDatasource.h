//
//  ChatViewDatasource.h
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ChatViewDatasource <NSObject>

- (NSArray*) getChatItems:(NSString *)chatRoomId;

- (void)postMessage:(NSString *)message withIdentifier:(NSString *)identifier onChatRoom:(NSString *)chatRoomId;

@end
