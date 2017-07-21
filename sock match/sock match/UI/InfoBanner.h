//
//  InfoBanner.h
//  sock match
//
//  Created by Satvik Borra on 7/8/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
typedef void (^AnimatingFinished)(void);

@interface InfoBanner : UIView

//@property (nonatomic, assign) int tag;
@property (nonatomic, copy) AnimatingFinished block;

-(id)initWithFrame:(CGRect)frame repeatTime:(int)repeatTimes text:(NSString*)text;
-(void)animate;
-(void)stopAnimating;

@end
