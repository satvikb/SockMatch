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
@synthesize mainMenuBackgroundMusic;

@synthesize soundEffectPlayers;
@synthesize boxPackagingURL;
@synthesize countdownURL;
@synthesize forkliftMovingURL;
@synthesize pauseUnpauseURL;
@synthesize sockPassedURL;
@synthesize pointURL;

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
    soundEffectPlayers = [[NSMutableArray alloc] init];
    [self loadSounds];
    return self;
}

-(void)loadSounds{
    NSURL *beltSoundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beltNoise" ofType:@"wav"]];
    beltSound = [[AVAudioPlayer alloc] initWithContentsOfURL:beltSoundUrl error:nil];
//    beltSound.numberO
    beltSound.numberOfLoops = -1;
    [beltSound prepareToPlay];
    beltSound.enableRate = true;
//    beltSound.rate = 0;
    
    NSURL *mainMenuBGSoundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BestSong" ofType:@"wav"]];
    mainMenuBackgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:mainMenuBGSoundUrl error:nil];
    //    beltSound.numberO
    mainMenuBackgroundMusic.numberOfLoops = -1;
    [mainMenuBackgroundMusic prepareToPlay];
    mainMenuBackgroundMusic.enableRate = true;
    //    beltSound.rate = 0;
    
    
    
    boxPackagingURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"boxPackaging" ofType:@"wav"]];
//    boxPackaging = [[AVAudioPlayer alloc] initWithContentsOfURL:boxPackagingSoundUrl error:nil];
//    //    beltSound.numberO
//    boxPackaging.numberOfLoops = -1;
//    [boxPackaging prepareToPlay];
//    boxPackaging.enableRate = true;
//    //    beltSound.rate = 0;
    
    countdownURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"countdown" ofType:@"wav"]];
//    countdown = [[AVAudioPlayer alloc] initWithContentsOfURL:resumeCountdownSoundUrl error:nil];
//    //    beltSound.numberO
//    countdown.numberOfLoops = -1;
//    [countdown prepareToPlay];
//    countdown.enableRate = true;
//    //    beltSound.rate = 0;
    
    forkliftMovingURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"forkliftMoving" ofType:@"wav"]];
    
    pauseUnpauseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pauseunpause" ofType:@"wav"]];
//    pauseUnpause = [[AVAudioPlayer alloc] initWithContentsOfURL:pauseUnpauseSoundUrl error:nil];
//    //    beltSound.numberO
//    pauseUnpause.numberOfLoops = -1;
//    [pauseUnpause prepareToPlay];
//    pauseUnpause.enableRate = true;
//    //    beltSound.rate = 0;
    
    sockPassedURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sockPassedFinal" ofType:@"wav"]];
//    sockPassed = [[AVAudioPlayer alloc] initWithContentsOfURL:sockPassedSoundUrl error:nil];
//    //    beltSound.numberO
//    sockPassed.numberOfLoops = -1;
//    [sockPassed prepareToPlay];
//    sockPassed.enableRate = true;
//    //    beltSound.rate = 0;
    
    pointURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Point" ofType:@"wav"]];
    
}

-(AVAudioPlayer*)playSoundEffect:(SoundEffects)soundEffect loops:(NSInteger)loops{

    AVAudioPlayer* eff;
    switch (soundEffect) {
        case BoxPackaging:
            eff = [self createAudioPlayer:boxPackagingURL loops:loops];
            break;
        case ResumeCountdown:
            eff = [self createAudioPlayer:countdownURL loops:loops];
            break;
        case PauseUnpause:
            eff = [self createAudioPlayer:pauseUnpauseURL loops:loops];
            break;
        case SockPassed:
            eff = [self createAudioPlayer:sockPassedURL loops:loops];
            break;
        case PointSound:
            eff = [self createAudioPlayer:pointURL loops:loops];
            break;
        default:
            break;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];
        [eff play];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            // Example:
            // self.myLabel.text = result;
        });
    });
    
    return eff;
}

-(AVAudioPlayer*)createAudioPlayer:(NSURL*)url loops:(NSInteger)loops{
    if([[Settings sharedInstance] getCurrentSetting:Sound]){
        AVAudioPlayer* soundEffect = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        //    beltSound.numberO
        soundEffect.numberOfLoops = loops;
        [soundEffect prepareToPlay];
        soundEffect.enableRate = true;
        
        soundEffect.delegate = self;
        //    beltSound.rate = 0;
        [soundEffectPlayers addObject:soundEffect];
        return soundEffect;
    }
    return nil;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [soundEffectPlayers removeObject:player];
}

@end
