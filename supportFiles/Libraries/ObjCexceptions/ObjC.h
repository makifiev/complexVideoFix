//
//  ObjC.h
//  ККВФ
//
//  Created by Акифьев Максим  on 28.10.2021.
//

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
