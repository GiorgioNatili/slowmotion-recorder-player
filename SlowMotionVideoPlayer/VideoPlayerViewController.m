//
//  VideoPlayerViewController.m
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/26/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

#import "VideoPlayerViewController.h"
@import AVFoundation;
@import AVKit;

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

@synthesize currentFileName = _currentFileName;
@synthesize slowMotion = _slowMotion;
@synthesize currentOutputURL = _currentOutputURL;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Populate the UI
    
    // Create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:self.currentOutputURL];
    
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = player;
    [player play];
    
    if(self.slowMotion == true) {
        
        player.rate = 0.5;
    }
    
    // show the view controller
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    
    controller.view.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
