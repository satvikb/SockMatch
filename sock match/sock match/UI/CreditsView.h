//
//  CreditsView.h
//  sock match
//
//  Created by Satvik Borra on 8/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditsView : UIView

typedef void (^CreditsTouch)(void);

-(id)initWithFrame:(CGRect)frame dismissBlock:(void (^)(void))dismissBlock;

//@property (nonatomic, assign) bool showing;
@property (nonatomic, strong) UILabel* tapToContinueLabel;
@property (nonatomic, copy) CreditsTouch creditsTouchBlock;

@end
