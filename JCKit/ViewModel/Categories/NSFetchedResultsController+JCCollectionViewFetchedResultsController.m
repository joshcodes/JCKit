//
//  NSFetchedResultsController+JCCollectionViewFetchedResultsController.m
//  JCKit
//
//  Created by Josh Wingstrom on 3/21/14.
//  Copyright (c) 2014 JoshCodes. All rights reserved.
//

#import "NSFetchedResultsController+JCCollectionViewFetchedResultsController.h"

@interface CollectionViewFetchedResultControllerDelegate : NSObject
<
NSFetchedResultsControllerDelegate
>
{
}

@property (nonatomic, retain) id<JCCollectionViewFetchedResultsControllerDelegate> delegate;
@property (nonatomic, retain) UICollectionView* collectionView;

-(id)initWithCollectionView:(UICollectionView*)collectionView delegate:(id<JCCollectionViewFetchedResultsControllerDelegate>)delegate;

@end

@implementation CollectionViewFetchedResultControllerDelegate

-(id)initWithCollectionView:(UICollectionView*)collectionView delegate:(id<JCCollectionViewFetchedResultsControllerDelegate>)delegate
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = delegate;
        self.collectionView = collectionView;
    }
    return self;
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            UICollectionViewCell* cell = [_collectionView cellForItemAtIndexPath:indexPath];
            [self.delegate configureCollectionCell:cell object:anObject indexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
}

@end


@implementation NSFetchedResultsController (JCCollectionViewFetchedResultsControllerCategory)

-(void)subscribeCollectionView:(UICollectionView*)collectionView delegate:(id<JCCollectionViewFetchedResultsControllerDelegate>)delegate
{
    CollectionViewFetchedResultControllerDelegate* cvFrcDelegate =
    [[CollectionViewFetchedResultControllerDelegate alloc] initWithCollectionView:collectionView delegate:delegate];
    
    NSError *eventFetchError = nil;
    if ([self performFetch:&eventFetchError] == NO) {
        NSLog(@"couldn't perform fetch:  %@", eventFetchError);
    } else {
        NSLog(@"got %lu events!  w00t!", (unsigned long)[[self fetchedObjects] count]);
        self.delegate = cvFrcDelegate;
        collectionView.dataSource = self;
    }
}

-(void)unsubscribeCollectionView:(UITableView*)tableView
{
    self.delegate = nil;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchedObjects.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Validate the appropriate delegate is being used
    NSObject* delegate = (NSObject*)self.delegate;
    if (![delegate isKindOfClass:CollectionViewFetchedResultControllerDelegate.class])
    {
        NSLog(@"FetchedResultsController is not managed by a JCCollectionViewFetchResultsController");
        return nil;
    }
    CollectionViewFetchedResultControllerDelegate* cvFrcDelegate = (CollectionViewFetchedResultControllerDelegate*)delegate;
    id<JCCollectionViewFetchedResultsControllerDelegate> jcCvFrcDelegate = cvFrcDelegate.delegate;
    
    NSInteger row = indexPath.row;
    id object = [self.fetchedObjects objectAtIndex:row];
    NSString* reuseIdentifier = [jcCvFrcDelegate collectionViewCellReuseIdForObject:object atIndexPath:indexPath];
    
    UICollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [jcCvFrcDelegate configureCollectionCell:collectionViewCell object:object indexPath:indexPath];
    
    return collectionViewCell;
}

@end
