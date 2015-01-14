//
//  AFSoundManager+getPlayerInfo.m
//  
//
//  Created by Виктор Стариков on 14.01.15.
//
//

#import "AFSoundManager+getPlayerInfo.h"

@implementation AFSoundManager (getPlayerInfo)

-(NSDictionary *)gpi_getPlayerInfo
{
    if (self.player.currentItem) {
        int percentage = (int)((CMTimeGetSeconds(self.player.currentItem.currentTime) * 100)/CMTimeGetSeconds(self.player.currentItem.duration));
        int timeRemaining = CMTimeGetSeconds(self.player.currentItem.duration) - CMTimeGetSeconds(self.player.currentItem.currentTime);
        NSDictionary *info = @{@"name": @"", @"duration": [NSNumber numberWithInt:CMTimeGetSeconds(self.player.currentItem.duration)], @"elapsed time": [NSNumber numberWithInt:CMTimeGetSeconds(self.player.currentItem.currentTime)], @"remaining time": [NSNumber numberWithInt:timeRemaining], @"volume": [NSNumber numberWithFloat:self.player.volume],@"percentage" : [NSNumber numberWithInt:percentage]};
        return info;
    }
    return nil;
}

@end
