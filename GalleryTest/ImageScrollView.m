//
//  ImageScrollView.m
//  Leo-My-Psoriasis
//
//  Created by Jonathan McAllister on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageScrollView.h"
#import "TilingView.h"

@implementation ImageScrollView
@synthesize index;


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#define ZOOM_STEP 2

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    float newScale;
    if (self.zoomScale < self.maximumZoomScale) {
        newScale = self.zoomScale * ZOOM_STEP;
    } else {
        newScale = self.minimumZoomScale;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:imageView]];
    [self zoomToRect:zoomRect animated:YES];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

#pragma mark - Override layoutSubviews to center content

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen

    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    imageView.frame = frameToCenter;
    
    if ([imageView isKindOfClass:[TilingView class]]) {
        // to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
        // tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
        // which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
        imageView.contentScaleFactor = 1.0;
    }
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

#pragma mark -
#pragma mark Configure scrollView to display new image (tiled or not)

- (void)displayTiledImageNamed:(NSString *)imageName size:(CGSize)imageSize
{
    // clear the previous imageView
    [imageView removeFromSuperview];
    imageView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new TilingView for the new image
    imageView = [[TilingView alloc] initWithImageName:imageName size:imageSize];
    //[(TilingView *)imageView setAnnotates:YES]; // ** remove this line to remove the white tile grid **
    [self addSubview:imageView];
    
    [self configureForImageSize:imageSize];
}

- (void)configureForImageSize:(CGSize)imageSize 
{
    CGSize boundsSize = [self bounds].size;

    // set up our content size and min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];

    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
        
    self.contentSize = imageSize;
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;  // start out with the content fully visible
}

@end
