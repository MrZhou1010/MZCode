//
//  ViewController.m
//  MZCode
//
//  Created by Mr.Z on 2019/8/6.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "ViewController.h"
#import "MyQRCodeViewController.h"
#import "MZCode.h"

@interface ViewController ()

@property (nonatomic, strong) MZCodeScanView *scanView;
@property (nonatomic, strong) MZCodeScanTool *scanTool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:preview];
    
    // 构建扫描样式视图
    _scanView = [[MZCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _scanView.backgroundColor = UIColor.clearColor;
    _scanView.scanRect = CGRectMake(80, 180, (self.view.frame.size.width - 2 * 80),  (self.view.frame.size.width - 2 * 80));
    _scanView.angleColor = [UIColor blueColor];
    _scanView.isShowBorder = NO;
    _scanView.borderColor = [UIColor whiteColor];
    _scanView.notRecoginitonAreaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _scanView.animationImage = [UIImage imageNamed:@"MZCode.bundle/scanLine"];
    [self.view addSubview:_scanView];
    __weak typeof(self) weakSelf = self;
    _scanView.codeScanBlock = ^{
        MyQRCodeViewController *myQRCodeVC = [[MyQRCodeViewController alloc] init];
        myQRCodeVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakSelf presentViewController:myQRCodeVC animated:YES completion:nil];
    };
    
    _scanTool = [[MZCodeScanTool alloc] initWithPreview:preview andScanFrame:_scanView.scanRect];
    _scanTool.scanFinishedBlock = ^(NSString *scanString) {
        NSLog(@"扫描结果 %@", scanString);
        [weakSelf.scanTool sessionStopRunning];
    };
    _scanTool.monitorLightBlock = ^(float brightness) {
        NSLog(@"当前亮度 %lf", brightness);
        if (brightness < -2) {
            // 环境太暗，显示闪光灯开关按钮
            [weakSelf.scanView showFlashSwitch:YES];
        } else if(brightness > 0) {
            // 环境亮度可以,且闪光灯处于关闭状态时，隐藏闪光灯开关
            if(weakSelf.scanView.flashOpen) {
                [weakSelf.scanView showFlashSwitch:NO];
            }
        }
    };
    [_scanTool sessionStartRunning];
    [_scanView startScanAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_scanTool sessionStopRunning];
}

@end
