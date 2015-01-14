//
//  PlayController.m
//  VK simple client
//
//  Created by Виктор Стариков on 14.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "PlayController.h"

@implementation PlayController

+(PlayController *) sharedInstance
{
    static PlayController * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PlayController alloc] init];
    });
    
    return _sharedInstance;
}

-(instancetype)init
{
    self = [super init];
    return self;
}


-(void)timerAction:(NSTimer *)timer
{
    NSDictionary* infoForCurrentPlaying = [[AFSoundManager sharedManager] gpi_getPlayerInfo];
    self.currentPlayingInfo = infoForCurrentPlaying;
    NSTimeInterval elapsedTime = [[infoForCurrentPlaying objectForKey:@"elapsed time"] doubleValue];
    NSTimeInterval duration = [[infoForCurrentPlaying objectForKey:@"duration"] doubleValue];
    
    int percentage = (int)((elapsedTime * 1000)/duration);
    
    if (percentage == 1000) {
        [self playNextTrack];
    }
}

-(void)playCurrentTrack
{
    [[AFSoundManager sharedManager] startStreamingRemoteAudioFromURL:[[Playlist sharedInstance] currentSong].URLString andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        if (!error) {
            
        } else {
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
    }];
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
}

-(void)playTrack:(int)number
{
    if ([[Playlist sharedInstance]changeCurrentTrackTo:number]) [self playCurrentTrack];
    else [[AFSoundManager sharedManager] stop];
}


-(void)playNextTrack
{
    [self playTrack:[Playlist sharedInstance].currentTrackNumber+1];
}

-(void)playPreviousTrack
{
    [self playTrack:[Playlist sharedInstance].currentTrackNumber-1];
}


-(void)addToPlaylist:(NSArray *)array
{
    [[Playlist sharedInstance].array addObjectsFromArray:array];
}

-(void)addToPlaylist:(NSArray*)array andPlayTrack:(int)trackNumber
{
    [Playlist sharedInstance].array = [array mutableCopy];
    [self playTrack:trackNumber];
}

-(void)togglePlayPause
{
    if ([self isPlaying]) {
        [[AFSoundManager sharedManager] pause];
    } else {
        [[AFSoundManager sharedManager] resume];
    }
}

-(BOOL)isPlaying
{
    if ([AFSoundManager sharedManager].player) {
        if ([AFSoundManager sharedManager].player.rate == 1.0) {
            return YES;
        }
    }
    return NO;
}

@end