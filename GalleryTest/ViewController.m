//
//  ViewController.m
//  GalleryTest
//
//  Created by Jonathan McAllister on 14/03/2012.
//  Copyright (c) 2012 Vertic. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize scrollView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [singleTapRecognizer setDelaysTouchesEnded:YES];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    [self.scrollView addGestureRecognizer:singleTapRecognizer];
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - Gesture Recognizer

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    BOOL hide = !sharedApplication.statusBarHidden;
    [sharedApplication setStatusBarHidden:hide withAnimation:UIStatusBarAnimationFade];
    [UIView beginAnimations:nil context:nil];
    [self.navigationController.navigationBar setAlpha:hide ? 0.0f : 1.0f];
    [UIView commitAnimations];
}

- (void)animationDone:(id)sender
{
    
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    
}



@end
