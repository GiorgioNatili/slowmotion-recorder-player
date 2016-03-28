/*
 VideoPreviewView.h
 SlowMotionVideoPlayer
 
 Created by Natili, Giorgio on 3/25/16.
 Copyright © 2016 Natili, Giorgio. All rights reserved.
 
 Abstract:
 Application preview view.
*/

@import UIKit;

@class AVPlayer;

@interface VideoPreviewView : UIView

@property AVPlayer *player;
@property (readonly) AVPlayerLayer *playerLayer;

@end
