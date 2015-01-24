//
//  PlayerViewController.h
//  VK simple client
//
//  Created by Виктор Стариков on 07.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

//#import "AFSoundManager.h"
#import "CBAutoScrollLabel.h"
#import "Song.h"
#import "VSLyricsView.h"

@interface PlayerViewController : UIViewController <VSLyricsViewDelegate>
- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)nextButtonPressed:(UIButton *)sender;
- (IBAction)previousButtonPressed:(UIButton *)sender;
- (IBAction)toggleRepeat:(UIButton *)sender;
- (IBAction)addSong:(UIButton *)sender;
- (IBAction)toggleShuffle:(UIButton *)sender;

-(void)addToPlaylist:(NSArray*)array;
-(void)addToPlaylist:(NSArray*)array andPlayTrack:(int)trackNumber;


@property (strong, nonatomic) IBOutlet CBAutoScrollLabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UISlider *seekSlider;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeEndLabel;
@property (strong, nonatomic) IBOutlet VSLyricsView *lyricsView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (strong, nonatomic) IBOutlet UIButton *repeatButton;
@property (strong, nonatomic) IBOutlet UIButton *shuffleButton;

@property (nonatomic) int currentTrackNumber;
@property (strong, nonatomic) Song* currentSong;


@property BOOL scrubbing;

@property NSTimer *timer;


@end
