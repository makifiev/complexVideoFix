//  Created by Акифьев Максим  on 22.11.2021.
//

#import <Foundation/Foundation.h>


@interface RABatchChanges : NSObject

- (void)beginUpdates;
- (void)endUpdates;

- (void)expandItemWithBlock:(void(^)())update atIndex:(NSInteger)index;
- (void)insertItemWithBlock:(void(^)())update atIndex:(NSInteger)index;

- (void)collapseItemWithBlock:(void(^)())update lastIndex:(NSInteger)index;
- (void)deleteItemWithBlock:(void(^)())update lastIndex:(NSInteger)index;

- (void)moveItemWithDeletionBlock:(void (^)())deletionUpdate fromLastIndex:(NSInteger)lastIndex additionBlock:(void (^)())additionUpdate toIndex:(NSInteger)index;

@end
