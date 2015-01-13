//
//  AFSoundManager+Percentage.m
//  VK simple client
//
//  Created by Виктор Стариков on 14.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "AFSoundManager+Percentage.h"

@implementation AFSoundManager (Percentage)

-(int)percentage
{
//    __block int percentage = 0;
//
//    if ((_audioPlayer.duration - _audioPlayer.currentTime) >= 1) {
//        
//        percentage = (int)((_audioPlayer.currentTime * 100)/_audioPlayer.duration);
//        int timeRemaining = _audioPlayer.duration - _audioPlayer.currentTime;
//        
//        if (block) {
//            block(percentage, _audioPlayer.currentTime, timeRemaining, error, NO);
//        }
//    } else {
//        
//        int timeRemaining = _audioPlayer.duration - _audioPlayer.currentTime;
//        
//        if (block) {
//            block(100, _audioPlayer.currentTime, timeRemaining, error, YES);
//        }
//        [_timer invalidate];
//        _status = AFSoundManagerStatusFinished;
//        [_delegate currentPlayingStatusChanged:AFSoundManagerStatusFinished];
//    }
    return 0;
}

@end
