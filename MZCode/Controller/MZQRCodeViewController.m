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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self setupUI];
}

- (void)setupUI {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(16, 150, self.view.frame.size.width - 32, 400)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5;
    bgView.layer.masksToBounds = YES;
    [self.view addSubview:bgView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, CGRectGetWidth(bgView.frame) - 60, 300)];
    NSString *codeString = @"这是一个测试用的二维码";
    // imageView.image = [MZCodeScanTool createQRCodeImageWithString:codeString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60, 300)];
    imageView.image = [MZCodeScanTool createQRCodeImageWithString:codeString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60, 300) frontColor:[UIColor orangeColor] backColor:[UIColor whiteColor] centerImage:[UIImage imageNamed:@"MZCode.bundle/scanFlashlight"]];
    [bgView addSubview:imageView];
    self.imageView = imageView;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 350, CGRectGetWidth(bgView.frame), 50)];
    titleLab.text = @"扫一扫上面的二维码图案添加好友！";
    titleLab.textColor = [UIColor blackColor];
    titleLab.font =[UIFont systemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLab];
}

@end
