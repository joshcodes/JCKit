//
//  NSFetchedResultsController+JCCollectionViewFetchedResultsController.h
//  JCKit
//
//  Created by Josh Wingstrom on 3/21/14.
//  Copyright (c) 2014 JoshCodes. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import "JCCollectionViewFetchedResultsController.h"

@interface NSFetchedResultsController (JCCollectionViewFetchedResultsControllerCategory)
<
    JCCollectionViewFetchedResultsController,
    UICollectionViewDataSource
>

@end
