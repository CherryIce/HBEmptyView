//
//  ExViewController.m
//  HBEmptyView
//
//  Created by hubin on 05/03/2021.
//

#import "ExViewController.h"
#import "UITableView+HBEmptyView.h"

@interface ExViewController ()<UITableViewDelegate,UITableViewDataSource,HBEmptyViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic , strong) NSMutableArray * dataArray;

@end

@implementation ExViewController

- (void)setType:(ExType)type {
    _type = type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    switch (_type) {
        case ExTypeNormal:
            self.tableView.tableFooterView = [UIView new];
            break;
        case ExTypeHeader:{
            UIView * v = [self creatViewWithHeight:100];
            v.backgroundColor = [UIColor redColor];
            self.tableView.tableHeaderView = v;
        }
            break;
        case ExTypeLongHeader:{
            UIView * v = [self creatViewWithHeight:800];
            v.backgroundColor = [UIColor redColor];
            self.tableView.tableHeaderView = v;
        }
            break;
        case ExTypeHeaderFooter:{
            UIView * v = [self creatViewWithHeight:100];
            v.backgroundColor = [UIColor redColor];
            self.tableView.tableHeaderView = v;
            
            UIView * v1 = [self creatViewWithHeight:50];
            v1.backgroundColor = [UIColor blackColor];
            self.tableView.tableFooterView = v1;
        }
            break;
        default:
            break;
    }
    
    
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"load" style:UIBarButtonItemStylePlain target:self action:@selector(refreshLoad)];
}

- (void) refreshLoad {
    [self.dataArray removeAllObjects];
    for (int i = 0; i < 20; i++) {
        [self.dataArray addObject:@(i)];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.dataArray[indexPath.row]];
    return cell;
}

- (UIView *)creatViewWithHeight:(CGFloat)h {
    UIView * v = [[UIView alloc] init];
    v.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, h);
    return v;
}

#pragma mark - HBEmptyViewDelegate
- (UIView *)makePlaceHolderView {
    if (self.dataArray.count == 0) {
        UIView * v = [self creatViewWithHeight:300];
        v.backgroundColor = [UIColor lightGrayColor];
        UILabel * label = [[UILabel alloc] initWithFrame:v.bounds];
        label.font = [UIFont boldSystemFontOfSize:30];
        label.text = @"no data~";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [v addSubview:label];
        return v;
    }
    return nil;
}

- (UIView *)makeNoMoreDataView {
    if (self.dataArray.count == 20) {
        UIView * v = [self creatViewWithHeight:30];
        UILabel * label = [[UILabel alloc] initWithFrame:v.bounds];
        label.text = @"--- no more data ---";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [v addSubview:label];
        return v;
    }
    return nil;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing{
    return YES;
}

#pragma mark - getter
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
