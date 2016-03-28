//
//  Video+CoreDataProperties.h
//  SlowMotionVideoPlayer
//
//  Created by Natili, Giorgio on 3/28/16.
//  Copyright © 2016 Natili, Giorgio. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Video.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
