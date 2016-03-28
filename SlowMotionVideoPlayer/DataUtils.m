//
//  DataUtils.m
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/28/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

@import AVFoundation;
#import <UIKit/UIKit.h>
#import "DataUtils.h"

@implementation DataUtils

- (UIImage *)generateThumbnailIconForVideoFileWith:(NSURL *)contentURL WithSize:(CGSize)size {
    
    UIImage *theImage = nil;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize=size;
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(100,100); //change whatever you want here.
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    theImage = [[UIImage alloc] initWithCGImage:imgRef] ;
    CGImageRelease(imgRef);
    
    return theImage;
    
}

@end
