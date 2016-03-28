//
//  DataManager.m
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/28/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Video+CoreDataProperties.h"
#import "DataUtils.h"
#import "AppDelegate.h"
#import "DataManager.h"

@implementation DataManager

- (void)createVideoWithFileAtURL:(NSURL *)url withFileName:(NSString *)filename {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    Video *video = (Video *)[NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                                          inManagedObjectContext:[appDelegate managedObjectContext]];
    
    // TODO here we need just the filename not the full path
    video.path = [url absoluteString];
    video.name = filename;
    
    DataUtils *dataUtils = [[DataUtils alloc] init];
    
    UIImage *image = [dataUtils generateThumbnailIconForVideoFileWith:url WithSize: CGSizeMake(100, 100)];
    video.thumbnail = UIImagePNGRepresentation(image);
    
    [appDelegate saveContext];
    
}

- (NSArray *)fetchVideosFromDatabase {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    request.sortDescriptors = @[sortDescriptor];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Cannot fetch objects %@", error);
    } else {
        return fetchedObjects;
    }
    
    return nil;
}


@end
