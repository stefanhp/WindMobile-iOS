//
//  ChatView.h
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewDatasource.h"


@interface ChatView : UIView {
@private 
    IBOutlet id<ChatViewDatasource> datasource;
    UIFont* textFont;
    UIFont* pseudoFont;
    UIFont* timeFont;

}

- (void)reloadContent:(NSString *)charRoomId;

@property (readwrite,retain) IBOutlet id<ChatViewDatasource> datasource;
@property (readwrite,retain) UIFont* textFont;
@property (readwrite,retain) UIFont* pseudoFont;
@property (readwrite,retain) UIFont* timeFont;

@end
