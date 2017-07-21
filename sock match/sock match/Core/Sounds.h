//
//  Sounds.h
//  sock match
//
//  Created by Satvik Borra on 7/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface Sounds : NSObject

+ (instancetype)sharedInstance;
-(void)loadSounds;

@property AVAudioPlayer* beltSound;


@end
