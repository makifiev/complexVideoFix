//  Created by Акифьев Максим  on 22.11.2021.
//


#import "RABatchChanges.h"
#import "RABatchChangeEntity.h"


@interface RABatchChanges ()

@property (nonatomic, strong) NSMutableArray *operationsStorage;
@property (nonatomic) NSInteger batchChangesCounter;

@end



@implementation RABatchChanges

- (id)init
{
  self = [super init];
  if (self) {
    _batchChangesCounter = 0;
  }
  
  return self;
}

- (void)beginUpdates
{
  if (self.batchChangesCounter++ == 0) {
    self.operationsStorage = [NSMutableArray array];
  }
}

- (void)endUpdates
{
  self.batchChangesCounter--;
  if (self.batchChangesCounter == 0) {
    [self.operationsStorage sortUsingSelector:@selector(compare:)];
    
    for (RABatchChangeEntity *entity in self.operationsStorage) {
      entity.updatesBlock();
    }
    self.operationsStorage = nil;
  }
}

- (void)insertItemWithBlock:(void (^)())update atIndex:(NSInteger)index
{
  RABatchChangeEntity *entity = [RABatchChangeEntity batchChangeEntityWithBlock:update
                                                                           type:RABatchChangeTypeItemRowInsertion
                                                                        ranking:index];
  [self addBatchChangeEntity:entity];
}

- (void)expandItemWithBlock:(void (^)())update atIndex:(NSInteger)index
{
  RABatchChangeEntity *entity= [RABatchChangeEntity batchChangeEntityWithBlock:update
                                                                          type:RABatchChangeTypeItemRowExpansion
                                                                       ranking:index];
  [self addBatchChangeEntity:entity];
}

- (void)deleteItemWithBlock:(void (^)())update lastIndex:(NSInteger)lastIndex
{
  RABatchChangeEntity *entity = [RABatchChangeEntity batchChangeEntityWithBlock:update
                                                                           type:RABatchChangeTypeItemRowDeletion
                                                                        ranking:lastIndex];
  [self addBatchChangeEntity:entity];
}

- (void)collapseItemWithBlock:(void (^)())update lastIndex:(NSInteger)lastIndex
{
  RABatchChangeEntity *entity = [RABatchChangeEntity batchChangeEntityWithBlock:update
                                                                           type:RABatchChangeTypeItemRowCollapse
                                                                        ranking:lastIndex];
  [self addBatchChangeEntity:entity];
}

- (void)moveItemWithDeletionBlock:(void (^)())deletionUpdate fromLastIndex:(NSInteger)lastIndex additionBlock:(void (^)())additionUpdate toIndex:(NSInteger)index
{
  RABatchChangeEntity *firstEntity = [RABatchChangeEntity batchChangeEntityWithBlock:deletionUpdate
                                                                                type:RABatchChangeTypeItemRowDeletion
                                                                             ranking:lastIndex];
  
  RABatchChangeEntity *secondEntity = [RABatchChangeEntity batchChangeEntityWithBlock:additionUpdate
                                                                                 type:RABatchChangeTypeItemRowInsertion
                                                                              ranking:index];
  [self addBatchChangeEntity:firstEntity];
  [self addBatchChangeEntity:secondEntity];
}

#pragma mark -

- (void)addBatchChangeEntity:(RABatchChangeEntity *)entity
{
  if (self.batchChangesCounter > 0) {
    [self.operationsStorage addObject:entity];
  } else {
    entity.updatesBlock();
  }
}



@end
