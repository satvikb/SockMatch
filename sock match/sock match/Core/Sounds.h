//
//  Sounds.h
//  sock match
//
//  Created by Satvik Borra on 7/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface Sounds : NSObject <AVAudioPlayerDelegate>

// there can only be one playing at once
typedef enum ContinuousSounds {
    MainMenuBackgroundMusic,
    ConveyorBeltMoving
} ContinuousSounds;

// there can be multiple playing at once
typedef enum SoundEffects {
    BoxPackaging,
    ResumeCountdown,
    ForkliftMoving,
    PauseUnpause,
    SockPassed
} SoundEffects;

+ (instancetype)sharedInstance;
-(void)loadSounds;
-(AVAudioPlayer*)playSoundEffect:(SoundEffects)soundEffect loops:(NSInteger)loops;

@property AVAudioPlayer* beltSound;
@property AVAudioPlayer* mainMenuBackgroundMusic;

@property (strong, nonatomic) NSMutableArray<AVAudioPlayer*>* soundEffectPlayers;
@property NSURL* boxPackagingURL;
@property NSURL* countdownURL;
@property NSURL* forkliftMovingURL;
@property NSURL* pauseUnpauseURL;
@property NSURL* sockPassedURL;


@end
