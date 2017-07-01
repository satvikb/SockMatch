//
//  GCLeaderboardViewController.m
//  sock match
//
//  Created by Satvik Borra on 7/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GCLeaderboardViewController.h"

@interface GCLeaderboardViewController (){
    NSArray* scores;
    NSMutableArray<UIView*>* scoreCells;
    UIView* background;
    UIView* navBar;
    UIScrollView* scrollView;
}

@end

@implementation GCLeaderboardViewController

-(id)initWithScores:(NSArray*)scores{
    self = [super init];
    self->scores = scores;
    
    background = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(-1, 0, 1, 1)]];
    background.backgroundColor = [UIColor blackColor];
    [self.view addSubview:background];
    
    navBar = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(-1, 0, 1, 0.15)]];
    navBar.backgroundColor = [UIColor darkGrayColor];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:[self propToRect:CGRectMake(0.05, 0.2, 0.4, 0.6) withinFrame:navBar.frame]];
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [navBar addSubview:backButton];
    [self.view addSubview:navBar];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, navBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-navBar.frame.size.height)];
//    scrollView.bounces = false;
//    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.showsVerticalScrollIndicator = false;
    [self.view addSubview:scrollView];
    
    scoreCells = [[NSMutableArray alloc] init];
    return self;
}

-(void)pressBackButton{
    
    if([self.delegate respondsToSelector: @selector(dismissLeaderboard:)]){
        [self.delegate dismissLeaderboard:self];
//        [self dismissViewControllerAnimated:false completion:nil];
    }
}

-(void)createScoreCells{
    CGFloat contentHeight = 0;
    
    for(int i = 0; i < scores.count; i++){
        GKScore* score = [scores objectAtIndex:i];
        GKPlayer* player = score.player;
        
        CGFloat propHeight = 0.15;
        UIView* scoreCell = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(-1, propHeight*i, 1, propHeight)]];
        
        UILabel* rankLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 0.18, 1) withinFrame:scoreCell.frame]];
        rankLabel.text = [NSString stringWithFormat:@"%li", score.rank];
        rankLabel.textAlignment = NSTextAlignmentCenter;
        [scoreCell addSubview:rankLabel];
        
        UILabel* scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.4, 0.5, 0.6, 0.5) withinFrame:scoreCell.frame]];
        scoreLabel.text = [NSString stringWithFormat:@"%lli %@", score.value, score.value == 1 ? @"sock" : @"socks"];
        [scoreCell addSubview:scoreLabel];
        
       UILabel* playerLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.4, 0, 0.6, 0.5) withinFrame:scoreCell.frame]];
        playerLabel.text = [NSString stringWithFormat:@"%@", player.alias];
        [scoreCell addSubview:playerLabel];
        
        CGRect imageFrame = [self propToRect: CGRectMake(0.18, 0, 0.2, 0) withinFrame:scoreCell.frame];
        UIImageView* playerImage = [[UIImageView alloc] initWithFrame:CGRectMake(imageFrame.origin.x, imageFrame.origin.y+(scoreCell.frame.size.height-imageFrame.size.width)/2, imageFrame.size.width, imageFrame.size.width)];
        playerImage.layer.cornerRadius = playerImage.frame.size.width/2;
        playerImage.layer.borderWidth = 2;
        playerImage.layer.borderColor = [UIColor blackColor].CGColor;
        
        [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage* img, NSError* error){
            if(error){
                NSLog(@"Error getting photo %@", error);
                
            }else{
                [playerImage setImage:img];
            }
        }];
        [scoreCell addSubview:playerImage];
        
        [scrollView addSubview:scoreCell];
        scoreCell.backgroundColor = [UIColor brownColor];
        [scoreCells addObject:scoreCell];
        
        contentHeight += scoreCell.frame.size.height;
    }
    scrollView.contentSize = CGSizeMake([self propX:1], contentHeight);
}

-(void)animateIn{
    [UIView animateWithDuration:0.25 animations:^{
        navBar.frame = CGRectOffset(navBar.frame, [self propX:1], 0);
        background.frame = CGRectOffset(background.frame, [self propX:1], 0);
    }];
    
    CGFloat currentDelay = 0;
    for(int i = 0; i < scoreCells.count; i++){
        UIView* cell = [scoreCells objectAtIndex:i];
        
        [UIView animateWithDuration:0.25 delay:currentDelay options:UIViewAnimationOptionCurveLinear animations:^void{
            cell.frame = CGRectOffset(cell.frame, [self propX:1], 0);
        } completion:^(BOOL finished){
            
        }];
        
        currentDelay += 0.02;
    }
}

-(void)animateOutWithCompletion:(void (^)(void))completion{
    [UIView animateWithDuration:0.25 animations:^{
        navBar.frame = CGRectOffset(navBar.frame, [self propX:-1], 0);
        background.frame = CGRectOffset(background.frame, [self propX:-1], 0);
    }];

    CGFloat currentDelay = 0;
    CGFloat increaseDelayBy = 0.02;
    for(int i = 0; i < scoreCells.count; i++){
        UIView* cell = [scoreCells objectAtIndex:i];
        
        [UIView animateWithDuration:0.25 delay:currentDelay options:UIViewAnimationOptionCurveLinear animations:^void{
            cell.frame = CGRectOffset(cell.frame, [self propX:-1], 0);
        } completion:^(BOOL finished){
            
        }];
        
        currentDelay += increaseDelayBy;
    }
    
    CGFloat totalDelay = increaseDelayBy*scoreCells.count;
    [self performSelector:@selector(doAnimateOutCompletion:) withObject:completion afterDelay:totalDelay];
}

-(void)doAnimateOutCompletion:(void (^)(void))completion{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

-(CGFloat) propY:(CGFloat) y {
    return y*self.view.frame.size.height;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = [[self view] frame];
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

- (CGRect) propToRect: (CGRect)prop withinFrame:(CGRect)frame {
    CGRect viewSize = frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
