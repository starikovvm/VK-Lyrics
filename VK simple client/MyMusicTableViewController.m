//
//  MyMusicTableViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 09.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "MyMusicTableViewController.h"
#import "PlayerViewController.h"
#import "Song.h"
#import "Playlist.h"
#import "SongCell.h"
#define LOADED_COUNT 100


@interface MyMusicTableViewController () <UISearchBarDelegate>

@end

static NSString* currentUserId;
static int audioTotalCount;
static int pagesTotalCount;
static UILabel *notLoadingLabel;

@implementation MyMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 0;
    self.isLoading = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadMusic) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.leftBarButtonItem.title = @"Выйти";
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.searchBar.delegate = self;
    self.isSearching = NO;
    [self loadMusicForPage:self.page];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
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
    if (self.isSearching) {
        [self searchMusicWithQuery:self.searchQuery forPage:page];
    } else {
        if (!currentUserId) {
            [[[VKApi users] get] executeWithResultBlock:^(VKResponse *response) {
                currentUserId = [[response.json objectAtIndex:0] objectForKey:@"id"];
                [self loadMusicWithUserID:currentUserId forPage:page];
            } errorBlock:^(NSError *error) {
                NSLog(@"An error occured: %@",error.description);
                [self.tableView reloadData];
            }];
        }
        if (!self.isLoading && currentUserId) {
            [self loadMusicWithUserID:currentUserId forPage:page];
        }
    }
}

-(void)loadMusicWithUserID:(NSString*)userID forPage:(int)page
{
    if (!self.isLoading && currentUserId) {
        self.isLoading = YES;
        NSNumber* offset = [NSNumber numberWithInt:(page*LOADED_COUNT)];
        
        VKRequest * audioReq = [VKApi requestWithMethod:@"audio.get" andParameters:@{VK_API_USER_ID : userID, VK_API_COUNT : @(LOADED_COUNT),VK_API_OFFSET : offset} andHttpMethod:@"GET"];
        [self loadMusicWithRequest:audioReq];
    }

}

-(void)searchMusicWithQuery:(NSString*)query forPage:(int)page
{
    if (!self.isLoading) {
        self.isLoading = YES;
        NSNumber* offset = [NSNumber numberWithInt:(page*LOADED_COUNT)];
        
        VKRequest* audioReq = [VKRequest requestWithMethod:@"audio.search" andParameters:@{@"q" : query, @"autocomplete" : @(1), VK_API_COUNT : @(LOADED_COUNT),VK_API_OFFSET : offset, VK_API_SORT : @(2)} andHttpMethod:@"GET"];
        [self loadMusicWithRequest:audioReq];
    }
}

-(void)loadMusicWithRequest:(VKRequest*)audioReq
{
    [audioReq executeWithResultBlock:^(VKResponse *response)
     {
         audioTotalCount = [[response.json objectForKey:VK_API_COUNT] intValue];
         pagesTotalCount = ceilf((float)audioTotalCount/LOADED_COUNT); //количество страниц
         for (NSDictionary* songDict in [response.json objectForKey:@"items"])
         {
             Song* song = [[Song alloc] initWithJSON:songDict];
             [self.musicArray addObject:song];
             [notLoadingLabel removeFromSuperview];
         }
         self.isLoading = NO;
         [self.tableView reloadData];
     } errorBlock:^(NSError *error) {
         NSLog(@"ERROR! %@",error.description);
         [self.tableView reloadData];
         self.isLoading = NO;
     }];

}

-(void)reloadMusic
{
    NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
    self.musicArray = emptyArray;
    self.page = 0;
    [self loadMusicForPage:self.page];
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.musicArray.count == 0) {
        notLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
        notLoadingLabel.numberOfLines = 0;
        notLoadingLabel.textColor = [UIColor blackColor];
        notLoadingLabel.font = [UIFont fontWithName:@"Helvetica-Italic" size:16.0];
        [notLoadingLabel setTextAlignment:NSTextAlignmentCenter];
        [notLoadingLabel setText:@"Произошла ошибка загрузки.\n Потяните вниз, чтобы обновить."];
        [notLoadingLabel sizeToFit];
        self.tableView.backgroundView = notLoadingLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.page+1 >= pagesTotalCount)
        return self.musicArray.count;
    else
        return self.musicArray.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > self.musicArray.count) {
        SongCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"songCell" forIndexPath:indexPath];
        cell.title.text = @"";
        cell.subtitle.text = @"";
        cell.length.text = @"";
        return cell;
    } else
    if (indexPath.row == self.musicArray.count)
    {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"refresh" forIndexPath:indexPath];
        return cell;
    }
    else
    {
        SongCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"songCell" forIndexPath:indexPath];
        cell.title.text = ((Song*)[self.musicArray objectAtIndex:indexPath.row]).title;
        cell.subtitle.text = ((Song*)[self.musicArray objectAtIndex:indexPath.row]).artist;
        int duration = ((Song*)[self.musicArray objectAtIndex:indexPath.row]).duration;
        cell.length.text = [NSString stringWithFormat:@"%i:%02i",duration/60,duration%60];
        return cell;
    }
    return nil;
}



#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqual:@"refresh"])
    { //Загрузить еще...
        if (self.page+1 < pagesTotalCount)
        {
            self.page++;
            [self loadMusicForPage:self.page];
        }
    } else
    {
        [Playlist sharedInstance].array = self.musicArray;
        [self performSegueWithIdentifier:@"musicListToPlayerSegue" sender:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[PlayerViewController class]]) {
        if ([sender isKindOfClass:[NSIndexPath class]])
        {
            PlayerViewController *destination = segue.destinationViewController;
            [destination addToPlaylist:self.musicArray andPlayTrack:(int)[sender row]];
        }
    }
}

#pragma mark - Search bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.musicArray = [NSMutableArray new];
    self.page = 0;
    if ([searchBar.text isEqualToString:@""]) {
        self.isSearching = NO;
        [self loadMusicForPage:self.page];
    } else {
        self.isSearching = YES;
        self.searchQuery = searchBar.text;
        [self searchMusicWithQuery:self.searchQuery forPage:self.page];
        NSLog(@"Searching %@",self.searchQuery);
    }
    [self.view endEditing:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.isSearching = NO;
    self.musicArray = [NSMutableArray new];
    self.page = 0;
    [self loadMusicForPage:self.page];
    [self.view endEditing:YES];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

/*
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
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (self.isSearching || indexPath.row >= self.musicArray.count) return NO;
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



@end
