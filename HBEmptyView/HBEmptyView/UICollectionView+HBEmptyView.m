//
//  UICollectionView+HBEmptyView.m
//  HBEmptyView
//
//  Created by hubin on 05/03/2021.
//

#import "UICollectionView+HBEmptyView.h"
#import <objc/runtime.h>

@interface  UICollectionView()

/**占位图*/
@property (nonatomic, strong) UIView *placeHolderView;

/**no more data*/
@property (nonatomic, strong) UIView *noMoreDataView;

@end

@implementation UICollectionView (HBEmptyView)

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

- (void)hb_reloadData {
    [self hb_reloadData];
    [self checkEmpty];
    [self checkNoMoreData];
}

- (void)checkEmpty {
    NSInteger rows = 0;
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        rows += [self numberOfItemsInSection:section];
    }
    
    // 如果rows为空
    if (rows == 0) {
        
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
        self.placeHolderView.frame =
        CGRectMake(CGRectGetMinX(self.placeHolderView.frame),
                   (CGRectGetHeight(self.frame) - CGRectGetHeight(self.placeHolderView.frame))/2,
                   CGRectGetWidth(self.placeHolderView.frame),
                   CGRectGetHeight(self.placeHolderView.frame));
        
        [self addSubview:self.placeHolderView];
    }
    else {
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
