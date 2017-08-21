//
//  CreditsView.m
//  sock match
//
//  Created by Satvik Borra on 8/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "CreditsView.h"
#import "Functions.h"


@implementation CreditsView {
    NSMutableArray<UILabel*>* nameLabels;
    NSMutableArray<UILabel*>* reasonLabels;

}

//@synthesize showing;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:(43.0/255.0) green:(43.0/255.0) blue:(43.0/255.0) alpha:1];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.1, 0.05, 0.8, 0.15)]];
    titleLabel.text = @"Credits";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:40]];
    [self addSubview:titleLabel];
    
    [self createLabelsForPerson:@"Satvik Borra" reason:@"Creating this okay mediocre game." atY:0.2];
    [self createLabelsForPerson:@"Virindh B." reason:@"Being too busy to make tangible contributions." atY:0.4];
    [self createLabelsForPerson:@"Vamsi L." reason:@"Trying to help after a lot of encouragement." atY:0.3];
    [self createLabelsForPerson:@"Aashish T." reason:@"Avoided downloading the beta at all costs." atY:0.5];
    [self createLabelsForPerson:@"Hemanth L." reason:@"Being as far from this game as possible." atY:0.6];

    
    UILabel* miscCredits = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.1, 0.8, 0.8, 0.1)]];
    miscCredits.text = @"average font by me.\nhorrible sound effects also by me.";
    miscCredits.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:10]];
    miscCredits.textAlignment = NSTextAlignmentCenter;
    miscCredits.numberOfLines = 2;
//    miscCredits.layer.borderWidth = 2;
    miscCredits.textColor = [UIColor whiteColor];
    [self addSubview:miscCredits];
    
    UILabel* tapToContinue = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.25, 0.9, 0.5, 0.1)]];
    tapToContinue.text = @"tap to close.";
    tapToContinue.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    tapToContinue.textAlignment = NSTextAlignmentCenter;
    tapToContinue.textColor = [UIColor whiteColor];
    [self addSubview:tapToContinue];
    
    return self;
}

-(void)createLabelsForPerson:(NSString*)name reason:(NSString*)reason atY:(CGFloat)y{
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.05, y, 0.35, 0.1)]];
    nameLabel.text = name;
    nameLabel.textColor = UIColor.whiteColor;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
//    nameLabel.layer.borderWidth = 2;
//    nameLabel.numberOfLines = 0;
    nameLabel.adjustsFontSizeToFitWidth = true;
    [self addSubview:nameLabel];
    [nameLabels addObject:nameLabel];
    
    UILabel* reasonLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.45, y, 0.5, 0.1)]];
    reasonLabel.text = reason;
    reasonLabel.textColor = UIColor.whiteColor;
    reasonLabel.textAlignment = NSTextAlignmentLeft;
    reasonLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
//    reasonLabel.layer.borderWidth = 2;
    reasonLabel.numberOfLines = 2;
    reasonLabel.adjustsFontSizeToFitWidth = true;
    [self addSubview:reasonLabel];
    [reasonLabels addObject:reasonLabel];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
}

-(CGFloat) propX:(CGFloat) x {
    return x*self.frame.size.width;
}

-(CGFloat) propY:(CGFloat) y {
    return y*self.frame.size.height;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}
@end
