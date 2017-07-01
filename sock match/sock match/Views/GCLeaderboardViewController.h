//
//  GCLeaderboardViewController.h
//  sock match
//
//  Created by Satvik Borra on 7/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GKScore.h>
#import <GameKit/GKPlayer.h>

@protocol LeaderboardDelegate;

@interface GCLeaderboardViewController : UIViewController

-(id)initWithScores:(NSArray*)scores;
-(void)createScoreCells;
-(void)animateIn;
-(void)animateOutWithCompletion:(void (^)(void))completion;

@property(nonatomic, strong) id<LeaderboardDelegate> delegate;
@end

@protocol LeaderboardDelegate <NSObject>
-(void)dismissLeaderboard:(GCLeaderboardViewController*)vc;
@end
