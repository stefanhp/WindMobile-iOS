//
//  ChatViewController.m
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

#import "ChatViewController.h"
#import "ChatItem.h"
#import "ChatView.h"
#import "GradientButton.h"

#import "iPadHelper.h"

@implementation ChatViewController



@synthesize scrollView;
@synthesize inputTextField;
@synthesize datasource;
@synthesize mainView;
@synthesize chatRoomId;
@synthesize sendButton;
@synthesize refreshing;

/*
 * Reload the content and create the celles
 */
- (void)reloadChatMessages
{
    if ( self.refreshing ) {
        return;
    }
    self.refreshing = true;
    [self chatView].loading = YES;
    [[self chatView] setNeedsDisplay];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // backgroun process
        NSString *error = nil;
        NSArray *items = nil;
        @try{
            items = [datasource getChatItems:chatRoomId];
        }
        @catch (NSException *ex) {
            error = [ex reason];
        }
        @finally {
            self.refreshing = false;
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [self stopRefreshAnimation];
            if ( !error) {
                [[self chatView] setChatItems:items];
                
            } else {
                UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:@"Server error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [openURLAlert show];
                [openURLAlert release];
            }
        });
    });
}

-(void)doRefreshChat 
{
    if ( datasource != nil ) {
        [self startRefreshAnimation];
        [self reloadChatMessages];
    } else {
        [[self chatView] setChatItems:nil];
    }
}

- (IBAction)refreshChat:(id)sender
{
    [self doRefreshChat];
}

- (ChatView *)chatView
{
    return ((ChatView*)[[scrollView subviews] objectAtIndex:0]);
}

- (void)viewDidLoad
{
    //self.chatRoomId = @"test";
    
    GradientButton *sendChatButton;
    
    CGSize viewSize = [inputTextField superview].bounds.size;
    CGFloat high = 30;
    CGFloat buttonWidth = (viewSize.width / 2.0);

    if([iPadHelper isIpad]){
        high = 60;
        buttonWidth = viewSize.width;
    }
    
    GradientButton *insertPositionButton = [[GradientButton alloc] initWithFrame:CGRectMake(4, 0, high-8,high-8)];
    [insertPositionButton setTitle:@"+" forState:UIControlStateNormal];
    [insertPositionButton addTarget:self action:@selector(insertPosition:) forControlEvents:UIControlEventTouchUpInside];
    insertPositionButton.cornerRadius = 6.0;
    insertPositionButton.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    insertPositionButton.strokeWeight = 1.0;
    [insertPositionButton useAlertStyle];
    
    if([iPadHelper isIpad]){
        sendChatButton = [[GradientButton alloc] initWithFrame:CGRectMake(viewSize.width - buttonWidth+2, 2, buttonWidth-8, high-4)];
    } else {
        sendChatButton = [[GradientButton alloc] initWithFrame:CGRectMake(viewSize.width - buttonWidth+2, 0, buttonWidth-16, high-4)];
    }
    [sendChatButton setTitle:NSLocalizedStringFromTable(@"CHAT_MESSAGE_SEND", @"WindMobile", nil) forState:UIControlStateNormal];
    [sendChatButton addTarget:self action:@selector(sendChatMessage:) forControlEvents:UIControlEventTouchUpInside];
    sendChatButton.cornerRadius = 6.0;
    sendChatButton.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    sendChatButton.strokeWeight = 1.0;
    sendChatButton.titleLabel.textColor = [UIColor whiteColor];
    
    sendChatButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [sendChatButton useGreenConfirmStyle];
    self.sendButton = sendChatButton;
    
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  viewSize.width,high)];
    if([iPadHelper isIpad]){
        accessoryView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    }else {
        accessoryView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    //[accessoryView addSubview:insertPositionButton];
    [accessoryView addSubview:sendChatButton];

    [insertPositionButton release];
    [sendChatButton release];
    
    ((UITextView*)inputTextField).inputAccessoryView = accessoryView;
    
    //------ Indicator view setup
    activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    indicatorMainView = [[UIView alloc] initWithFrame:self.view.bounds];
    indicatorMainView.opaque = YES;
    indicatorMainView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.2];
    [indicatorMainView addSubview:activityView];
    
    CGRect activityRect = CGRectMake((CGRectGetWidth(indicatorMainView.bounds) - CGRectGetWidth(activityView.bounds)) / 2.0, 
                                     (CGRectGetHeight(indicatorMainView.bounds) - CGRectGetHeight(activityView.bounds)) / 2.0,
                                     CGRectGetWidth(activityView.bounds),
                                     CGRectGetHeight(activityView.bounds));
    activityView.frame = activityRect;
    
    
    // Put Refresh button on the top left
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refreshChat)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];
    
    //------ Add notification ---------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputEnded:) name:UITextViewTextDidEndEditingNotification object:inputTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputStarted:) name:UITextViewTextDidBeginEditingNotification object:inputTextField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification 
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    keyboardRect = [self.mainView convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGRect newTextViewFrame = self.mainView.frame;
    
    keyboardOffset = (newTextViewFrame.size.height - keyboardTop);
    newTextViewFrame.size.height -= keyboardOffset;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.mainView.frame = newTextViewFrame;
    [scrollView scrollRectToVisible:CGRectMake(0,scrollView.contentSize.height-1,10, 10) animated:YES];

    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
    NSDictionary* userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.mainView convertRect:keyboardRect fromView:nil];
        
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect newTextViewFrame = self.mainView.frame;
    
    newTextViewFrame.size.height += keyboardOffset;
    
    self.mainView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

- (IBAction)cancelChatMessage:(id)sender
{
    ((UITextView*)inputTextField).text = @"";
    [inputTextField resignFirstResponder];
}

- (IBAction)sendChatMessage:(id)sender 
{
    NSString *message = [inputTextField text];

    [[self chatView] addTemporaryMessage:message];
    [self activateIndicatorView];
    
    [sendButton setEnabled:NO];
    [inputTextField resignFirstResponder];
    [inputTextField setFresh];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // backgroun process
        NSString *error = nil;
        if ( message.length > 0 ) {
            @try{
                // identifier is not required in a real REST session
                [datasource postMessage:message withIdentifier:@"iPhone" onChatRoom:chatRoomId];
            }
            @catch (NSException *ex) {
                error = [ex reason];
            }
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [self deactivateIndicatorView];
            if ( error ) {
                UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:@"Server error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [openURLAlert show];
                [openURLAlert release];
            }
            [sendButton setEnabled:YES];
            [self refreshChat:self];
        });
    });
}

-(void)activateIndicatorView
{
    [self.view addSubview:indicatorMainView];
    [activityView startAnimating];
}

-(void)deactivateIndicatorView
{
    [activityView stopAnimating];
    [indicatorMainView removeFromSuperview];
}

- (void)textViewDidChange:(UITextView *)textView
{

}

-(void)textInputEnded:(NSNotification *)notification 
{
    [inputTextField setNeedsDisplay];
}

-(void)textInputStarted:(NSNotification *)notification 
{
    [inputTextField setNeedsDisplay];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    NSMutableString *str = [NSMutableString stringWithString:[textView text]];
    [str replaceCharactersInRange:range withString:text];
    if ([str length] == 0 ) {
        [inputTextField resignFirstResponder];
        [inputTextField setFresh];
    }
    return TRUE;
}

-(void)insertPosition:(id)sender
{
    CLLocationManager* locationManager = [[[CLLocationManager alloc] init] autorelease];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coor = [location coordinate];
    // Get a refererence to the system pasteboard because that's
	// the only one @selector(paste:) will use.
	UIPasteboard* generalPasteboard = [UIPasteboard generalPasteboard];
	
	// Save a copy of the system pasteboard's items
	// so we can restore them later.
	NSArray* items = [generalPasteboard.items copy];
	
	// Set the contents of the system pasteboard
	// to the text we wish to insert.
	generalPasteboard.string = [NSString stringWithFormat:@"<%+f,%+f>",coor.latitude,coor.longitude];
	
	// Tell this responder to paste the contents of the
	// system pasteboard at the current cursor location.
	[inputTextField paste: self];
	
	// Restore the system pasteboard to its original items.
	generalPasteboard.items = items;
	
	// Free the items array we copied earlier.
	[items release];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [self doRefreshChat];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [inputTextField resignFirstResponder];
    [[self chatView] setChatItems:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)startRefreshAnimation
{
	// Remove refresh button
	self.navigationItem.rightBarButtonItem = nil;
	
	// activity indicator
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	self.navigationItem.rightBarButtonItem = activityItem;
	[activityItem release];
}

- (void)stopRefreshAnimation
{
	// Stop animation
	self.navigationItem.rightBarButtonItem = nil;
	
	// Put Refresh button on the top left
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refreshChat:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];
}

- (void)dealloc 
{
    [chatRoomId release];
    [sendButton release];
    [indicatorMainView release];
    [super dealloc];
}
@end
