//
//  Storage.h
//  sock match
//
//  Created by Satvik Borra on 6/29/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lockbox.h"

@interface Storage : NSObject

+(bool)saveHighScore:(int)score;
+(int)getSavedHighScore;
+(bool)didCompleteTutorial;
+(void)completeTutorial;

@end
