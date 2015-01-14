//
//  PlayerViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 07.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "PlayerViewController.h"
#import "Playlist.h"
#import "AFSoundManager+getPlayerInfo.h"

@interface PlayerViewController ()

@end

static BOOL isPlaying;

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.seekSlider setThumbImage:[UIImage imageNamed:@"thumb25.png"] forState:UIControlStateNormal];
    [AFSoundManager sharedManager].delegate = self;
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    self.nameLabel.labelSpacing = 40; // distance between start and end labels
    self.nameLabel.pauseInterval = 2; // seconds of pause before scrolling starts again
    self.nameLabel.scrollSpeed = 30; // pixels per second
    self.nameLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
    self.nameLabel.fadeLength = 12.f; // length of the left and right edge fade, 0 to disable
    
    if ([AFSoundManager sharedManager].player.rate == 1.0) {
        [self changeToPause];
    } else {
        [self changeToPlay];
    }
    
    [self updateLabels];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                repeats:YES];
    self.scrubbing = NO;

}

-(void)viewDidAppear:(BOOL)animated
{
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
    [[Playlist sharedInstance] removeObserver:self forKeyPath:@"currentTrackNumber"];
    [self resignFirstResponder];
}


#pragma mark - helpers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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
    switch (status) {
        case AFSoundManagerStatusPlaying:
            [self changeToPause];
            break;
        
        case AFSoundManagerStatusPaused:
            [self changeToPlay];
            break;
        
        case AFSoundManagerStatusFinished:

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
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm:ss"];
    NSDictionary* infoForCurrentPlaying = [[AFSoundManager sharedManager] gpi_getPlayerInfo];
    NSTimeInterval elapsedTime = [[infoForCurrentPlaying objectForKey:@"elapsed time"] doubleValue];
    NSTimeInterval timeRemaining = [[infoForCurrentPlaying objectForKey:@"remaining time"] doubleValue];
    NSTimeInterval duration = [[infoForCurrentPlaying objectForKey:@"duration"] doubleValue];
    
    int percentage = (int)((elapsedTime * 1000)/duration);
    
    NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
    self.timeLabel.text = [formatter stringFromDate:elapsedTimeDate];
    
    NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
    if (timeRemaining < 0) //не прогрузилось
    {
        self.timeEndLabel.text = @"00:00";
    }
    else
    {
        self.timeEndLabel.text = [formatter stringFromDate:timeRemainingDate];
    }
    if (!self.scrubbing) {
     		   self.seekSlider.value = percentage * 0.001;
    }
    if (percentage == 1000) {
        [self playNextTrack];
    }
}



#pragma mark - IBActions


- (IBAction)playButtonPressed:(UIButton *)sender {
    if ([AFSoundManager sharedManager].status != AFSoundManagerStatusPlaying) {
        [[AFSoundManager sharedManager] resume];
    }
    else
    {
        [[AFSoundManager sharedManager] pause];

    }
    [self updateTime:nil];
    
}

- (IBAction)nextButtonPressed:(UIButton *)sender
{
    [self playNextTrack];
}

- (IBAction)previousButtonPressed:(UIButton *)sender
{
    [self playPreviousTrack];
}

- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}

- (IBAction)setCurrentTime:(id)scrubber {
    [[AFSoundManager sharedManager]moveToSection:self.seekSlider.value];

    self.scrubbing = FALSE;
}

@end
