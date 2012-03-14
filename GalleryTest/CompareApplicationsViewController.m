//
//  CompareApplicationsViewController.m
//  Leo-My-Psoriasis
//
//  Created by Jonathan McAllister on 01/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompareApplicationsViewController.h"
#import "ImageScrollView.h"


@implementation CompareApplicationsViewController

@synthesize delegate;
@synthesize applications;
@synthesize leftScrollView;
@synthesize rightScrollView;

+ (UIImage *)loadImage:(NSString *)name
{
    NSString *path = [NSString stringWithFormat:@"Documents/%@.jpg", name];
    NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:jpgPath]) {
        return [UIImage imageWithContentsOfFile:jpgPath];
    } else {
        NSLog(@"File (%@) does not exist", name);
    }
    return nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - IBActions

- (IBAction)done:(id)sender
{
    [delegate compareApplicationsViewControllerDidCancel:self];
}


#pragma mark - Image wrangling

- (NSUInteger)imageCount
{
    return [applicationImages count];
}

- (NSString *)imageNameAtIndex:(NSUInteger)index
{
    Note *note = [applicationImages objectAtIndex:index];
    return note.picture_id;
}

- (CGSize)imageSizeAtIndex:(NSUInteger)index
{
    Note *note = [applicationImages objectAtIndex:index];
    return CGSizeMake([note.picture_width floatValue], [note.picture_height floatValue]);
}

#pragma mark - Frame calculations
#define PADDING  10

- (CGRect)frameForPagingScrollView:(UIScrollView *)scrollView
{
    return CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    /*
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
     */
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index inScrollView:(UIScrollView *)scrollView
{
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView:scrollView];
    
    CGRect pageFrame = pagingScrollViewFrame;
    /*
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index) + PADDING;
     */
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index);
    return pageFrame;
}


#pragma mark - Tiling and page configuration

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index inSet:(NSMutableSet *)visiblePages
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index inScrollView:(UIScrollView *)scrollView
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index inScrollView:scrollView];
    
    [page displayTiledImageNamed:[self imageNameAtIndex:index] size:[self imageSizeAtIndex:index]];
}

- (void)tilePages:(UIScrollView *)scrollView
{
    NSMutableSet *visiblePages = scrollView == self.leftScrollView ? visiblePagesLeft : visiblePagesRight;
    
    // Calculate which pages are visible
    CGRect visibleBounds = scrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages 
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index inSet:visiblePages]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ImageScrollView alloc] init];
            }
            [self configurePage:page forIndex:index inScrollView:scrollView];
            [scrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }    
}


#pragma mark - ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages:scrollView];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    recycledPages = [[NSMutableSet alloc] init];
    visiblePagesLeft = [[NSMutableSet alloc] init];
    visiblePagesRight = [[NSMutableSet alloc] init];
    
    applicationImages = [[NSMutableArray alloc] init];
    for (Application *application in self.applications) {
        if (application.note != nil && application.note.picture_id != nil) {
            [applicationImages addObject:application.note];
            [applicationImages addObject:application.note];
            [applicationImages addObject:application.note];
            [applicationImages addObject:application.note];
            [applicationImages addObject:application.note];
            [applicationImages addObject:application.note];
        }
    }

    self.leftScrollView.contentSize = CGSizeMake(self.leftScrollView.frame.size.width * [self imageCount], self.leftScrollView.frame.size.height);
    self.rightScrollView.contentSize = CGSizeMake(self.rightScrollView.frame.size.width * [self imageCount], self.rightScrollView.frame.size.height);
    // Set scroll position to the far right
    CGRect farRight = CGRectMake(self.rightScrollView.frame.size.width * ([self imageCount] - 1), 0, self.rightScrollView.frame.size.width, self.rightScrollView.frame.size.height);
    self.rightScrollView.bounds = farRight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self tilePages:self.leftScrollView];
    [self tilePages:self.rightScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    leftScrollView = nil;
    rightScrollView = nil;
    recycledPages = nil;
    visiblePagesLeft = nil;
    visiblePagesRight = nil;
}



@end
