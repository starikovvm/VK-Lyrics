//
//  VSLyricsDownloader.m
//  VK simple client
//
//  Created by Виктор Стариков on 20.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "VSLyricsDownloader.h"

static BOOL foundLyricInURL;
static NSString* tempLyrics;

@implementation VSLyricsDownloader


+(VSLyricsDownloader *) sharedInstance
{
    static VSLyricsDownloader * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[VSLyricsDownloader alloc] init];
    });
    
    return _sharedInstance;
}

-(void)getLRCForTitle:(NSString*)title artist:(NSString*)artist
{
    self.LRCLyrics = nil;
    self.plainTextLyrics = nil;
    self.offset = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* lyricsString = nil;
        NSData* listData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://geci.me/api/lyric/%@/%@",[title stringByReplacingOccurrencesOfString:@" " withString:@"%20"],[artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]]];
        if (listData) {
            NSError* error;
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:listData options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
                return;
            }
            if (dict[@"result"]) {
                NSArray* result = dict[@"result"];
                if (result.count > 0) {
                    NSData* lyricsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:result[0][@"lrc"]]];
                    if (lyricsData) {
                        lyricsString = [NSString stringWithUTF8String:[lyricsData bytes]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self parseLRC:lyricsString];
                        });
                    }
                }
            }
        }
        if (!lyricsString) {
            [self getPlainTextLyricsForTitle:title artist:artist];
        } else if ([lyricsString isEqualToString:@""]){
            [self getPlainTextLyricsForTitle:title artist:artist];
        } else {
            //LRC lyrics found
        }
    });
}


-(void)parseLRC:(NSString*)LRCString
{
    if (![LRCString containsString:@":"] || ![LRCString containsString:@"["]) {
        NSLog(@"It is not an LRC file");
        [self.delegate didRecievePlainTextLyrics:LRCString];
        return;
    }
    self.offset = 0;
    NSArray * lines = [LRCString componentsSeparatedByString:@"\n"];
    NSMutableArray* LRCArray = [[NSMutableArray alloc] init];
    [lines enumerateObjectsUsingBlock:^(NSString * line, NSUInteger idx, BOOL *stop) {
        NSScanner * scanner = [NSScanner scannerWithString:line];
        NSString * scannedString;
        [scanner scanString:@"[" intoString:&scannedString];
        NSMutableArray *keys = [NSMutableArray array];

        BOOL needToContinue = NO;
        while (scannedString) {
            NSString * key;
            [scanner scanUpToString:@"]" intoString:&key];
            if ([key hasPrefix:@"ti:"] || [key hasPrefix:@"title:"]) {
                //title
                break;
            }
            else if ([key hasPrefix:@"ar:"] || [key hasPrefix:@"artist:"]) {
                //artist
                break;
            }
            else if ([key hasPrefix:@"al:"] || [key hasPrefix:@"album:"]) {
                //album
                break;
            }
            else if ([key hasPrefix:@"by:"]) {
                //author
                break;
            }
            else if ([key hasPrefix:@"ve:"]) {
                //version
                break;
            }
            else if ([key hasPrefix:@"offset:"]) {
                self.offset = [[key substringFromIndex:7] floatValue] * 0.001;
                NSLog(@"Offset is %f",[[key substringFromIndex:7] floatValue] * 0.001);
                break;
            }
            else if ([key hasPrefix:@"length:"]) {
                //length
                break;
            }
            else {
                needToContinue = YES;
                if (key) [keys addObject:key];
            }
            scannedString = nil;
            scanner.scanLocation += 1;
            [scanner scanString:@"[" intoString:&scannedString];
        }
        if (needToContinue) {
            NSString * value = [line substringFromIndex:scanner.scanLocation];
            
            NSDateFormatter* formatterMS = [[NSDateFormatter alloc] init];
            [formatterMS setDateFormat:@"mm:ss.SS"];
            NSDateFormatter* formatterS = [[NSDateFormatter alloc] init];
            [formatterS setDateFormat:@"mm:ss"];

            value = value ?: @"";
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

            [keys enumerateObjectsUsingBlock:^(NSString * timeline, NSUInteger idx, BOOL *stop) {
                NSDate* date = [formatterMS dateFromString:timeline];
                if (!date) {
                    date = [formatterS dateFromString:timeline];
                }
                if (date) {
                    NSTimeInterval time = [date timeIntervalSinceDate:[formatterS dateFromString:@"00:00"]];
                    NSArray* arr = @[@(time+self.offset),value];
                    if (arr) [LRCArray addObject:arr];
                }
            }];
        }
    }];
    if (LRCArray) {
        self.LRCLyrics = LRCArray;
        [self.delegate didRecieveLRC:self.LRCLyrics];
    }
}


-(void)getPlainTextLyricsForTitle:(NSString*)title artist:(NSString*)artist
{
    NSURL* lyricsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=%@&song=%@",[artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"],[title stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:lyricsURL];
    parser.delegate = self;
    [parser parse];
    if (!parser) {
        [self.delegate didNotRecieveLyrics];
    }
}

#pragma mark - NSXMLParserDelegate

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
    tempLyrics = @"";
}
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    if (![tempLyrics isEqualToString:@""]) {
        self.plainTextLyrics = tempLyrics;
        [self.delegate didRecievePlainTextLyrics:self.plainTextLyrics];
    } else {
        [self.delegate didNotRecieveLyrics];
    }
}
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error during parsing: %@",parseError);
    [self.delegate didNotRecieveLyrics];
}
- (void) parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"Error during validation: %@",validationError);
    [self.delegate didNotRecieveLyrics];
}


- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Lyric"])
    {
        foundLyricInURL = YES;
    } else foundLyricInURL = NO;
}



- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
    foundLyricInURL = NO;
}


- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (foundLyricInURL) {
        tempLyrics = [NSString stringWithFormat:@"%@%@",tempLyrics,string];
    }
}
@end
