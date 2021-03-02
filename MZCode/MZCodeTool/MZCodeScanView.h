//
//  MZCodeScanView.h
//  MZCode
//
//  Created by Mr.Z on 2019/8/6.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MZCodeScanBlock)(void);

typedef void (^MZFlashSwitchBlock)(BOOL open);

@interface MZCodeScanView : UIView

/// 点击"我的二维码"的回调
@property (nonatomic, copy) MZCodeScanBlock codeScanBlock;

/// 打开/关闭闪光灯的回调
@property (nonatomic, copy) MZFlashSwitchBlock flashSwitchBlock;

/// 扫码区域,默认为正方形
@property (nonatomic, assign) CGRect scanRect;

/// 是否需要绘制扫码矩形框,默认YES
@property (nonatomic, assign) BOOL isShowBorder;

/// 矩形框线条颜色,默认clearColor
@property (nonatomic, strong, nullable) UIColor *borderColor;

/// 4个角的颜色,默认greenColor
@property (nonatomic, strong, nullable) UIColor *angleColor;

/// 扫码区域4个角的宽度 默认为20.0
@property (nonatomic, assign) CGFloat angleWidth;

/// 扫码区域4个角的高度 默认为20.0
@property (nonatomic, assign) CGFloat angleHeight;

/// 扫码区域4个角的线条宽度 默认4.0
@property (nonatomic, assign) CGFloat angleLineWidth;

/// 扫码区域4个角与矩形框间距 默认2.0
@property (nonatomic, assign) CGFloat angleBorderMargin;

/// 动画效果的图像
@property (nonatomic, strong, nullable) UIImage *animationImage;

/// 闪光灯效果的图像
@property (nonatomic, strong, nullable) UIImage *flashLightImage;

/// 非识别区域颜色,默认RGBA(0, 0, 0, 0.5)
@property (nonatomic, strong, nullable) UIColor *notRecoginitonAreaColor;

/// 闪光灯开关的状态
@property (nonatomic, assign, readonly) BOOL flashOpen;

/// 是否显示"我的二维码",默认YES
@property (nonatomic, assign) BOOL isShowMyCode;

/// 是否显示描述信息,默认YES
@property (nonatomic, assign) BOOL isShowTipDescription;

/// 描述信息
@property (nonatomic, copy) NSString *tipDescription;

/// 开始扫描动画
- (void)startScanAnimation;

/// 结束扫描动画
- (void)stopScanAnimation;

/// 正在处理扫描到的结果
- (void)handlingResultsOfScan;

/// 完成扫描结果处理
- (void)handledResultsOfScan;

/// 是否显示闪光灯开关
/// @param show YES or NO
- (void)showFlashSwitch:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
