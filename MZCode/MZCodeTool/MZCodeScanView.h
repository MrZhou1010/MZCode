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

/** 点击我的二维码的回调 */
@property (nonatomic, copy) MZCodeScanBlock codeScanBlock;
/** 打开/关闭闪光灯的回调 */
@property (nonatomic, copy) MZFlashSwitchBlock flashSwitchBlock;
/** 扫码区域,默认为正方形,x = 100,y = 100 */
@property (nonatomic, assign) CGRect scanRect;
/** 是否需要绘制扫码矩形框,默认YES */
@property (nonatomic, assign) BOOL isShowBorder;
/** 矩形框线条颜色 */
@property (nonatomic, strong, nullable) UIColor *borderColor;
/** 4个角的颜色 */
@property (nonatomic, strong, nullable) UIColor *angleColor;
/** 扫码区域4个角的宽度 默认为20 */
@property (nonatomic, assign) CGFloat angleWidth;
/** 扫码区域4个角的高度 默认为20 */
@property (nonatomic, assign) CGFloat angleHeight;
/** 扫码区域4个角的线条宽度 默认4 */
@property (nonatomic, assign) CGFloat angleLineWidth;
/** 扫码区域4个角与矩形框间距 默认2 */
@property (nonatomic, assign) CGFloat angleBorderMargin;
/** 动画效果的图像 */
@property (nonatomic, strong, nullable) UIImage *animationImage;
/** 非识别区域颜色,默认RGBA(0, 0, 0, 0.5) */
@property (nonatomic, strong, nullable) UIColor *notRecoginitonAreaColor;
/** 闪光灯开关的状态 */
@property (nonatomic, assign) BOOL flashOpen;

/**
 *  开始扫描动画
 */
- (void)startScanAnimation;

/**
 *  结束扫描动画
 */
- (void)stopScanAnimation;

/**
 *  正在处理扫描到的结果
 */
- (void)handlingResultsOfScan;

/**
 *  完成扫描结果处理
 */
- (void)handledResultsOfScan;

/**
 *  是否显示闪光灯开关
 *  @param show YES or NO
 */
- (void)showFlashSwitch:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
