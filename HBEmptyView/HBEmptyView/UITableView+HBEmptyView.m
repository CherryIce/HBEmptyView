//
//  UITableView+HBEmptyView.m
//  HBEmptyView
//
//  Created by hubin on 05/03/2021.
//

#import "UITableView+HBEmptyView.h"
#import <objc/runtime.h>

@interface UITableView ()

/**占位图*/
@property (nonatomic, strong) UIView *placeHolderView;

/**占位图是否放在了tablefooterview上面*/
@property (nonatomic, assign) BOOL isAddFooter;

/**no more data*/
@property (nonatomic, strong) UIView *noMoreDataView;

@end

@implementation UITableView (HBEmptyView)

+ (void)load{
    Method m1 = class_getInstanceMethod([self class], @selector(reloadData));
    Method m2 = class_getInstanceMethod([self class], @selector(hb_reloadData));
    method_exchangeImplementations(m1, m2);
}

- (UIView *)placeHolderView {
    return objc_getAssociatedObject(self, @selector(placeHolderView));
}

- (void)setPlaceHolderView:(UIView *)placeHolderView {
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)noMoreDataView {
    return objc_getAssociatedObject(self, @selector(noMoreDataView));
}

- (void)setNoMoreDataView:(UIView *)noMoreDataView {
    objc_setAssociatedObject(self, @selector(noMoreDataView), noMoreDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAddFooter {
    NSNumber *number = objc_getAssociatedObject(self, @selector(isAddFooter));
    return number.boolValue;
}

- (void)setIsAddFooter:(BOOL)isAddFooter {
    NSNumber *number = [NSNumber numberWithBool:isAddFooter];
    objc_setAssociatedObject(self, @selector(isAddFooter), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hb_reloadData {
    [self hb_reloadData];
    [self checkEmpty];
    [self checkNoMoreData];
}

- (void)checkEmpty {
    NSInteger rows = 0;
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        rows += [self numberOfRowsInSection:section];
    }
    
    // 如果rows为空
    if (rows == 0) {
    
        // 模式ScrollView可以滚动
        BOOL scrollEnabled = YES;
        if ([self respondsToSelector:@selector(enableScrollWhenPlaceHolderViewShowing)]) {
            scrollEnabled = [[self performSelector:@selector(enableScrollWhenPlaceHolderViewShowing)] boolValue];
        }
        else if ([self.delegate respondsToSelector:@selector(enableScrollWhenPlaceHolderViewShowing)]) {
            scrollEnabled = [self.delegate performSelector:@selector(enableScrollWhenPlaceHolderViewShowing)];
        }
        self.scrollEnabled = scrollEnabled;
        
        // 移除placeHolderView
        [self.placeHolderView removeFromSuperview];
        
        // 获取placeHolderView
        if ([self respondsToSelector:@selector(makePlaceHolderView)]) {
            self.placeHolderView = [self performSelector:@selector(makePlaceHolderView)];
        }
        else if ( [self.delegate respondsToSelector:@selector(makePlaceHolderView)]) {
            self.placeHolderView = [self.delegate performSelector:@selector(makePlaceHolderView)];
        }
        
        //考虑有tableHeaderView并且tableHeaderView有数据的情况
        if (self.tableHeaderView) {
            if (self.isAddFooter) {
                //此处单纯针对tableHeaderView有数据并且高度过大可以允许滑动的情况
                UIView * footer = self.tableFooterView;
                if (CGRectGetHeight(footer.frame) == CGRectGetHeight(self.placeHolderView.frame)) {
                    self.tableFooterView = self.placeHolderView;
                }else{
                    [footer addSubview:self.placeHolderView];
                    self.tableFooterView = footer;
                }
            }else{
                //考虑tableFooterView情况
                self.isAddFooter = YES;
                if (self.tableFooterView) {
                    UIView * footer = self.tableFooterView;
                    UIView * newFooter = [[UIView alloc] init];
                    newFooter.frame = CGRectMake(0,
                                                 0,
                                                 CGRectGetWidth(footer.frame),
                                                 CGRectGetHeight(self.placeHolderView.frame) + CGRectGetHeight(footer.frame));
                    newFooter.backgroundColor = footer.backgroundColor;
                    [newFooter addSubview:self.placeHolderView];
                    [newFooter addSubview:footer];
                    footer.frame = CGRectMake(CGRectGetMinX(footer.frame),
                                              CGRectGetMaxY(newFooter.frame) - CGRectGetHeight(footer.frame),
                                              CGRectGetWidth(footer.frame),
                                              CGRectGetHeight(footer.frame));
                    
                    self.tableFooterView = newFooter;
                }else{
                    self.placeHolderView.frame =
                    CGRectMake(CGRectGetMinX(self.placeHolderView.frame),
                               self.tableHeaderView.frame.size.height,
                               CGRectGetWidth(self.placeHolderView.frame),
                               CGRectGetHeight(self.placeHolderView.frame));
                    
                    self.tableFooterView = self.placeHolderView;
                }
            }
        }else{
            //普通情况
            self.isAddFooter = NO;
            self.placeHolderView.frame =
            CGRectMake(CGRectGetMinX(self.placeHolderView.frame),
                       (CGRectGetHeight(self.frame) - CGRectGetHeight(self.placeHolderView.frame))/2,
                       CGRectGetWidth(self.placeHolderView.frame),
                       CGRectGetHeight(self.placeHolderView.frame));
            
            [self addSubview:self.placeHolderView];
        }
    }
    else {
        //重置要考虑之前占位图所处的位置
        UIView * footer = self.tableFooterView;
        if (self.isAddFooter) {
            CGRect frame = footer.frame;
            if (CGRectGetHeight(footer.frame) == CGRectGetHeight(self.placeHolderView.frame)) {
                footer.frame = CGRectZero;
            }else{
                frame.origin.y = 0;
                frame.size.height -= CGRectGetHeight(self.placeHolderView.frame);
                footer.frame = frame;
            }
            self.tableFooterView = footer;
            self.isAddFooter = NO;
        }
        // rows不为空 移除placeHolderView
        [self.placeHolderView removeFromSuperview];
        self.placeHolderView = nil;
        // 设置TableView 可滚动
        self.scrollEnabled = YES;
    }
}

- (void) checkNoMoreData {
    // 移除
    [self.noMoreDataView removeFromSuperview];
    self.noMoreDataView = nil;
    // 获取
    if ([self respondsToSelector:@selector(makeNoMoreDataView)]) {
        self.noMoreDataView = [self performSelector:@selector(makeNoMoreDataView)];
    }
    else if ( [self.delegate respondsToSelector:@selector(makeNoMoreDataView)]) {
        self.noMoreDataView = [self.delegate performSelector:@selector(makeNoMoreDataView)];
    }
    if (self.noMoreDataView) {
        CGFloat h = self.contentSize.height;
        self.contentSize = CGSizeMake(self.frame.origin.x, h + CGRectGetHeight(self.noMoreDataView.frame));
        self.noMoreDataView.frame =
        CGRectMake(CGRectGetMinX(self.noMoreDataView.frame),
                   h,
                   CGRectGetWidth(self.noMoreDataView.frame),
                   CGRectGetHeight(self.noMoreDataView.frame));
        [self addSubview:self.noMoreDataView];
    }
}

@end
