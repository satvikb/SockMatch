//
//  Sounds.m
//  sock match
//
//  Created by Satvik Borra on 7/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Sounds.h"

@implementation Sounds

@synthesize beltSound;

+ (instancetype)sharedInstance
{
    static Sounds *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Sounds alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    [self loadSounds];
    return self;
}

-(void)loadSounds{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beltNoise" ofType:@"wav"]];
    beltSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    beltSound.numberO
    beltSound.numberOfLoops = -1;
    [beltSound prepareToPlay];
    beltSound.enableRate = true;
//    beltSound.rate = 0;
}

@end
