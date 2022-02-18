//
//  RATableView.h
//  Pods
//
//  Created by Акифьев Максим  on 22.11.2021.
//


#import <UIKit/UIKit.h>


@interface RATableView : UITableView

@property (nonatomic, nullable, weak) id<UITableViewDelegate> tableViewDelegate;
@property (nonatomic, nullable, weak) id<UIScrollViewDelegate> scrollViewDelegate;

@end
