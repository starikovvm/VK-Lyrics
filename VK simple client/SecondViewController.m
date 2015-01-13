//
//  SecondViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 06.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "SecondViewController.h"
#define LOADED_COUNT 50

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"VK_TOKEN"]) {
        [self performSegueWithIdentifier:@"toLoginSegue" sender:self];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    self.page = 0;
    [self loadMusicForPage:self.page];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - easy instantiation

-(NSMutableArray *)musicArray{
    if (!_musicArray) {
        _musicArray = [[NSMutableArray alloc] init];
    }
    return _musicArray;
}

#pragma mark - data loading

-(void)loadMusicForPage:(int)page
{
    if (!self.isLoading) {
        NSLog(@"Loading page %i",page);
        self.isLoading = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *friendsURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?&lang=ru&count=%i&offset=%i&access_token=%@",LOADED_COUNT,page*LOADED_COUNT,[[NSUserDefaults standardUserDefaults] objectForKey:@"VK_TOKEN"]]];
            NSData *loadedData = [NSData dataWithContentsOfURL:friendsURL];
            [self performSelectorOnMainThread:@selector(fetchData:) withObject:loadedData waitUntilDone:YES];
        });
    }
}

-(void)fetchData:(NSData*)loadedData
{
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:loadedData options:kNilOptions error:&error];
    if ([json objectForKey:@"error"] && [[[json objectForKey:@"error"] objectForKey:@"error_code"] intValue]!=6) {
        NSLog(@"%@",[json objectForKey:@"error"]);
        [self performSegueWithIdentifier:@"toLoginSegue" sender:self];
        [self loadMusicForPage:0];
    }
    else
    {
        if ([[[json objectForKey:@"error"] objectForKey:@"error_code"] intValue]==6) {
            NSLog(@"Too many loadings");
        }
        [self.musicArray addObjectsFromArray:[json objectForKey:@"response"]];
        [self.tableView setNeedsLayout];
    }
    self.isLoading = NO;
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.musicArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.musicArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [[self.musicArray objectAtIndex:indexPath.row] objectForKey:@"artist"];
    
    return cell;
}

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.player = nil;
    NSLog(@"%@ selected",[[self.musicArray objectAtIndex:indexPath.row] objectForKey:@"title"]);
    NSURL *url = [NSURL URLWithString:[[self.musicArray objectAtIndex:indexPath.row] objectForKey:@"url"]];
                  // You may find a test stream at <http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8>.
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
                  //(optional) [playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
//    self.player = [AVPlayer playerWithURL:url];
    [self.player play];
    ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = LOADED_COUNT;
    if(y > h + reload_distance)
    {
        if ([self.musicArray count]%LOADED_COUNT == 0 && !self.isLoading) {
            self.page++;
            [self loadMusicForPage:self.page];
        }
    }
}
    

@end
