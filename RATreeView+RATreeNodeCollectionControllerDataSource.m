//  Created by Акифьев Максим  on 22.11.2021.
//

#import "RATreeView+RATreeNodeCollectionControllerDataSource.h"

@implementation RATreeView (RATreeNodeCollectionControllerDataSource)

- (NSInteger)treeNodeCollectionController:(RATreeNodeCollectionController *)controller numberOfChildrenForItem:(id)item
{
  return [self.dataSource treeView:self numberOfChildrenOfItem:item];
}

- (id)treeNodeCollectionController:(RATreeNodeCollectionController *)controller child:(NSInteger)childIndex ofItem:(id)item
{
  return [self.dataSource treeView:self child:childIndex ofItem:item];
}

@end
