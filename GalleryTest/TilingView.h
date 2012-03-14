//
//  TilingView.h
//  Leo-My-Psoriasis
//
//  Created by Jonathan McAllister on 06/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TilingView : UIView
{
    NSString *imageName;
}

- (id)initWithImageName:(NSString *)name size:(CGSize)size;

@end
