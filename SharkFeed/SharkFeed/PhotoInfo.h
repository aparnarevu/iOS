//
//  PhotoInfo.h
//  MyPhotoFlickr
//
//  Created by Aparna on 7/29/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoInfo : NSObject

@property(nonatomic,copy) NSString *photoTitle;
@property(nonatomic,copy) NSString* photoId;
@property(nonatomic,copy) NSString *thumbnailImageURL;


-(id)initWithPhotoDetailsDict:(NSDictionary *)dict;
@end
