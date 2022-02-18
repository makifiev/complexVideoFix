//  Created by Акифьев Максим  on 22.11.2021.
//

#import "RATreeView.h"


@class RATreeNode;


@interface RATreeView (Private)

- (RATreeNode *)treeNodeForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(id)item;

- (void)setupTreeStructure;

- (void)collapseCellForTreeNode:(RATreeNode *)treeNode;
- (void)collapseCellForTreeNode:(RATreeNode *)treeNode collapseChildren:(BOOL)collapseChildren withRowAnimation:(RATreeViewRowAnimation)rowAnimation;
- (void)expandCellForTreeNode:(RATreeNode *)treeNode;
- (void)expandCellForTreeNode:(RATreeNode *)treeNode expandChildren:(BOOL)expandChildren withRowAnimation:(RATreeViewRowAnimation)rowAnimation;

- (void)insertItemAtIndex:(NSInteger)index inParent:(id)parent withAnimation:(RATreeViewRowAnimation)animation;
- (void)removeItemAtIndex:(NSInteger)indexe inParent:(id)parent withAnimation:(RATreeViewRowAnimation)animation;

@end
