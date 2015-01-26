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
#import "VKSdk.h"


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
    [self.seekSlider setMinimumTrackImage:[UIImage imageNamed:@"transparentTrackImage.png"] forState:UIControlStateNormal];
    [self.seekSlider setMaximumTrackImage:[UIImage imageNamed:@"transparentTrackImage.png"] forState:UIControlStateNormal];

    MPVolumeView* volumeBar = [[MPVolumeView alloc] initWithFrame:CGRectMake(45, self.view.bounds.size.height-34, self.view.bounds.size.width-90, 30)];
    [volumeBar setShowsVolumeSlider:YES];
    [volumeBar setShowsRouteButton:YES];
    [volumeBar setBackgroundColor:[UIColor clearColor]];
    [volumeBar setVolumeThumbImage:[UIImage imageNamed:@"thumbVolumeBar.png"] forState:UIControlStateNormal];
    [volumeBar setMinimumVolumeSliderImage:[UIImage imageNamed:@"minTrackImageVolume.png"] forState:UIControlStateNormal];
    [volumeBar setMaximumVolumeSliderImage:[UIImage imageNamed:@"maxTrackImageVolume.png"] forState:UIControlStateNormal];
    [self.view addSubview:volumeBar];
    self.lyricsView.LRCTextFont = [UIFont fontWithName:@"Helvetica Neue" size:22.0f];
    self.lyricsView.LRCTextColor = [UIColor colorWithWhite:0.325 alpha:1.000];
    self.lyricsView.textColor = [UIColor colorWithWhite:0.325 alpha:1.000];
    self.lyricsView.delegate = self;
    
    UIBarButtonItem* playListButton = [[UIBarButtonItem alloc] initWithTitle:@"Плейлист" style:UIBarButtonItemStylePlain target:self action:@selector(goToPlaylist)];
    
    self.navigationItem.rightBarButtonItem = playListButton;
    
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
    [self updateLabels];
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
        if (currentSong) {
            [self.nameLabel setText:currentSong.title refreshLabels:YES];
            [self.artistLabel setText:currentSong.artist];
            [self.lyricsView getLyricsForTitle:currentSong.title artist:currentSong.artist];
            
        }
    });
}

-(BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}
-(void)updateTime:(NSTimer *)timer;
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm:ss"];
    
    NSDictionary* infoForCurrentPlaying = [PlayController sharedInstance].currentPlayingInfo;
    NSTimeInterval elapsedTime = [[infoForCurrentPlaying objectForKey:@"elapsed time"] doubleValue];
    NSTimeInterval timeRemaining = [[infoForCurrentPlaying objectForKey:@"remaining time"] doubleValue];
    NSTimeInterval duration = [[infoForCurrentPlaying objectForKey:@"duration"] doubleValue];
    NSTimeInterval downloadedTime = [[PlayController sharedInstance] availableDuration];
    
    Song* currentSong = [[Playlist sharedInstance] currentSong];
    if (currentSong) {
        
        NSDictionary* nowPlayingDictionary = @{MPMediaItemPropertyTitle:currentSong.title,
                                               MPMediaItemPropertyArtist:currentSong.artist,
                                               MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:duration],
                                               MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:elapsedTime]};
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingDictionary];
    }
    
    
    float percentage = elapsedTime/duration;
    float downloadedPercentage = downloadedTime/duration;
    
    NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
    self.timeLabel.text = [formatter stringFromDate:elapsedTimeDate];
    
    NSDate *timeRemainingDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining];
    
    if (timeRemaining < 0) //не прогрузилось
    {
        self.timeEndLabel.text = @"-00:00";
        self.downloadProgressView.progress = 0;
    }
    else
    {
        self.downloadProgressView.progress = downloadedPercentage;
        self.timeEndLabel.text = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:timeRemainingDate]];
    }
    
    if (!self.scrubbing) self.seekSlider.value = percentage;
    
    if ([[PlayController sharedInstance] isPlaying])
        [self changeToPause];
    else
        [self changeToPlay];
    
    if ([PlayController sharedInstance].repeatEnabled)
        [self.repeatButton setImage:[UIImage imageNamed:@"repeatEnabled"] forState:UIControlStateNormal];
    else
        [self.repeatButton setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
    
    if ([PlayController sharedInstance].shuffleEnabled)
        [self.shuffleButton setImage:[UIImage imageNamed:@"shuffleEnabled"] forState:UIControlStateNormal];
    else
        [self.shuffleButton setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
}


#pragma mark - VSLyricsViewDelegate

-(NSTimeInterval)currentTime{
    return [[PlayController sharedInstance] currentTime];
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

- (IBAction)toggleRepeat:(UIButton *)sender {
    if ([PlayController sharedInstance].repeatEnabled) {
        [PlayController sharedInstance].repeatEnabled = NO;
        [self.repeatButton setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
    } else {
        [PlayController sharedInstance].repeatEnabled = YES;
        [self.repeatButton setImage:[UIImage imageNamed:@"repeatEnabled"] forState:UIControlStateNormal];
    }
}

- (IBAction)addSong:(UIButton *)sender {
    VKRequest* addRequest = [VKRequest requestWithMethod:@"audio.add" andParameters:@{@"audio_id" : @([[Playlist sharedInstance] currentSong].songId), @"owner_id" : @([[Playlist sharedInstance] currentSong].ownerId)} andHttpMethod:@"GET"];
    [addRequest executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Success!");
        UIImageView* successImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"successMark"]];
        successImageView.frame = CGRectMake(self.view.bounds.size.width/2-55, self.view.bounds.size.height/2-55, 110, 110);
        [self.view addSubview:successImageView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
            [successImageView removeFromSuperview];
        } repeats:NO];
    } errorBlock:^(NSError *error) {
        NSLog(@"ERROR! %@",error.description);
    }];
    
}

- (IBAction)toggleShuffle:(UIButton *)sender {
    [[PlayController sharedInstance] toggleShuffle];
    if ([PlayController sharedInstance].shuffleEnabled) {
        [self.shuffleButton setImage:[UIImage imageNamed:@"shuffleEnabled"] forState:UIControlStateNormal];
    } else {
        [self.shuffleButton setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
    }
}

- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}

- (IBAction)setCurrentTime:(id)scrubber {
    [[AFSoundManager sharedManager]moveToSection:self.seekSlider.value];
    self.scrubbing = FALSE;
}

-(void)goToPlaylist{
    [self performSegueWithIdentifier:@"toPlaylistSegue" sender:self];
}

@end
