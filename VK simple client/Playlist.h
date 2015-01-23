//
//  Playlist.h
//  VK simple client
//
//  Created by Виктор Стариков on 13.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"

@interface Playlist : NSObject

+ (Playlist *)sharedInstance;
- (Song *)currentSong;
- (BOOL)changeCurrentTrackTo:(int)trackNumber;
- (void)shuffleEnable;
- (void)shuffleDisable;

@property (strong, nonatomic) NSMutableArray* array;
@property (nonatomic) int currentTrackNumber;

@end
