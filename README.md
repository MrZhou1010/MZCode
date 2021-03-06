# MZCode

**二维码、条形码扫描及生成**

	@property (nonatomic, strong) MZCodeScanView *scanView;
	@property (nonatomic, strong) MZCodeScanTool *scanTool;
    
`构建扫描样式视图`

	self.scanView = [[MZCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	self.scanView.backgroundColor = UIColor.clearColor;
	self.scanView.scanRect = CGRectMake(40, 180, (self.view.frame.size.width - 2 * 40), (self.view.frame.size.width - 2 * 40));
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
    	MZQRCodeViewController *qrCodeVC = [[MZQRCodeViewController alloc] init];
    	qrCodeVC.modalPresentationStyle = UIModalPresentationFullScreen;
    	[weakSelf.navigationController presentViewController:qrCodeVC animated:YES completion:nil];
	};
	self.scanView.flashSwitchBlock = ^(BOOL open) {
    	NSLog(@"open:%d", open);
	};
	self.scanTool = [[MZCodeScanTool alloc] initWithPreview:preview 		andScanFrame:self.scanView.scanRect];
	self.scanTool.scanFinishedBlock = ^(NSString *scanString) {
    	NSLog(@"扫描结果 %@", scanString);
    	[weakSelf.scanTool sessionStopRunning];
	};
	self.scanTool.monitorLightBlock = ^(float brightness) {
	    NSLog(@"当前亮度 %lf", brightness);
    	if (brightness < -2.0) {
        	// 环境太暗,显示闪光灯开关按钮
        	[weakSelf.scanView showFlashSwitch:YES];
    	} else if (brightness > 0) {
        	// 环境亮度可以,且闪光灯处于关闭状态时,隐藏闪光灯开关按钮
        	if (weakSelf.scanView.flashOpen) {
            	[weakSelf.scanView showFlashSwitch:YES];
        	} else {
            	[weakSelf.scanView showFlashSwitch:NO];
        	}
    	}
	};
	[self.scanTool sessionStartRunning];
	[self.scanView startScanAnimation];
    
`一句话生成二维码`

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, CGRectGetWidth(bgView.frame) - 60, 300)];
    NSString *codeString = @"这是一个测试用的二维码";
    NSInteger type = 2;
    if (type == 1) {
      // 方式一
      	imageView.image = [MZCodeScanTool createQRCodeImageWithString:codeString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60, 300)];
    } else {
      // 方式二
      	imageView.image = [MZCodeScanTool createQRCodeImageWithString:codeString size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60, 300) frontColor:[UIColor orangeColor] backColor:[UIColor whiteColor] centerImage:[UIImage imageNamed:@"MZCode.bundle/scanFlashlight"]];
 	}

`一句话生成条形码`

	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, CGRectGetWidth(bgView.frame) - 60, 60)];
	NSString *testBarString = @"string_date_20201210_time_1200";
	imageView.image = [MZCodeScanTool createBarCodeImageWithString:testBarString 	size:CGSizeMake(CGRectGetWidth(bgView.frame) - 60, 60)];
