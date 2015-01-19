//
//  PlayerViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 07.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "PlayerViewController.h"
#import "Playlist.h"
//#import "AFSoundManager+getPlayerInfo.h"
#import "PlayController.h"

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
    [self.nameLabel observeApplicationNotifications];
    [self.seekSlider setMinimumTrackImage:[UIImage imageNamed:@"minTrackImage.png"] forState:UIControlStateNormal];
    [self.seekSlider setMaximumTrackImage:[UIImage imageNamed:@"maxTrackImage.png"] forState:UIControlStateNormal];
//    MPVolumeView* volumeBar = [[MPVolumeView alloc] initWithFrame:CGRectMake(self.volumeView.bounds.origin.x, self.volumeView.bounds.origin.y, self.volumeView.bounds.size.width, self.volumeView.bounds.size.height)];
    MPVolumeView* volumeBar = [[MPVolumeView alloc] initWithFrame:CGRectMake(45, self.view.bounds.size.height-34, self.view.bounds.size.width-90, 30)];
    [volumeBar setShowsVolumeSlider:YES];
    [volumeBar setShowsRouteButton:YES];
    [volumeBar setBackgroundColor:[UIColor clearColor]];
    [volumeBar setVolumeThumbImage:[UIImage imageNamed:@"thumbVolumeBar.png"] forState:UIControlStateNormal];
    [volumeBar setMinimumVolumeSliderImage:[UIImage imageNamed:@"minTrackImageVolume.png"] forState:UIControlStateNormal];
    [volumeBar setMaximumVolumeSliderImage:[UIImage imageNamed:@"maxTrackImageVolume.png"] forState:UIControlStateNormal];
//    [volumeBar sizeToFit];
    [self.view addSubview:volumeBar];
    
    [self updateLabels];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                repeats:YES];
    self.scrubbing = NO;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[Playlist sharedInstance] addObserver:self forKeyPath:@"currentTrackNumber" options:NSKeyValueObservingOptionNew context:nil];
//    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[Playlist sharedInstance] removeObserver:self forKeyPath:@"currentTrackNumber"];
//    [self resignFirstResponder];
}

-(void)dealloc
{
    [[Playlist sharedInstance] removeObserver:self forKeyPath:@"currentTrackNumber"];
}

#pragma mark - helpers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentTrackNumber"]) {
        [self updateLabels];
    }
}

-(void)addToPlaylist:(NSArray *)array
{
    [[PlayController sharedInstance] addToPlaylist:array];
}

-(void)addToPlaylist:(NSArray*)array andPlayTrack:(int)trackNumber
{
    [[PlayController sharedInstance] addToPlaylist:array andPlayTrack:trackNumber];
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
        Song* currentSong = [[Playlist sharedInstance] currentSong];
        [self.nameLabel setText:currentSong.title refreshLabels:YES];
        [self.artistLabel setText:currentSong.artist];
//        int duration = [[Playlist sharedInstance] currentSong].duration;
//        self.timeEndLabel.text = [NSString stringWithFormat:@"-%i:%02i",duration/60,duration%60];
    });
}

-(void)updateTime:(NSTimer *)timer;
{
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm:ss"];
//    NSDictionary* infoForCurrentPlaying = [[AFSoundManager sharedManager] gpi_getPlayerInfo];
    NSDictionary* infoForCurrentPlaying = [PlayController sharedInstance].currentPlayingInfo;
    NSTimeInterval elapsedTime = [[infoForCurrentPlaying objectForKey:@"elapsed time"] doubleValue];
    NSTimeInterval timeRemaining = [[infoForCurrentPlaying objectForKey:@"remaining time"] doubleValue];
    NSTimeInterval duration = [[infoForCurrentPlaying objectForKey:@"duration"] doubleValue];
    
    Song* currentSong = [[Playlist sharedInstance] currentSong];
    
    NSDictionary* nowPlayingDictionary = @{MPMediaItemPropertyTitle:currentSong.title,
                                           MPMediaItemPropertyArtist:currentSong.artist,
                                           MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:duration],
                                           MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:elapsedTime]};
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingDictionary];
    
    int percentage = (int)((elapsedTime * 1000)/duration);
    
    NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
    self.timeLabel.text = [formatter stringFromDate:elapsedTimeDate];
    
    NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
    if (timeRemaining < 0) //не прогрузилось
    {
        self.timeEndLabel.text = @"-00:00";
    }
    else
    {
        self.timeEndLabel.text = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:timeRemainingDate]];
    }
    if (!self.scrubbing) {
     		   self.seekSlider.value = percentage * 0.001;
    }
    if ([[PlayController sharedInstance] isPlaying]) {
        [self changeToPause];
    } else {
        [self changeToPlay];
    }
}



#pragma mark - IBActions


- (IBAction)playButtonPressed:(UIButton *)sender {
    [[PlayController sharedInstance] togglePlayPause];
    [self updateTime:nil];
    
}

- (IBAction)nextButtonPressed:(UIButton *)sender
{
    [[PlayController sharedInstance] playNextTrack];
}

- (IBAction)previousButtonPressed:(UIButton *)sender
{
    [[PlayController sharedInstance] playPreviousTrack];
}

- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}

- (IBAction)setCurrentTime:(id)scrubber {
    [[AFSoundManager sharedManager]moveToSection:self.seekSlider.value];
    self.scrubbing = FALSE;
}

@end
