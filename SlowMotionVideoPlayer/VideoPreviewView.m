/*
 
 VideoPreviewView.m
 SlowMotionVideoPlayer
 
 Created by Natili, Giorgio on 3/25/16.
 Copyright © 2016 Natili, Giorgio. All rights reserved.

 Abstract:
 Application preview view.
 
*/

@import Foundation;
@import AVFoundation;
#import "VideoPreviewView.h"


@implementation VideoPreviewView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
