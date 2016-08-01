//
//  PhotoInfo.m
//  MyPhotoFlickr
//
//  Created by Aparna on 7/29/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import "PhotoInfo.h"

@implementation PhotoInfo
-(id)initWithPhotoDetailsDict:(NSDictionary *)dict {
    self = [super init];
    if (self)
    {
        self.photoTitle = [dict valueForKey:@"title"];
        self.photoId = [dict valueForKey:@"id"];
        self.thumbnailImageURL = [dict valueForKey:@"url_t"];
    }
    return self;

}

@end
