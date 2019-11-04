//
//  ResultViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    self.resultLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/4, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width/2,50)];
//    _resultLabel.font = [UIFont systemFontOfSize:20];
//    _resultLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.resultLabel];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
