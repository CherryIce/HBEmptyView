//
//  ViewController.m
//  HBEmptyView
//
//  Created by hubin on 05/03/2021.
//

#import "ViewController.h"
#import "ExViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)buttonClick:(UIButton *)sender {
    ExViewController * ctl = [[ExViewController alloc] init];
    ctl.type = sender.tag;
    [self.navigationController pushViewController:ctl animated:YES];
}


@end
