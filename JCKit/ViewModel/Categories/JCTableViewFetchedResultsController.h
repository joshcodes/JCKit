//
//  JCTableViewFetchResultsControllerDelegate.h
//  JCKit
//
//  Created by Josh Wingstrom on 3/21/14.
//  Copyright (c) 2014 JoshCodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCTableViewFetchedResultsControllerDelegate <NSObject>

-(NSString*)tableViewCellTypeForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
-(void)configureTableCell:(UITableViewCell*)tableViewCell object:(id)object indexPath:(NSIndexPath*)indexPath;

@optional

@end
