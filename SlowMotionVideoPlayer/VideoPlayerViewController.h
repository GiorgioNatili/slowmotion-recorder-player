//
//  VideoPlayerViewController.h
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/26/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerViewController : UIViewController

@property(nonatomic)NSString *currentFileName;
@property (nonatomic, assign, getter=isSlowmotion) BOOL slowMotion;
@property(nonatomic)NSURL *currentOutputURL;

@end
