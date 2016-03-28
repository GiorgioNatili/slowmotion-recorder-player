//
//  RecordingViewController.m
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/25/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

@import AVFoundation;

#import "RecordingViewController.h"
#import "VideoUtils.h"
#import "VideoPlayerViewController.h"
#import "VideoPreviewView.h"

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
    
};

@interface RecordingViewController () <AVCaptureFileOutputRecordingDelegate> {
    AVPlayer *_player;
}

// AV capture and saving members
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

// Utilities
@property (nonatomic) VideoUtils *videoUtils;
@property (nonatomic) NSString *currentFileName;
@property (nonatomic) NSURL *currentOutputURL;

// UI items
@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UISegmentedControl *frameRate;
@property (weak, nonatomic) IBOutlet VideoPreviewView *videoPreview;

@end

@implementation RecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the videoUtils
    self.videoUtils = [[VideoUtils alloc] init];

    // Disable UI. The UI is enabled if and only if the session starts running.
    self.record.enabled = NO;
    
    // Create the AVCaptureSession.
    self.session = [[AVCaptureSession alloc] init];
    
    // Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    self.setupResult = AVCamSetupResultSuccess;
    
    self.videoPreview.playerLayer.player = self.player;
    
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] ) {
        case AVAuthorizationStatusAuthorized: {
            // The user has previously granted access to the camera.
            self.record.enabled = YES;
            break;
        }
        case AVAuthorizationStatusNotDetermined: {
            
            // The user has not yet been presentplicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                
                if ( !granted ) {
                    
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                
                self.record.enabled = granted;
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default: {
            // The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }

    // Setup the capture session.
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult != AVCamSetupResultSuccess ) {
            return;
        }
        
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [self.videoUtils deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if ( ! videoDeviceInput ) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        [self.session beginConfiguration];
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                // can only be manipulated on the main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                // -[viewWillTransitionToSize:withTransitionCoordinator:].
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                // TODO eventually handle preview
                // AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                // previewLayer.connection.videoOrientation = initialVideoOrientation;
                
            } );
        }
        else {
            NSLog( @"Could not add video device input to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if ( ! audioDeviceInput ) {
            NSLog( @"Could not create audio device input: %@", error );
        }
        
        if ( [self.session canAddInput:audioDeviceInput] ) {
            
            [self.session addInput:audioDeviceInput];
        } else {
            
            NSLog( @"Could not add audio device input to the session" );
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ( [self.session canAddOutput:movieFileOutput] ) {
            
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if ( connection.isVideoStabilizationSupported ) {
                
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            
            self.movieFileOutput = movieFileOutput;
            
        } else {
            
            NSLog( @"Could not add movie file output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        [self.session commitConfiguration];
    });

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    dispatch_async( self.sessionQueue, ^{
        switch ( self.setupResult )
        {
            case AVCamSetupResultSuccess:
            {
                // Only setup observers and start the session running if setup succeeded.
              //  [self addObservers];
                [self.session startRunning];
            //    self.sessionRunning = self.session.isRunning;
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                });
            }
        }
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVCaptureFileOutputRecordingDelegate implementation
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
                                             didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                             fromConnections:(NSArray *)connections error:(NSError *)error {
    
    self.currentOutputURL = outputFileURL;
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
                                             didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                                             fromConnections:(NSArray *)connections {
    
    dispatch_async( dispatch_get_main_queue(), ^{
        
        self.record.enabled = YES;
        [self.record setTitle:NSLocalizedString( @"Stop", @"") forState:UIControlStateNormal];
    });
    
}

#pragma mark - Private
- (void) handleFPS {
    
    NSInteger selectedIndex = self.frameRate.selectedSegmentIndex;
    
    if (selectedIndex == 0) {
        
        [self.videoUtils switchSession:self.session toDesiredFPS:30.0];
        
    } else if (selectedIndex == 1) {
        
        [self.videoUtils switchSession:self.session toDesiredFPS:60.0];
    
    } else if( selectedIndex == 2) {
        
        [self.videoUtils switchSession:self.session toDesiredFPS:240.0];
    }

    
}

- (AVPlayer *)player {
    if (!_player)
        _player = [[AVPlayer alloc] init];
    return _player;
}

#pragma mark - User Interactions
- (IBAction)recordVideo:(id)sender {
    
    UIButton *button = (UIButton*) sender;
    button.enabled = NO;
    
    [self handleFPS];
    
    dispatch_async( self.sessionQueue, ^{
        
        if ( !self.movieFileOutput.isRecording ) {
            
            // Update the orientation on the movie file output video connection before starting recording.
            AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            // Turn OFF flash for video recording.
            [self.videoUtils setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];
            
            // Start recording to a temporary file.
            NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            
            // Temporary saving the path
            self.currentFileName = [outputFileName stringByAppendingPathExtension:@"mov"];
            
            NSURL *recordingURL = [self.videoUtils localFileURL:self.currentFileName];

            [self.movieFileOutput startRecordingToOutputFileURL:recordingURL recordingDelegate:self];
            
        } else {
            
           [self.movieFileOutput stopRecording];
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                // TODO play the video
                NSString *currentMessage = [NSString stringWithFormat: @"Your wonderful file is %@, ready to play it?", self.currentFileName];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:currentMessage delegate:self cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil, nil];
                
                [alert show];
                
            });

        }
        
    });
    
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        VideoPlayerViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
        
        vc.currentFileName  = self.currentFileName;
        vc.slowMotion       = true;
        vc.currentOutputURL = self.currentOutputURL;
        
        [self presentViewController:vc animated:YES completion:nil];
        
    }
    
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
