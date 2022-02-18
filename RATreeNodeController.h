//  Created by Акифьев Максим  on 22.11.2021.
//

#import <Foundation/Foundation.h>

@class RATreeNodeController, RATreeNode, RATreeNodeItem;


@interface RATreeNodeController : NSObject

@property (nonatomic, weak, readonly) RATreeNodeController *parentController;
@property (nonatomic, strong, readonly) NSArray *childControllers;

@property (nonatomic, strong, readonly) RATreeNode *treeNode;
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, readonly) NSInteger numberOfVisibleDescendants;
@property (nonatomic, strong, readonly) NSIndexSet *descendantsIndexes;
@property (nonatomic, readonly) NSInteger level;

- (instancetype)initWithParent:(RATreeNodeController *)parentController item:(RATreeNodeItem *)item expandedBlock:(BOOL (^)(id))expanded;

- (void)collapseAndCollapseChildren:(BOOL)collapseChildren;
- (void)expandAndExpandChildren:(BOOL)expandChildren;

- (void)insertChildControllers:(NSArray *)controllers atIndexes:(NSIndexSet *)indexes;
- (void)moveChildControllerAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex;
- (void)removeChildControllersAtIndexes:(NSIndexSet *)indexes;

- (NSInteger)indexForItem:(id)item;
- (NSInteger)lastVisibleDescendatIndexForItem:(id)item;
- (RATreeNodeController *)controllerForIndex:(NSInteger)index;
- (RATreeNodeController *)controllerForItem:(id)item;

@end
