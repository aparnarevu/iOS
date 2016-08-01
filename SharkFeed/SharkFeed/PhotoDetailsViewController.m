//
//  PhotoDetailsViewController.m
//  SampleAPI
//
//  Created by Aparna on 7/29/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import "PhotoDetailsViewController.h"
#import "PhotoInfo.h"
#import "Constants.h"

@interface PhotoDetailsViewController ()
{
    NSString *selectedImageURL;
    BOOL isDownloadingTheImage;
}

@end

@implementation PhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                    style:UIBarButtonItemStylePlain target:self action:nil];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSharkFeedLogo]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 104, 16)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
    isDownloadingTheImage =true;

    [self getPhotoDetails];

    // Do any additional setup after loading the view.
    [self.view bringSubviewToFront:self.detailsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Utility Methods
- (void)downloadImage:(UIImage*)image filename:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    BOOL isDownloaded = [data writeToFile:filename atomically:YES];
    if(isDownloaded) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:kDownloadSuccessMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok]; // add action to uialertcontroller
        [self presentViewController:alert animated:YES completion:nil];
    }

    
}

-(void)getPhotoDetails
{
    NSString *flickerURLStr = [NSString stringWithFormat:@"%@%@&photo_id=%@&format=json&nojsoncallback=1",kPhotoInfoAPI,kFlickrAPIKey,self.selectedPhotoId];
    isDownloadingTheImage = false;

    [self downloadData:flickerURLStr];
}

-(void)downloadData:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(isDownloadingTheImage)
        {
            if(data){
                UIImage *image = [UIImage imageWithData:data];
                if(image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.photoOriginalView.image = image;
                        isDownloadingTheImage =false;
                    });
                }
            }
        } else {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            NSDictionary *photoDict = [jsonData valueForKey:kPhoto];
            NSString *farm = [photoDict valueForKey:@"farm"];
            NSString *secret = [photoDict valueForKey:@"secret"];
            NSString *server = [photoDict valueForKey:@"server"];

            selectedImageURL = [NSString stringWithFormat:@"%@%@/%@/%@_%@.jpg",kFlickrDownloadImageAPI,farm,server,self.selectedPhotoId,secret];

            dispatch_async(dispatch_get_main_queue(), ^{

                self.labelPhotoTitle.text = [[photoDict valueForKey:@"title"] valueForKey:@"_content"];
                isDownloadingTheImage = true;
                [self downloadData:selectedImageURL];
            });
        }
    }];
    [task resume];
}
#pragma mark - Action  Methods
-(IBAction)downloadImage:(id)sender
{
    [self downloadImage:self.photoOriginalView.image filename:[selectedImageURL lastPathComponent]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
