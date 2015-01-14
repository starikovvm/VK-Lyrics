//
//  PlayController.h
//  VK simple client
//
//  Created by Виктор Стариков on 14.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFSoundManager.h"
#import "Playlist.h"
#import "AFSoundManager+getPlayerInfo.h"


@interface PlayController : NSObject

+(PlayController *) sharedInstance;

-(void)playTrack:(int)number;
-(void)playCurrentTrack;
-(void)playNextTrack;
-(void)playPreviousTrack;
-(void)togglePlayPause;
-(void)addToPlaylist:(NSArray *)array;
-(void)addToPlaylist:(NSArray*)array andPlayTrack:(int)trackNumber;
-(BOOL)isPlaying;

@property NSTimer* timer;
@property (strong,nonatomic)NSDictionary* currentPlayingInfo;

@end
