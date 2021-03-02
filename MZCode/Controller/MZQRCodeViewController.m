//
//  MZQRCodeViewController.m
//  MZCode
//
//  Created by Mr.Z on 2020/12/2.
//  Copyright © 2020 Mr.Z. All rights reserved.
//

#import "MZQRCodeViewController.h"
#import "MZCodeScanTool.h"

@interface MZQRCodeViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MZQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self setupUI];
}

- (void)setupUI {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(16.0, 150.0, self.view.frame.size.width - 32.0, 400.0)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5.0;
    bgView.layer.masksToBounds = YES;
    [self.view addSubview:bgView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 20.0, CGRectGetWidth(bgView.frame) - 60.0, 300.0)];
    NSString *codeString = @"这是一个测试用的二维码";
    NSInteger type = 2;
    if (type == 1) {
        // 方式一
        imageView.image = [MZCodeScanTool createQRCodeImageWithString:codeString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60.0, 300.0)];
    } else {
        // 方式二
        imageView.image = [MZCodeScanTool createQRCodeImageWithString:codeString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60.0, 300.0) frontColor:[UIColor orangeColor] backColor:[UIColor whiteColor] centerImage:[UIImage imageNamed:@"MZCode.bundle/scanFlashlight"]];
    }
    [bgView addSubview:imageView];
    self.imageView = imageView;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 350.0, CGRectGetWidth(bgView.frame), 50.0)];
    titleLab.text = @"扫一扫上面的二维码图案添加好友！";
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLab];
}

@end
