//
//  JCCollectionViewFetchedResultsController.h
//  JCKit
//
//  Created by Josh Wingstrom on 3/21/14.
//  Copyright (c) 2014 JoshCodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCCollectionViewFetchedResultsControllerDelegate <NSObject>

-(NSString*)collectionViewCellReuseIdForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
-(void)configureCollectionCell:(UICollectionViewCell*)collectionViewCell object:(id)object indexPath:(NSIndexPath*)indexPath;

@optional

@end

@protocol JCCollectionViewFetchedResultsController <NSObject>

-(void)subscribeCollectionView:(UICollectionView*)collectionView delegate:(id<JCCollectionViewFetchedResultsControllerDelegate>)delegate;
-(void)unsubscribeCollectionView:(UITableView*)tableView;

@end
