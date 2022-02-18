//  Created by Акифьев Максим  on 22.11.2021.
//


#import <Foundation/Foundation.h>

@interface RATreeNodeItem : NSObject

@property (nonatomic, strong, readonly) id item;

- (instancetype)initWithParent:(id)parent index:(NSInteger)index;

@end
