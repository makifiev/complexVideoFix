//  Created by Акифьев Максим  on 22.11.2021.
//

#import "RATreeNodeItem.h"

@interface RATreeNodeItem ()

@property (nonatomic, strong) id item;
@property (nonatomic, weak) id parent;
@property (nonatomic) NSInteger index;

@property (nonatomic, weak) id<RATreeNodeItemDataSource> dataSource;

@end
