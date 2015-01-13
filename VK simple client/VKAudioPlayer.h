//
//  VKAudioPlayer.h
//  VK simple client
//
//  Created by Виктор Стариков on 13.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Playlist.h"

@interface VKAudioPlayer : NSObject  <AVAudioPlayerDelegate>

+(VKAudioPlayer *)sharedInstance;
-(void)playURL:(NSURL *)URL;
-(void)playSong;
-(void)playNextTrack;
-(void)playPreviousTrack;

-(NSString*)timeFormat:(float)value;
- (void)setCurrentAudioTime:(float)value;
- (NSTimeInterval)getCurrentAudioTime;
- (float)getAudioDuration;

@property (strong,nonatomic) AVAudioPlayer *player;

@end
