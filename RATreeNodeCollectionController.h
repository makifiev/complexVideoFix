
//The MIT License (MIT)
//
//  Created by Акифьев Максим  on 22.11.2021.
//

#import <Foundation/Foundation.h>

@class RATreeNodeController, RATreeNode, RATreeNodeCollectionController;

@protocol RATreeNodeCollectionControllerDataSource <NSObject>

- (NSInteger)treeNodeCollectionController:(RATreeNodeCollectionController *)controller numberOfChildrenForItem:(id)item;
- (id)treeNodeCollectionController:(RATreeNodeCollectionController *)controller child:(NSInteger)childIndex ofItem:(id)item;

@end


@interface RATreeNodeCollectionController : NSObject

@property (nonatomic, weak) id<RATreeNodeCollectionControllerDataSource> dataSource;
@property (nonatomic, readonly) NSInteger numberOfVisibleRowsForItems;

- (RATreeNode *)treeNodeForIndex:(NSInteger)index;
- (NSInteger)levelForItem:(id)item;
- (id)parentForItem:(id)item;
- (id)childInParent:(id)parent atIndex:(NSInteger)index;

- (NSInteger)indexForItem:(id)item;
- (NSInteger)lastVisibleDescendantIndexForItem:(id)item;

- (void)collapseRowForItem:(id)item collapseChildren:(BOOL)collapseChildren updates:(void(^)(NSIndexSet *))updates;
- (void)expandRowForItem:(id)item expandChildren:(BOOL)expandChildren updates:(void (^)(NSIndexSet *))updates;

- (void)insertItemsAtIndexes:(NSIndexSet *)indexes inParent:(id)item;
- (void)moveItemAtIndex:(NSInteger)index inParent:(id)parent toIndex:(NSInteger)newIndex inParent:(id)newParent updates:(void(^)(NSIndexSet *deletions, NSIndexSet *additions))updates;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes inParent:(id)item updates:(void(^)(NSIndexSet *))updates;

@end
