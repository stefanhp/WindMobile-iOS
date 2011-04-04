//
//  VMSegmentedControl.m
//  WindMobile
//
//  Created by Yann on 04.04.11.
//  Copyright 2011 la-haut.info. All rights reserved.
//

#import "VMSegmentedControl.h"

@implementation VMSegmentedControl

- (void)setSelectedSegmentIndex:(NSInteger)toValue {
    // Trigger UIControlEventValueChanged even when re-tapping the selected segment.
    if (toValue==self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [super setSelectedSegmentIndex:toValue];        
}

@end
