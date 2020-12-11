//
//  MZBarCodeViewController.m
//  MZCode
//
//  Created by Mr.Z on 2020/12/2.
//  Copyright © 2020 Mr.Z. All rights reserved.
//

#import "MZBarCodeViewController.h"
#import "MZCodeScanTool.h"

@interface MZBarCodeViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MZBarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self setupUI];
}

- (void)setupUI {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(16, 200, self.view.frame.size.width - 32, 150)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5;
    bgView.layer.masksToBounds = YES;
    [self.view addSubview:bgView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, CGRectGetWidth(bgView.frame) - 60, 60)];
    NSString *testBarString = @"string_date_20201210_time_1200";
    imageView.image = [MZCodeScanTool createBarCodeImageWithString:testBarString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60, 60)];
    [bgView addSubview:imageView];
    self.imageView = imageView;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(bgView.frame), 50)];
    titleLab.text = @"这是一个测试用的条形码";
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLab];
}

@end
