//
//  TutorialView.h
//  sock match
//
//  Created by Satvik Borra on 6/30/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sock.h"
#import "Functions.h"
#import "FocusOnRect.h"

@interface TutorialView : UIView

typedef void (^AnimateSockOneComplete)(Sock* s);
typedef void (^AnimateSockTwoComplete)(Sock* s);
typedef void (^SockOneTouchEnd)(Sock* s);
typedef void (^SockOneTouchMove)(Sock* s);
typedef void (^SockTwoTouchMove)(Sock* s);

@property (nonatomic, assign) TutorialState tutorialState;
@property (nonatomic, strong) Sock* sockOne;
@property (nonatomic, strong) Sock* sockTwo;

@property (strong, nonatomic) UILabel* tutorialText;

-(id)initWithScreenFrame:(CGRect)frame andSockImage:(UIImage*)sockImage;
-(void)animateSockOneToX:(CGFloat)xPos withBeltMoveSpeed:(CGFloat)beltMoveSpeed;
-(void)animateSockTwoToX:(CGFloat)xPos withBeltMoveSpeed:(CGFloat)beltMoveSpeed;
-(void)animateTutorialLabelIn;
-(void)animateTutorialLabelOutAndRemoveTutorialView;
-(void)focusOnRect:(CGRect)rect withLabels:(NSArray<UILabel*>*)labels touchBlock:(void (^)(void))touched;
    
@property (nonatomic, copy) AnimateSockOneComplete animateSockOneCompleteBlock;
@property (nonatomic, copy) AnimateSockTwoComplete animateSockTwoCompleteBlock;
@property (nonatomic, copy) SockOneTouchEnd sockOneTouchEndBlock;
@property (nonatomic, copy) SockOneTouchMove sockOneTouchMoveBlock;
@property (nonatomic, copy) SockTwoTouchMove sockTwoTouchMoveBlock;

@end
