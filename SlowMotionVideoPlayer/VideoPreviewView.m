/*
 
 VideoPreviewView.m
 SlowMotionVideoPlayer
 
 Created by Natili, Giorgio on 3/25/16.
 Copyright © 2016 Natili, Giorgio. All rights reserved.

 Abstract:
 Application preview view.
 
*/

@import AVFoundation;

#import "VideoPreviewView.h"

@implementation VideoPreviewView

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
	AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
	return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
	AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
	previewLayer.session = session;
}

@end
