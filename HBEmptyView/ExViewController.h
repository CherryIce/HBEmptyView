//
//  ExViewController.h
//  HBEmptyView
//
//  Created by hubin on 05/03/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ExType) {
    ExTypeNormal = 0,
    ExTypeHeader,
    ExTypeLongHeader,
    ExTypeHeaderFooter
};

@interface ExViewController : UIViewController

@property (nonatomic , assign) ExType type;

@end

NS_ASSUME_NONNULL_END
