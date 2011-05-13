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
    UIFont* textFont;
    UIFont* pseudoFont;
    UIFont* timeFont;
    Boolean loading;
}

-(void)setChatItems:(NSArray *)items;
-(void)addTemporaryMessage:(NSString *)message;

@property () Boolean loading;

@property (readwrite,retain) UIFont* textFont;
@property (readwrite,retain) UIFont* pseudoFont;
@property (readwrite,retain) UIFont* timeFont;

@end
