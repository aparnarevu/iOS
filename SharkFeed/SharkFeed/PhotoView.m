//
//  PhotoView.m
//  SampleAPI
//
//  Created by Aparna on 7/29/16.
//  Copyright © 2016 OrangePeople. All rights reserved.
//

#import "PhotoView.h"

@implementation PhotoView

-(id)initWithFrame:(CGRect)rect{
    self = [super init];
    if (self)
    {

    }
    return self;
    
}
-(void)awakeFromNib {
    self.userInteractionEnabled = YES;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
