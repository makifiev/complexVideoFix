//  Created by Акифьев Максим  on 22.11.2021.
//


#import "RATreeNodeItem.h"

@protocol RATreeNodeItemDataSource <NSObject>

- (id)itemForTreeNodeItem:(RATreeNodeItem *)treeNodeItem;

@end


@interface RATreeNodeItem (Private)

@property (nonatomic, strong, readonly) id parent;
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, weak) id<RATreeNodeItemDataSource> dataSource;

@end
