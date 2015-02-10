//
//  Playlist.m
//  VK simple client
//
//  Created by Виктор Стариков on 13.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "Playlist.h"
#import "NSMutableArray+shuffle.h"


@implementation Playlist

NSMutableArray* shuffledArray;

+ (Playlist *)sharedInstance
{
    static Playlist * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Playlist alloc] init];
    });
    
    return _sharedInstance;
}

-(NSMutableArray*)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc] init];
    }
    return _array;
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



- (void)shuffleEnable
{
    if (self.array.count > 0) {
        Song* currentSong = [self currentSong];
        NSMutableArray* bufArray = [self.array mutableCopy];
        shuffledArray = [NSMutableArray arrayWithArray:self.array];
        if ([bufArray respondsToSelector:@selector(shuffle)])
            [bufArray shuffle];
        else
            NSLog(@"shuffle doesn't work");
        self.array = [NSMutableArray arrayWithArray:bufArray];
        [self.array exchangeObjectAtIndex:0 withObjectAtIndex:[self.array indexOfObject:currentSong]];
        self.currentTrackNumber = 0;
    }
}

- (void)shuffleDisable
{
    if (self.array.count > 0) {
        Song* currentSong = [self currentSong];
        self.array = shuffledArray;
        self.currentTrackNumber = (int)[self.array indexOfObject:currentSong];
    }
}

@end
