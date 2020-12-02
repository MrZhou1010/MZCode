//
//  MZCodeScanView.m
//  MZCode
//
//  Created by Mr.Z on 2019/8/6.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "MZCodeScanView.h"
#import "MZCodeScanTool.h"

#define MZNotificationDefault [NSNotificationCenter defaultCenter]

@interface MZCodeScanView ()

/** 动画线条 */
@property (nonatomic, strong) UIImageView *scanLine;
/** 网络状态提示语 */
@property (nonatomic, strong) UILabel *netLabel;
/** 菊花等待 */
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
/** 扫描结果处理中 */
@property (nonatomic, strong) UIView *handlingView;
/** 手电筒开关 */
@property (nonatomic, strong) UIButton *flashBtn;
/** 是否正在动画 */
@property (nonatomic, assign) BOOL isAnimating;
/** 闪光灯开关的状态 */
@property (nonatomic, assign, readwrite) BOOL flashOpen;

@end

@implementation MZCodeScanView

#pragma mark - Lazy
- (UIImageView *)scanLine {
    if (!_scanLine) {
        _scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.scanRect.origin.x, self.scanRect.origin.y, self.scanRect.size.width, 2.0)];
        if (!self.animationImage) {
            self.animationImage = [UIImage imageNamed:@"MZCode.bundle/scanLine"];
        }
        _scanLine.image = self.animationImage;
        _scanLine.contentMode = UIViewContentModeScaleToFill;
    }
    return _scanLine;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        if (@available(iOS 13.0, *)) {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        _activityView.frame = CGRectMake(0, 0, self.scanRect.size.width, 40.0);
        [_activityView startAnimating];
    }
    return _activityView;
}

- (UIView *)handlingView {
    if (!_handlingView) {
        _handlingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scanRect.size.width, 80.0)];
        _handlingView.center = CGPointMake(self.frame.size.width / 2.0, self.scanRect.origin.y + self.scanRect.size.height / 2.0);
        [_handlingView addSubview:self.activityView];
        UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40.0, self.scanRect.size.width, 40.0)];
        handleLabel.font = [UIFont systemFontOfSize:12];
        handleLabel.textAlignment = NSTextAlignmentCenter;
        handleLabel.textColor = [UIColor whiteColor];
        handleLabel.text = @"正在处理...";
        [_handlingView addSubview:handleLabel];
    }
    return _handlingView;
}

- (UIButton *)flashBtn {
    if (!_flashBtn) {
        _flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40.0, 40.0)];
        _flashBtn.center = CGPointMake(self.frame.size.width / 2.0, self.scanRect.origin.y + self.scanRect.size.height - 40.0);
        _flashBtn.hidden = YES;
        if (!self.flashLightImage) {
            self.flashLightImage = [UIImage imageNamed:@"MZCode.bundle/scanFlashlight"];
        }
        [_flashBtn setImage:self.flashLightImage forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(flashBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_flashBtn];
    }
    return _flashBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.scanRect = CGRectMake(60.0, 100.0, frame.size.width - 2.0 * 60.0, frame.size.width - 2.0 * 60.0);
        self.isShowBorder = YES;
        self.borderColor = UIColor.clearColor;
        self.notRecoginitonAreaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.angleWidth = 20.0;
        self.angleHeight = 20.0;
        self.angleLineWidth = 4.0;
        self.angleBorderMargin = 2.0;
        self.angleColor = UIColor.greenColor;
        self.isShowMyCode = YES;
        self.isShowTipDescription = YES;
        self.tipDescription = @"将二维码置于扫描框内，即可自动扫描";
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawScanRect];
    [self addSubview:self.scanLine];
    if (self.isShowTipDescription) {
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.scanRect.origin.y + self.scanRect.size.height + 20.0, rect.size.width, 40.0)];
        descLabel.text = self.tipDescription;
        descLabel.textColor = [UIColor whiteColor];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.numberOfLines = 0;
        descLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [self addSubview:descLabel];
    }
    if (self.isShowMyCode) {
        UIButton *myCode = [[UIButton alloc] initWithFrame:CGRectMake(0, self.scanRect.origin.y + self.scanRect.size.height + 20.0 + 40.0 + 10.0, rect.size.width, 20.0)];
        myCode.titleLabel.font = [UIFont systemFontOfSize:15];
        [myCode setTitle:@"我的二维码" forState:UIControlStateNormal];
        [myCode setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [myCode addTarget:self action:@selector(myCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:myCode];
    }
    [MZNotificationDefault addObserver:self selector:@selector(appWillEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [MZNotificationDefault addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/// 绘制扫描区域
- (void)drawScanRect {
    CGSize scanSize = self.scanRect.size;
    CGFloat yMin = self.scanRect.origin.y;
    CGFloat yMax = self.scanRect.origin.y + scanSize.height;
    CGFloat xMin = self.scanRect.origin.x;
    CGFloat xMax = self.scanRect.origin.x + scanSize.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    const CGFloat *components = CGColorGetComponents(self.notRecoginitonAreaColor.CGColor);
    CGContextSetFillColor(context, components);
    // 扫码区域上面填充
    CGRect topRect = CGRectMake(0, 0, self.frame.size.width, yMin);
    CGContextFillRect(context, topRect);
    // 扫码区域左边填充
    CGRect leftRect = CGRectMake(0, yMin, xMin, scanSize.height);
    CGContextFillRect(context, leftRect);
    // 扫码区域下面填充
    CGRect bottomRect = CGRectMake(0, yMax, self.frame.size.width, self.frame.size.height - yMax);
    CGContextFillRect(context, bottomRect);
    //扫码区域右边填充
    CGRect rightRect = CGRectMake(xMax, yMin, xMin, scanSize.height);
    CGContextFillRect(context, rightRect);
    // 执行绘画
    CGContextStrokePath(context);
    if (self.isShowBorder) {
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextAddRect(context, self.scanRect);
        CGContextStrokePath(context);
    }
    // 矩形框的4个相框角
    CGContextSetStrokeColorWithColor(context, self.angleColor.CGColor);
    CGContextSetLineWidth(context, self.angleLineWidth);
    // 左上角
    CGContextMoveToPoint(context, xMin - self.angleLineWidth - self.angleBorderMargin, yMin - self.angleLineWidth / 2.0 - self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMin - self.angleLineWidth + self.angleWidth - self.angleBorderMargin, yMin - self.angleLineWidth / 2.0 - self.angleBorderMargin);
    CGContextMoveToPoint(context, xMin - self.angleLineWidth / 2.0 - self.angleBorderMargin, yMin - self.angleLineWidth - self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMin - self.angleLineWidth / 2.0 - self.angleBorderMargin, yMin - self.angleLineWidth + self.angleHeight - self.angleBorderMargin);
    // 左下角
    CGContextMoveToPoint(context, xMin - self.angleLineWidth - self.angleBorderMargin, yMax + self.angleLineWidth / 2.0 + self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMin - self.angleLineWidth + self.angleWidth - self.angleBorderMargin, yMax + self.angleLineWidth / 2.0 + self.angleBorderMargin);
    CGContextMoveToPoint(context, xMin - self.angleLineWidth / 2.0 - self.angleBorderMargin, yMax + self.angleLineWidth + self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMin - self.angleLineWidth / 2.0 - self.angleBorderMargin, yMax + self.angleLineWidth - self.angleHeight + self.angleBorderMargin);
    // 右上角
    CGContextMoveToPoint(context, xMax + self.angleLineWidth + self.angleBorderMargin, yMin - self.angleLineWidth / 2.0 - self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMax + self.angleLineWidth - self.angleWidth + self.angleBorderMargin, yMin - self.angleLineWidth / 2.0 - self.angleBorderMargin);
    CGContextMoveToPoint(context, xMax + self.angleLineWidth / 2.0 + self.angleBorderMargin, yMin - self.angleLineWidth - self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMax + self.angleLineWidth / 2.0 + self.angleBorderMargin, yMin - self.angleLineWidth + self.angleHeight - self.angleBorderMargin);
    // 右下角
    CGContextMoveToPoint(context, xMax + self.angleLineWidth + self.angleBorderMargin, yMax + self.angleLineWidth / 2.0 + self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMax + self.angleLineWidth - self.angleWidth + self.angleBorderMargin, yMax + self.angleLineWidth / 2.0 + self.angleBorderMargin);
    CGContextMoveToPoint(context, xMax + self.angleLineWidth / 2.0 + self.angleBorderMargin, yMax + self.angleLineWidth + self.angleBorderMargin);
    CGContextAddLineToPoint(context, xMax + self.angleLineWidth / 2.0 + self.angleBorderMargin, yMax + self.angleLineWidth - self.angleHeight + self.angleBorderMargin);
    CGContextStrokePath(context);
}

/// 点击"我的二维码"按钮事件
- (void)myCodeClicked:(UIButton *)btn {
    if (self.codeScanBlock) {
        self.codeScanBlock();
    }
}

/// 点击闪光灯按钮事件
- (void)flashBtnClicked:(UIButton *)flashBtn {
    self.flashOpen = !self.flashOpen;
    [MZCodeScanTool openFlashSwitch:self.flashOpen];
    if (self.flashSwitchBlock) {
        self.flashSwitchBlock(self.flashOpen);
    }
}

#pragma mark - Notification
- (void)appWillEnterForeground {
    [self startScanAnimation];
}

- (void)appWillEnterBackground {
    [self stopScanAnimation];
}

#pragma mark - Function
- (void)startScanAnimation {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    [self startScan];
}

- (void)stopScanAnimation {
    self.scanLine.frame = CGRectMake(self.scanRect.origin.x, self.scanRect.origin.y, self.scanRect.size.width, 2.0);
    self.isAnimating = NO;
    [self.scanLine.layer removeAllAnimations];
}

- (void)startScan {
    [UIView animateWithDuration:3.0 animations:^{
        self.scanLine.frame = CGRectMake(self.scanRect.origin.x, self.scanRect.origin.y + self.scanRect.size.height - 2.0, self.scanRect.size.width, 2.0);
    } completion:^(BOOL finished) {
        if (finished) {
            self.scanLine.frame = CGRectMake(self.scanRect.origin.x, self.scanRect.origin.y, self.scanRect.size.width, 2.0);
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.05];
        }
    }];
}

/// 正在处理扫描到的结果
- (void)handlingResultsOfScan {
    if (!self.handlingView) {
        [self addSubview:self.handlingView];
    }
    [self.activityView startAnimating];
}

/// 完成扫描结果处理
- (void)handledResultsOfScan {
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    self.activityView = nil;
    [self.handlingView removeFromSuperview];
    self.handlingView = nil;
}

/// 是否显示闪光灯开关
- (void)showFlashSwitch:(BOOL)show {
    self.flashBtn.hidden = !show;
}

- (void)dealloc {
    [self stopScanAnimation];
    [self handledResultsOfScan];
    [MZNotificationDefault removeObserver:self];
}

@end
