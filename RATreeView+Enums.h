//  Created by Акифьев Максим  on 22.11.2021.
//
#import "RATreeView.h"

@interface RATreeView (Enums)

//Row Animations
+ (UITableViewRowAnimation)tableViewRowAnimationForTreeViewRowAnimation:(RATreeViewRowAnimation)rowAnimation;

#if TARGET_OS_IOS
//Cell Separator Styles
+ (RATreeViewCellSeparatorStyle)treeViewCellSeparatorStyleForTableViewSeparatorStyle:(UITableViewCellSeparatorStyle)style;
+ (UITableViewCellSeparatorStyle)tableViewCellSeparatorStyleForTreeViewCellSeparatorStyle:(RATreeViewCellSeparatorStyle)style;
#endif

//Tree View Style
+ (UITableViewStyle)tableViewStyleForTreeViewStyle:(RATreeViewStyle)treeViewStyle;
+ (RATreeViewStyle)treeViewStyleForTableViewStyle:(UITableViewStyle)tableViewStyle;

//Scroll Positions
+ (UITableViewScrollPosition)tableViewScrollPositionForTreeViewScrollPosition:(RATreeViewScrollPosition)scrollPosition;

@end
