//
//  MZCodeScanViewController.m
//  MZCode
//
//  Created by Mr.Z on 2020/12/2.
//  Copyright © 2020 Mr.Z. All rights reserved.
//

#import "MZCodeScanViewController.h"
#import "MZQRCodeViewController.h"
#import "MZCode.h"

@interface MZCodeScanViewController ()

@property (nonatomic, strong) MZCodeScanView *scanView;
@property (nonatomic, strong) MZCodeScanTool *scanTool;

@end

@implementation MZCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    UIView *preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:preview];
    // 构建扫描样式视图
    self.scanView = [[MZCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scanView.backgroundColor = UIColor.clearColor;
    self.scanView.scanRect = CGRectMake(40.0, 180.0, (self.view.frame.size.width - 2.0 * 40.0), (self.view.frame.size.width - 2.0 * 40.0));
    self.scanView.angleColor = [UIColor blueColor];
    self.scanView.isShowBorder = NO;
    self.scanView.borderColor = [UIColor whiteColor];
    self.scanView.notRecoginitonAreaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.scanView.animationImage = [UIImage imageNamed:@"MZCode.bundle/scanLine"];
    self.scanView.isShowMyCode = YES;
    self.scanView.tipDescription = @"将二维码放于框内\n即可自动扫描";
    [self.view addSubview:self.scanView];
    __weak typeof(self) weakSelf = self;
    self.scanView.codeScanBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        MZQRCodeViewController *qrCodeVC = [[MZQRCodeViewController alloc] init];
        qrCodeVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [strongSelf.navigationController presentViewController:qrCodeVC animated:YES completion:nil];
    };
    self.scanView.flashSwitchBlock = ^(BOOL open) {
        NSLog(@"闪光灯状态:%d", open);
    };
    self.scanTool = [[MZCodeScanTool alloc] initWithPreview:preview andScanFrame:self.scanView.scanRect];
    self.scanTool.scanFinishedBlock = ^(NSString *scanString) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"扫描结果:%@", scanString);
        [strongSelf.scanTool sessionStopRunning];
    };
    self.scanTool.monitorLightBlock = ^(float brightness) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"当前亮度:%lf", brightness);
        if (brightness < -2.0) {
            // 环境太暗,显示闪光灯开关按钮
            [strongSelf.scanView showFlashSwitch:YES];
        } else if (brightness > 0) {
            // 环境亮度可以,且闪光灯处于关闭状态时,隐藏闪光灯开关按钮
            if (strongSelf.scanView.flashOpen) {
                [strongSelf.scanView showFlashSwitch:YES];
            } else {
                [strongSelf.scanView showFlashSwitch:NO];
            }
        }
    };
    [self.scanTool sessionStartRunning];
    [self.scanView startScanAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.scanTool sessionStopRunning];
}

@end
