//
//  WindMobileHelper.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 02.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WindMobileHelper : NSObject {

}
+ (NSDate*)decodeDateFromString:(NSString*)stringDate;
+ (NSDate*)decodeDateFromJavaInt:(double)dateValue;
+ (NSString*)naturalTimeSinceDate:(NSDate*)date;
@end
