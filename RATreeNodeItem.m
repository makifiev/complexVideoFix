//  Created by Акифьев Максим  on 22.11.2021.
//


#import "RATreeNodeItem.h"
#import "RATreeNodeItem+Private.h"
#import "RATreeNodeItem+ClassExtension.h"


@implementation RATreeNodeItem

- (instancetype)initWithParent:(id)parent index:(NSInteger)index
{
  self = [super init];
  if (self) {
    _parent = parent;
    _index = index;
  }
  
  return self;
}

- (id)item
{
  if (!_item) {
    _item = [self.dataSource itemForTreeNodeItem:self];
  }
  return _item;
}

@end
