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

#import "AFSoundManager.h"
#import "CBAutoScrollLabel.h"
#import "Song.h"

@interface PlayerViewController : UIViewController <AFSoundManagerDelegate>
- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)nextButtonPressed:(UIButton *)sender;
- (IBAction)previousButtonPressed:(UIButton *)sender;

-(void)addToPlaylist:(NSArray*)array;
-(void)addToPlaylist:(NSArray*)array andPlayTrack:(int)trackNumber;


@property (strong, nonatomic) IBOutlet CBAutoScrollLabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UISlider *seekSlider;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeEndLabel;
@property (strong, nonatomic) IBOutlet UIView *lyricsView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic) int currentTrackNumber;
@property (strong, nonatomic) Song* currentSong;


@property BOOL scrubbing;

@property NSTimer *timer;


@end
