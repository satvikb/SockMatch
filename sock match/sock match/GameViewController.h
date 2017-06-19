//
//  GameViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameTransition;

@interface GameViewController : UIViewController{
    
}

@property (nonatomic, weak) id<GameTransition> delegate;

-(void)beginGame;
-(void)endGame;
-(void)stopGameLoop;
@end

@protocol GameTransition <NSObject>
- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score;
@end
