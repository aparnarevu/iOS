//
//  SharkFeedViewController.h
//  SharkFeed
//
//  Created by Aparna on 7/31/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharkFeedViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic, assign) int currentIndex;
@property(nonatomic) NSMutableArray *photoList;
@property(nonatomic, weak)IBOutlet UICollectionView *collectionView;

-(void)downloadPhotosFromFlickrForPage:(int)pageNo;

@end

