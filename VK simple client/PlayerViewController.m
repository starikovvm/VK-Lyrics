//
//  PlayerViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 07.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "PlayerViewController.h"
#import "Playlist.h"
#import "VKAudioPlayer.h"

@interface PlayerViewController ()

@end

static BOOL isPlaying;

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.seekSlider setThumbImage:[UIImage imageNamed:@"thumb25.png"] forState:UIControlStateNormal];
    
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    self.nameLabel.labelSpacing = 40; // distance between start and end labels
    self.nameLabel.pauseInterval = 2; // seconds of pause before scrolling starts again
    self.nameLabel.scrollSpeed = 30; // pixels per second
    self.nameLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
    self.nameLabel.fadeLength = 12.f; // length of the left and right edge fade, 0 to disable
    [self updateLabels];
    if ([[VKAudioPlayer sharedInstance].player rate]) {
        [self changeToPause];  // This changes the button to Pause
    }
    else {
        [self changeToPlay];   // This changes the button to Play
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                 repeats:YES];
    self.scrubbing = NO;

}

-(void)viewDidAppear:(BOOL)animated
{
    [[VKAudioPlayer sharedInstance].player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [[Playlist sharedInstance] addObserver:self forKeyPath:@"currentTrackNumber" options:NSKeyValueObservingOptionNew context:nil];
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VKAudioPlayer sharedInstance].player removeObserver:self forKeyPath:@"rate"];
    [[Playlist sharedInstance] removeObserver:self forKeyPath:@"currentTrackNumber"];
    [self resignFirstResponder];
}


#pragma mark - helpers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([[VKAudioPlayer sharedInstance].player rate]) {
            [self changeToPause];  // This changes the button to Pause
        }
        else {
            [self changeToPlay];   // This changes the button to Play
        }
    }
    if ([keyPath isEqualToString:@"currentTrackNumber"]) {
        [self playCurrentTrack];
        [self updateLabels];
    }
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

-(void)playCurrentTrack
{
    [[AFSoundManager sharedManager] startStreamingRemoteAudioFromURL:[[Playlist sharedInstance] currentSong].URLString andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        if (!error) {
            
        } else {
            
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
    }];
}

-(void)playTrack:(int)number
{
    [Playlist sharedInstance].currentTrackNumber = number;
    [self playCurrentTrack];
//    [[VKAudioPlayer sharedInstance] playSong];
    [self updateLabels];
}

-(void)playNextTrack
{
    [[Playlist sharedInstance] changeCurrentTrackTo:[Playlist sharedInstance].currentTrackNumber+1];
}

-(void)playPreviousTrack
{
    [[Playlist sharedInstance] changeCurrentTrackTo:[Playlist sharedInstance].currentTrackNumber-1];

}

-(void)currentPlayingStatusChanged:(AFSoundManagerStatus)status
{
    NSLog(@"status changed!");
    switch (status) {
        case AFSoundManagerStatusPlaying:
            [self changeToPause];
            break;
        
        case AFSoundManagerStatusPaused:
            [self changeToPlay];
            break;
        
        case AFSoundManagerStatusFinished:
            [self playNextTrack];
            break;
            
        default:
            break;
    }
}


#pragma mark - UI

-(void)changeToPause
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playButton.imageView.image = [UIImage imageNamed:@"pause"];
    });
    isPlaying = YES;
}

-(void)changeToPlay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playButton.imageView.image = [UIImage imageNamed:@"play"];
    });
    isPlaying = NO;
}

-(void)updateLabels
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nameLabel setText:[[Playlist sharedInstance] currentSong].title refreshLabels:YES];
        [self.artistLabel setText:[[Playlist sharedInstance] currentSong].artist];
        int duration = [[Playlist sharedInstance] currentSong].duration;
        self.timeEndLabel.text = [NSString stringWithFormat:@"%i:%02i",duration/60,duration%60];
    });
}

-(void)updateTime:(NSTimer *)timer;
{
//    if (!self.scrubbing) {
//        self.seekSlider.value = [[VKAudioPlayer sharedInstance] getCurrentAudioTime];
//    }
//    self.timeLabel.text = [NSString stringWithFormat:@"%@",
//                             [[VKAudioPlayer sharedInstance] timeFormat:[[VKAudioPlayer sharedInstance] getCurrentAudioTime]]];
//    
//    self.timeEndLabel.text = [NSString stringWithFormat:@"-%@",
//                          [[VKAudioPlayer sharedInstance] timeFormat:[[VKAudioPlayer sharedInstance] getAudioDuration] - [[VKAudioPlayer sharedInstance] getCurrentAudioTime]]];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm:ss"];
    NSDictionary* infoForCurrentPlaying = [[AFSoundManager sharedManager] retrieveInfoForCurrentPlaying];
    NSTimeInterval elapsedTime = [[infoForCurrentPlaying objectForKey:@"elapsed time"] doubleValue];
    NSTimeInterval timeRemaining = [[infoForCurrentPlaying objectForKey:@"time remaining"] doubleValue];
    NSTimeInterval duration = [[infoForCurrentPlaying objectForKey:@"duration"] doubleValue];

    
    int percentage = (int)((elapsedTime * 100)/duration);
    
    NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
    self.timeLabel.text = [formatter stringFromDate:elapsedTimeDate];
    
    NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
    self.timeEndLabel.text = [formatter stringFromDate:timeRemainingDate];
    
    if (!self.scrubbing) {
     		   self.seekSlider.value = percentage * 0.01;
    }
}



#pragma mark - IBActions


- (IBAction)playButtonPressed:(UIButton *)sender {
    if ([AFSoundManager sharedManager].status != AFSoundManagerStatusPlaying) {
//        [[VKAudioPlayer sharedInstance].player pause];
        [[AFSoundManager sharedManager] resume];
    }
    else
    {
//        [[VKAudioPlayer sharedInstance].player play];
        [[AFSoundManager sharedManager] pause];

    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                repeats:YES];
    
//    NSUInteger duration = CMTimeGetSeconds([VKAudioPlayer sharedInstance].player.currentItem.asset.duration);
//    unsigned long minutes = floor(duration/60);
//    unsigned long seconds = floor(duration%60);
//    NSString* durationString = [NSString stringWithFormat:@"%02lu:%02lu s",minutes,seconds];
//    NSLog(@"Duration is %@",durationString);
}

- (IBAction)nextButtonPressed:(UIButton *)sender
{
//    [[VKAudioPlayer sharedInstance].player removeObserver:self forKeyPath:@"rate"];
//    [[VKAudioPlayer sharedInstance] playNextTrack];
//    [[VKAudioPlayer sharedInstance].player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self playNextTrack];
}

- (IBAction)previousButtonPressed:(UIButton *)sender
{
//    [[VKAudioPlayer sharedInstance].player removeObserver:self forKeyPath:@"rate"];
//    [[VKAudioPlayer sharedInstance] playPreviousTrack];
//    [[VKAudioPlayer sharedInstance].player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self playPreviousTrack];
}

- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}

- (IBAction)setCurrentTime:(id)scrubber {
    //if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it
//    [NSTimer scheduledTimerWithTimeInterval:0.01
//                                     target:self
//                                   selector:@selector(updateTime:)
//                                   userInfo:nil
//                                    repeats:NO];
    
    //[[VKAudioPlayer sharedInstance] setCurrentAudioTime:self.seekSlider.value];
    [[AFSoundManager sharedManager]moveToSection:self.seekSlider.value];

    self.scrubbing = FALSE;
}

@end
