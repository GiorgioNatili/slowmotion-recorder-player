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

- (void)switchSession:(AVCaptureSession *)captureSession toDesiredFPS:(CGFloat)desiredFPS {
    
    BOOL isRunning = captureSession.isRunning;
    
    if (isRunning)  [captureSession stopRunning];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            
            NSLog(@"selected format:%@", selectedFormat);
            
            videoDevice.activeFormat = selectedFormat;
            
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            
            [videoDevice unlockForConfiguration];
        }
    }
    
    if (isRunning) [captureSession startRunning];
    
}

- (void)scaleTimeRange:(CMTimeRange)timeRange toDuration:(CMTime)duration{

    AVURLAsset* videoAsset = nil; //self.inputAsset;
    
    //create mutable composition
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *videoInsertError = nil;
    BOOL videoInsertResult = [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                                            ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                             atTime:kCMTimeZero
                                                              error:&videoInsertError];
    if (!videoInsertResult || nil != videoInsertError) {
        //handle error
        return;
    }
    
    //slow down whole video by 2.0
    double videoScaleFactor = 2.0;
    CMTime videoDuration = videoAsset.duration;
    
    [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
                               toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
    
    //export
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                         presetName:AVAssetExportPresetLowQuality];
    
}


@end


