//
//  MyQRCodeViewController.m
//  MZCode
//
//  Created by 木木 on 2019/8/6.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "MyQRCodeViewController.h"
#import "MZCodeScanTool.h"

@interface MyQRCodeViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MyQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self createUI];
}

- (void)createUI {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(16, 150, self.view.frame.size.width - 32, 400)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5;
    bgView.layer.masksToBounds = YES;
    [self.view addSubview:bgView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(bgView.frame) - 32, 300)];
    NSString *myInfo = @"this is a test!";
    imageView.image = [MZCodeScanTool createQRCodeImageWithString:myInfo andSize:CGSizeMake(CGRectGetWidth(bgView.frame) - 32, 300) andBackColor:[UIColor whiteColor] andFrontColor:[UIColor blackColor] andCenterImage:[UIImage imageNamed:@"scanFlashlight"]];
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
