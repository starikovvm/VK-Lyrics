//
//  VSLyricsView.m
//  VK simple client
//
//  Created by Виктор Стариков on 21.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "VSLyricsView.h"

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
    [[VSLyricsDownloader sharedInstance] getLRCForTitle:title artist:artist];
}

-(void)setFont:(UIFont *)font{
    _textView.font = font;
}

-(void)setTextColor:(UIColor *)textColor{
    _textView.textColor = textColor;
}

#pragma mark - VSLyricsDownloaderDelegate

-(void)didRecieveLRC:(NSArray *)lyricsArray withOffset:(float)offset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.scrollEnabled = NO;
        _textView.text = @"Downloaded LRC";
    });
}
-(void)didRecievePlainTextLyrics:(NSString *)lyrics
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = lyrics;
        _textView.scrollEnabled = YES;
    });
}

-(void)didNotRecieveLyrics
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = @"";
        _textView.scrollEnabled = NO;
        NSLog(@"Did not recieve any lyrics");
    });
}

@end
