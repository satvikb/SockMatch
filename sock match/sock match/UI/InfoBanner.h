//
//  InfoBanner.h
//  sock match
//
//  Created by Satvik Borra on 7/8/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoBanner : UIView

-(id)initWithFrame:(CGRect)frame repeatTime:(int)repeatTimes text:(NSString*)text;
-(void)animate;
-(void)stopAnimating;

@end
