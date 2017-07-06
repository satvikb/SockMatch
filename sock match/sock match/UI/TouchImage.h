//
//  TouchImage.h
//  sock match
//
//  Created by Satvik Borra on 7/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchImage : UIImageView{
    
}

typedef void (^TouchImageDown)(void);

-(id)initWithFrame:(CGRect)frame image:(UIImage*)img;

@property (nonatomic, copy) TouchImageDown block;

@end
