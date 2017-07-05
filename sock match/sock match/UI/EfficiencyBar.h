//
//  EfficiencyBar.h
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EfficiencyBar : UIView

-(id)initWithFrame:(CGRect)frame frameImage:(UIImage*)frameImage innerImage:(UIImage*)innerImage;
-(void)setInnerBarPercentage:(CGFloat)percent;

@end
