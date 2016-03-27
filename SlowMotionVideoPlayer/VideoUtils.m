//
//  VideoUtils.m
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/26/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

@import AVFoundation;
#import "VideoUtils.h"

@implementation VideoUtils

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {

    if ( device.hasFlash && [device isFlashModeSupported:flashMode] ) {
        
        NSError *error = nil;
        
        if ( [device lockForConfiguration:&error] ) {
            
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (NSURL *)localFileURL:(NSString *)withFileName {
 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *videosDirectory = [paths objectAtIndex:0];

    NSString *outputFilePath = [videosDirectory stringByAppendingPathComponent:withFileName];
    
    return [NSURL fileURLWithPath:outputFilePath];
    
}

@end


