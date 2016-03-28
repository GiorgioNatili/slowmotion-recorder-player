//
//  DataManager.h
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/28/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
- (void)createVideoWithFileAtURL:(NSURL *)url withFileName:(NSString *)filename;
- (NSArray *)fetchVideosFromDatabase;
@end
