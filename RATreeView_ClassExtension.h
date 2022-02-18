//  Created by Акифьев Максим  on 22.11.2021.
//

#import "RATreeView.h"

@class RABatchChanges;


@interface RATreeView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RATreeNodeCollectionController *treeNodeCollectionController;

@property (nonatomic, strong) RABatchChanges *batchChanges;

@end
