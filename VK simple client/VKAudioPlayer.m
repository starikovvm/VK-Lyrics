//
//  VKAudioPlayer.m
//  VK simple client
//
//  Created by Виктор Стариков on 13.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "VKAudioPlayer.h"

@implementation VKAudioPlayer


+ (VKAudioPlayer *)sharedInstance
{
    static VKAudioPlayer * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[VKAudioPlayer alloc] init];
    });
    
    return _sharedInstance;
}

-(void)playURL:(NSURL *)URL
{
    NSLog(@"playURL called");
//    self.player = nil;
//    NSError* error = nil;
//    //    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
////    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:URL error:&error];
//    
//    NSData *soundData = [NSData dataWithContentsOfURL:URL];
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                               NSUserDomainMask, YES) objectAtIndex:0]
//                          stringByAppendingPathComponent:@"music.mp3"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [soundData writeToFile:filePath atomically:YES];
//    });
//    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
//                                                           fileURLWithPath:filePath] error:&error];
//    NSLog(@"error %@", error);
//    
//    if (error)
//    {
//        NSLog(@"%@",error);
//    }
//    //    self.player = [AVPlayer playerWithURL:url];
//    [self.player play];
}

-(void)playSong
{
    if ([[Playlist sharedInstance] currentSong]) {
        [self playURL:[[Playlist sharedInstance] currentSong].URL];
        NSLog(@"Playing %@",[[Playlist sharedInstance] currentSong].title);
    }
}

-(void)playNextTrack
{
    if ([Playlist sharedInstance].currentTrackNumber < [Playlist sharedInstance].array.count-1) {
        [Playlist sharedInstance].currentTrackNumber++;
        [self playSong];
    }
}

-(void)playPreviousTrack
{
    if ([Playlist sharedInstance].currentTrackNumber > 0) {
        [Playlist sharedInstance].currentTrackNumber--;
        [self playSong];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [self playNextTrack];
    }
}

-(NSString*)timeFormat:(float)value
{
    
    float minutes = floor(lroundf(value)/60);
    float seconds = lroundf(value) - (minutes * 60);
    
    int roundedSeconds = (int)lroundf(seconds);
    int roundedMinutes = (int)lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%d:%02d",
                      roundedMinutes, roundedSeconds];
    return time;
}

- (void)setCurrentAudioTime:(float)value
{
    [self.player setCurrentTime:value];
}

- (NSTimeInterval)getCurrentAudioTime
{
    return [self.player currentTime];
}

- (float)getAudioDuration
{
    return [self.player duration];
}



@end
