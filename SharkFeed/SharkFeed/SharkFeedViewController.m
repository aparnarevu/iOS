//
//  SharkFeedViewController.m
//  SharkFeed
//
//  Created by Aparna on 7/31/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import "SharkFeedViewController.h"
#import "PhotoView.h"
#import "PhotoInfo.h"
#import "PhotoDetailsViewController.h"
#import "Constants.h"

@interface SharkFeedViewController ()
{
    UIRefreshControl *refreshControl;
    int totalPages;
    NSTimer *timer;
    BOOL isAnimating;
    int totalNoOfPages;
    UIStoryboard *storyBoard;

}
@end

@implementation SharkFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:kNavigationBarBackgroundImage]
                                                  forBarMetrics:UIBarMetricsDefault];

    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSharkFeedLogo]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 104, 16)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];

    self.navigationItem.titleView = titleView;

    storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    [self loadRefreshControl];
    isAnimating= false;
    self.photoList = [[NSMutableArray alloc] init];
    [self downloadPhotosFromFlickrForPage:1];

    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return  (self.photoList.count > 0) ? self.photoList.count : 30;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell
    if(self.photoList.count == 0){
        return cell;
    }

    PhotoInfo *photo = [self.photoList objectAtIndex:indexPath.row];

    NSURL *url = [NSURL URLWithString:photo.thumbnailImageURL];

    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UICollectionViewCell *updateCell = (id)[collectionView cellForItemAtIndexPath:indexPath];
                    PhotoInfo *photoInfo = [self.photoList objectAtIndex:indexPath.row];

                    if (updateCell) {
                        PhotoView *cellImageView = (PhotoView *)[updateCell viewWithTag:1001];
                        cellImageView.image = image;
                        cellImageView.photoId = photoInfo.photoId;
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageDetails:)];
                        tapGesture.numberOfTapsRequired =1;
                        tapGesture.delegate = self;
                        [cellImageView addGestureRecognizer:tapGesture];
                    }
                });
            }
        }
    }];

    [task resume];

    return cell;
}

-(void)loadRefreshControl
{
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];

    UIView *customView = [[[NSBundle mainBundle] loadNibNamed:@"RefreshView" owner:self options:nil] lastObject];
    customView.frame = refreshControl.bounds;
    customView.tag = 2001;
    [refreshControl addSubview:customView];

    refreshControl.backgroundColor =[UIColor clearColor];
    refreshControl.tintColor = [UIColor clearColor];
}

-(void)showImageDetails:(UIGestureRecognizer *)tapGesture
{
    PhotoView *photoView =(PhotoView *) [tapGesture view];
    PhotoDetailsViewController *detailsViewCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"PhotoDetailsViewController"];
    detailsViewCtrl.selectedPhotoId = photoView.photoId;
    [self.navigationController pushViewController:detailsViewCtrl animated:YES];

}

-(void)refershControlAction
{
    isAnimating = true;
    if(totalNoOfPages > self.currentIndex) {
        [self downloadPhotosFromFlickrForPage:self.currentIndex +1];
    }
}

-(void)downloadPhotosFromFlickrForPage:(int)pageNo
{

    NSString *flickerURLStr = [NSString stringWithFormat:@"%@%@&text=shark&format=json&nojsoncallback=1&page=%d&extras=url_t,url_c,url_l,url_o",kFlickrSearchAPI,kFlickrAPIKey,pageNo];

    NSURL *url = [NSURL URLWithString:flickerURLStr];


    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                                              NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

                                              self.currentIndex = [[[jsonData valueForKey:kFlickrTotalPhotos] valueForKey:kFlickrCurrentPage] intValue];

                                              if(self.currentIndex == 1)
                                                  totalNoOfPages = [[[jsonData valueForKey:kFlickrTotalPhotos] valueForKey:kFlickrTotalPages] intValue];

                                              [self loadPhotos:[[jsonData valueForKey:kFlickrTotalPhotos] valueForKey:kFlickrPhoto]];

                                              dispatch_async(dispatch_get_main_queue(), ^{

                                                  [CATransaction begin];
                                                  [CATransaction setCompletionBlock:^{
                                                      [refreshControl endRefreshing];

                                                      [self.collectionView reloadData];

                                                  }];

                                                  [CATransaction commit];
                                              });
                                          }];
    [downloadTask resume];
}

-(void)loadPhotos:(NSArray *)photos
{
    for(int i=0; i<photos.count; i++) {
        NSDictionary *photoDict = photos[i];
        PhotoInfo *photo = [[PhotoInfo alloc] initWithPhotoDetailsDict:photoDict];
        [self.photoList addObject:photo];
    }
    isAnimating = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(refreshControl.refreshing) {
        if(!isAnimating) {
            timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(endOfWork) userInfo:nil repeats:NO];
            
        }
    }
}

-(void)endOfWork{
    [refreshControl endRefreshing];
    [timer invalidate];
    timer = nil;
}


@end
