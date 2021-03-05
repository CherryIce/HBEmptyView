//
//  HBEmptyViewProtocol.h
//  HBEmptyView
//
//  Created by hubin on 05/03/2021.
//

#ifndef HBEmptyViewProtocol_h
#define HBEmptyViewProtocol_h

@protocol HBEmptyViewDelegate <NSObject>

@required

/**
 无数据占位图
 @return 占位图
 */
- (UIView *)makePlaceHolderView;

/**
 没有更多数据了
 @return 没有更多数据图
 */
- (UIView *)makeNoMoreDataView;

@optional

/**
 出现占位图的时候TableView是否能拖动
 @return BOOL
 */
- (BOOL)enableScrollWhenPlaceHolderViewShowing;

@end


#endif /* HBEmptyViewProtocol_h */
