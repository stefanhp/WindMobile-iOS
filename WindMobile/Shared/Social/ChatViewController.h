//
//  ChatViewController.h
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChatViewDatasource.h"
#import "MessageTextView.h"

@interface ChatViewController : UIViewController <UIScrollViewDelegate,UITextViewDelegate> {
@private 
    IBOutlet id<ChatViewDatasource> datasource;
    IBOutlet UIScrollView* scrollView;
    IBOutlet MessageTextView* inputTextField;
    IBOutlet UIView *mainView;
    NSString *chatRoomId;
    UIButton* sendButton;
    
    UIView *indicatorMainView;
    UIActivityIndicatorView *activityView;
    CGFloat keyboardOffset;
}

@property ( nonatomic,retain ) id<ChatViewDatasource> datasource;
@property ( nonatomic,retain ) UIScrollView* scrollView;
@property ( nonatomic,retain )  MessageTextView* inputTextField;
@property ( nonatomic,retain ) UIView* mainView;
@property ( nonatomic,retain ) NSString* chatRoomId;
@property ( nonatomic,retain ) UIButton* sendButton;

- (IBAction)refreshChat;
- (IBAction)sendChatMessage:(id)sender;

-(void)activateIndicatorView;
-(void)deactivateIndicatorView;


@end
