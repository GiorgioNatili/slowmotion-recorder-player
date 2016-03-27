//
//  VideoUtils.h
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/26/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

@import AVFoundation;
#import <Foundation/Foundation.h>

@interface VideoUtils : NSObject

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device;
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position;
- (NSURL *)localFileURL:(NSString *)withFileName;
@end
