//
//  Playlist.m
//  VK simple client
//
//  Created by Виктор Стариков on 13.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist

+ (Playlist *)sharedInstance
{
    static Playlist * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Playlist alloc] init];
    });
    
    return _sharedInstance;
}

- (Song *)currentSong;
{
    Song* cSong = nil;
    if (self.currentTrackNumber < self.array.count) {
        cSong = self.array[self.currentTrackNumber];
    }
    return cSong;
}

- (BOOL)changeCurrentTrackTo:(int)trackNumber
{
    if (trackNumber >= 0 && trackNumber < self.array.count) {
        self.currentTrackNumber = trackNumber;
        return YES;
    }
    return NO;
}

@end
