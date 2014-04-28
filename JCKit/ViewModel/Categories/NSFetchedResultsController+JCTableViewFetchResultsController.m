//
//  NSFetchedResultsController+JCTableViewFetchResultsController.m
//  JCKit
//
//  Created by Josh Wingstrom on 3/21/14.
//  Copyright (c) 2014 JoshCodes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSFetchedResultsController+JCTableViewFetchResultsController.h"
#import "JCBasic.h"

@interface JCTVFRCDelegate : NSObject<NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, retain) id<JCTableViewFetchedResultsControllerDelegate> delegate;

-(id)initWithTableView:(UITableView*)tableView delegate:(id<JCTableViewFetchedResultsControllerDelegate>)delegate;

@end

@implementation JCTVFRCDelegate

-(id)initWithTableView:(UITableView*)tableView delegate:(id<JCTableViewFetchedResultsControllerDelegate>)delegate
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = delegate;
        self.tableView = tableView;
    }
    return self;
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self.delegate configureTableCell:cell object:anObject indexPath:indexPath];
            break;
        }
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end

@implementation NSFetchedResultsController (JCTableViewFetchResultsControllerCategory)

-(void)subscribeTableView:(UITableView *)tableView delegate:(id<JCTableViewFetchedResultsControllerDelegate>)delegate
{
    JCBasic* basic = [[JCBasic alloc] init];
    [basic includeStuff];
    
    JCTVFRCDelegate* frcDelegate = [[JCTVFRCDelegate alloc] initWithTableView:tableView delegate:delegate];
    
    NSError *eventFetchError = nil;
    if ([self performFetch:&eventFetchError] == NO) {
        NSLog(@"couldn't perform fetch:  %@", eventFetchError);
    } else {
        NSLog(@"got %lu events!  w00t!", (unsigned long)[[self fetchedObjects] count]);
        self.delegate = frcDelegate;
    }
}

-(void)unsubscribeTableView:(UITableView *)tableView
{
    // TODO: Check if delegate has tableView
    self.delegate = nil;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Validate the appropriate delegate is being used
    NSObject* delegate = (NSObject*)self.delegate;
    if (![delegate isKindOfClass:JCTVFRCDelegate.class])
    {
        NSLog(@"FetchedResultsController is not managed by a JCTableViewFetchResultsControllerCategory");
        return nil;
    }
    JCTVFRCDelegate* frcDelegate = (JCTVFRCDelegate*)delegate;
    
    // Get the object
    id object = [self objectAtIndexPath:indexPath];
    
    // Get the reuse identifier
    NSString* reuseIdentifier = [frcDelegate.delegate tableViewCellTypeForObject:object atIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [frcDelegate.delegate configureTableCell:cell object:object indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:[self objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
}

@end
