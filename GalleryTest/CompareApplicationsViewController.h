//
//  CompareApplicationsViewController.h
//  Leo-My-Psoriasis
//
//  Created by Jonathan McAllister on 01/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CompareApplicationsViewController;

@protocol CompareApplicationsViewControllerDelegate <NSObject>

- (void)compareApplicationsViewControllerDidCancel:(CompareApplicationsViewController *)controller;

@end


@interface CompareApplicationsViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray *applicationImages;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePagesLeft;
    NSMutableSet *visiblePagesRight;
}

@property (nonatomic, weak) id <CompareApplicationsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *applications;

@property (nonatomic, strong) IBOutlet UIScrollView *leftScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *rightScrollView;

- (IBAction)done:(id)sender;

@end
