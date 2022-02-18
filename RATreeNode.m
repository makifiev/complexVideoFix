
//The MIT License (MIT)
//
//  Created by Акифьев Максим  on 22.11.2021.
//


#import "RATreeNode.h"

#import "RATreeNodeItem.h"


@interface RATreeNode () {
  BOOL _expanded;
}

@property (nonatomic) BOOL expanded;
@property (nonatomic, strong) RATreeNodeItem *lazyItem;
@property (nonatomic, copy) BOOL (^expandedBlock)(id);

@end


@implementation RATreeNode

- (id)initWithLazyItem:(RATreeNodeItem *)item expandedBlock:(BOOL (^)(id))expandedBlock;
{
  self = [super init];
  if (self) {
    _lazyItem = item;
    _expandedBlock = expandedBlock;
  }
  
  return self;
}


#pragma mark -

- (RATreeNodeItem *)item
{
  return self.lazyItem.item;
}

- (BOOL)expanded
{
  if (self.expandedBlock) {
    _expanded = self.expandedBlock(self.item);
    self.expandedBlock = nil;
  }
  
  return _expanded;
}

- (void)setExpanded:(BOOL)expanded
{
  self.expandedBlock = nil;
  _expanded = expanded;
}

@end
