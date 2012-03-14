//
//  ImageScrollView.h
//  Leo-My-Psoriasis
//
//  Created by Jonathan McAllister on 06/02/2012.
//  Copyright (c) 2012 Vertic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate>
{
    UIView *imageView;
}

@property (assign) NSUInteger index;

- (void)displayTiledImageNamed:(NSString *)imageName size:(CGSize)imageSize;
- (void)configureForImageSize:(CGSize)imageSize;

@end
