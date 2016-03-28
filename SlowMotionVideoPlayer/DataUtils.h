//
//  DataUtils.h
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/28/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataUtils : NSObject
- (UIImage *)generateThumbnailIconForVideoFileWith:(NSURL *)contentURL WithSize:(CGSize)size;
@end
