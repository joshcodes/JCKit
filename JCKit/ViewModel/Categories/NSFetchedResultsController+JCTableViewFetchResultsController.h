//
//  NSFetchedResultsController+JCTableViewFetchResultsController.h
//  JCKit
//
//  Created by Josh Wingstrom on 3/21/14.
//  Copyright (c) 2014 JoshCodes. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "JCTableViewFetchedResultsController.h"
#import "NSFetchedResultsController+JCTableViewFetchResultsController.h"

@interface NSFetchedResultsController (JCTableViewFetchResultsControllerCategory) <UITableViewDataSource>

-(void)subscribeTableView:(UITableView*)tableView delegate:(id<JCTableViewFetchedResultsControllerDelegate>)delegate;
-(void)unsubscribeTableView:(UITableView*)tableView;

@end

