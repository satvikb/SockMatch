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

@synthesize tapToContinueLabel;
@synthesize creditsTouchBlock;

-(id)initWithFrame:(CGRect)frame dismissBlock:(void (^)(void))dismissBlock{
    self = [super initWithFrame:frame];
    self.creditsTouchBlock = dismissBlock;
    
    self.backgroundColor = [UIColor colorWithRed:(43.0/255.0) green:(43.0/255.0) blue:(43.0/255.0) alpha:1];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.1, 0.05, 0.8, 0.15)]];
    titleLabel.text = @"Credits";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:40]];
    [self addSubview:titleLabel];
    
    
    
    UILabel* nameLabel = [self createLabel:[self propToRect:CGRectMake(0.05, 0.2, 0.35, 0.4)] fontSize:30];
    nameLabel.text = @"Satvik B.";
    
    UILabel* stuffDoneLabel = [self createLabel:[self propToRect:CGRectMake(0.45, 0.225, 0.5, 0.4)] fontSize:30];
    stuffDoneLabel.text = @"Concept\nDesign\nProgramming\nGraphics\nSound Effects\nFont";
    stuffDoneLabel.layer.borderWidth = 3;
    stuffDoneLabel.numberOfLines = 6;
    
    UILabel* contact = [self createLabel:[self propToRect:CGRectMake(0.05, 0.625, 0.9, 0.05)] fontSize:13];
    contact.text = @"contact me at satvikbgamedeveloper@gmail.com";
        contact.layer.borderWidth = 3;
    contact.numberOfLines = 1;
    
    
    UILabel* contributions = [self createLabel:[self propToRect:CGRectMake(0.05, 0.7, 0.9, 0.05)] fontSize:10];
    contributions.text = @"vamsi lolla for \"music\".";
//    contributions.layer.borderWidth = 3;
    contributions.numberOfLines = 1;
    
    
    UILabel* minorContributions = [self createLabel:[self propToRect:CGRectMake(0.05, 0.75, 0.9, 0.05)] fontSize:10];
    minorContributions.text = @"minor contributions from some other people i know.";
//    minorContributions.layer.borderWidth = 3;
    minorContributions.numberOfLines = 2;
    
//    [self createLabelsForPerson:@"Satvik Borra" reason:@"Creating this okay mediocre game." atY:0.2];
//    [self createLabelsForPerson:@"Virindh B." reason:@"Being too busy." atY:0.4];
//    [self createLabelsForPerson:@"Vamsi L." reason:@"Trying." atY:0.3];
//    [self createLabelsForPerson:@"Aashish T." reason:@"Not downloading the beta." atY:0.5];
//    [self createLabelsForPerson:@"Hemanth L." reason:@"Being as far from this game as possible." atY:0.6];
//
//
//    UILabel* miscCredits = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.1, 0.8, 0.8, 0.1)]];
//    miscCredits.text = @"average font by me.\nhorrible sound effects also by me.";
//    miscCredits.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:10]];
//    miscCredits.textAlignment = NSTextAlignmentCenter;
//    miscCredits.numberOfLines = 2;
////    miscCredits.layer.borderWidth = 2;
//    miscCredits.textColor = [UIColor whiteColor];
//    [self addSubview:miscCredits];
    
    tapToContinueLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.25, 0.9, 0.5, 0.1)]];
    tapToContinueLabel.text = @"tap to close.";
    tapToContinueLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    tapToContinueLabel.textAlignment = NSTextAlignmentCenter;
    tapToContinueLabel.textColor = [UIColor whiteColor];
    [self addSubview:tapToContinueLabel];
    
    return self;
}

-(UILabel*)createLabel:(CGRect)frame fontSize:(CGFloat)fontSize{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectIntegral(frame)];
    label.text = @"";
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:fontSize]];
    [self addSubview:label];
    return label;
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
    creditsTouchBlock();
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
