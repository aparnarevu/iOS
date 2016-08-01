//
//  PhotoDetailsViewController.h
//  SampleAPI
//
//  Created by Aparna on 7/29/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoInfo.h"
@interface PhotoDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *photoOriginalView;
@property (weak, nonatomic) IBOutlet UILabel *labelPhotoTitle;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *inAppButton;
@property(nonatomic,copy) NSString* selectedPhotoId;

-(IBAction)downloadImage:(id)sender;

@end
