//  Created by Акифьев Максим  on 22.11.2021.
//

#import "RATreeView+TableViewDataSource.h"
#import "RATreeView+Private.h"
#import "RATreeView_ClassExtension.h"

#import "RATreeNodeCollectionController.h"
#import "RATreeNodeController.h"
#import "RATreeNode.h"

@implementation RATreeView (TableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (self.treeNodeCollectionController == nil) {
    [self setupTreeStructure];
  }
  return self.treeNodeCollectionController.numberOfVisibleRowsForItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  RATreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
  return [self.dataSource treeView:self cellForItem:treeNode.item];
}


#pragma mark - Inserting or Deleting Table Rows

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([self.dataSource respondsToSelector:@selector(treeView:commitEditingStyle:forRowForItem:)]) {
    RATreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    [self.dataSource treeView:self commitEditingStyle:editingStyle forRowForItem:treeNode.item];
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([self.dataSource respondsToSelector:@selector(treeView:canEditRowForItem:)]) {
    RATreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    return [self.dataSource treeView:self canEditRowForItem:treeNode.item];
  }
  return YES;
}

@end
