//
//  VSLyricsView.m
//  VK simple client
//
//  Created by Виктор Стариков on 21.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "VSLyricsView.h"

@interface VSLyricsView ()

@property NSTimer* timer;

@end


@implementation VSLyricsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    
    _textView = [[UITextView alloc] initWithFrame:self.bounds];
    _textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _textView.text = @"";
    _textView.scrollEnabled = YES;
    _textView.editable = NO;
    _textView.textAlignment = NSTextAlignmentCenter;
    
    if (_font)
        self.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    if (_textColor)
        self.textColor = [UIColor colorWithWhite:0.427 alpha:1.000];

    [self addSubview:_textView];
    
    [VSLyricsDownloader sharedInstance].delegate = self;
}

-(void)getLyricsForTitle:(NSString*)title artist:(NSString*)artist
{
    self.textView.text = @"";
    _LRCArray = nil;
    [[VSLyricsDownloader sharedInstance] getLRCForTitle:title artist:artist];
}

-(void)setFont:(UIFont *)font{
    _font = font;
    _textView.font = font;
}

-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    _textView.textColor = textColor;
}

-(void)updateTextForTime:(NSTimeInterval)time{
    if (_LRCArray) {
        if (_LRCArray.count >1) {
            for (unsigned long i = 0;i<_LRCArray.count - 2;i++) {
                NSTimeInterval currentStringTime =[_LRCArray[i][0] doubleValue];
                NSTimeInterval nextStringTime = [_LRCArray[i+1][0] doubleValue];
                if (currentStringTime <= time && nextStringTime > time) {
                    self.textView.text = _LRCArray[i][1];
                    return;
                }
            }
            self.textView.text = @"";
        }
    }
}

-(void)timerAction
{
    [self updateTextForTime:[self.delegate currentTime]];
}

-(void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - VSLyricsDownloaderDelegate

-(void)didRecieveLRC:(NSArray *)lyricsArray
{
    [self startTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.scrollEnabled = NO;
        _LRCArray = lyricsArray;
    });
}
-(void)didRecievePlainTextLyrics:(NSString *)lyrics
{
    [self stopTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        _LRCArray = nil;
        _textView.text = lyrics;
        _textView.scrollEnabled = YES;
    });
}

-(void)didNotRecieveLyrics
{
    [self stopTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        _LRCArray = nil;
        _textView.text = @"";
        _textView.scrollEnabled = NO;
        NSLog(@"Did not recieve any lyrics");
    });
}

@end
