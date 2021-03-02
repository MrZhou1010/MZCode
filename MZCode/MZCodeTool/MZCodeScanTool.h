//
//  MZCodeScanTool.h
//  MZCode
//
//  Created by Mr.Z on 2019/8/6.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  扫描完成的回调
 *  @param scanString 扫描出的字符串
 */
typedef void (^MZCodeScanFinishedBlock)(NSString * __nullable scanString);

/**
 *  监听环境光感的回调
 *  @param brightness 亮度值
 */
typedef void (^MZCodeMonitorLightBlock)(float brightness);

@interface MZCodeScanTool : NSObject

/// 扫描出结果后的回调,注意循环引用的问题
@property (nonatomic, copy) MZCodeScanFinishedBlock __nullable scanFinishedBlock;

/// 监听环境光感的回调,如果!=nil表示开启监测环境亮度功能
@property (nonatomic, copy) MZCodeMonitorLightBlock __nullable monitorLightBlock;

/// 初始化扫描工具
/// @param preview 展示输出流的视图
/// @param scanFrame 扫描识别区域
- (instancetype)initWithPreview:(UIView *)preview andScanFrame:(CGRect)scanFrame;

/// 开启扫描
- (void)sessionStartRunning;

/// 停止扫描
- (void)sessionStopRunning;

/// 闪光灯开关
/// @param on 闪光灯开关
+ (void)openFlashSwitch:(BOOL)on;

/// 识别图中二维码
/// @param codeImage 二维码图片
/// @param failure 识别失败
- (void)scanQRCodeImage:(UIImage *)codeImage failure:(void (^)(NSString * __nullable errString))failure;

/// 生成自定义样式二维码
/// @param codeString 字符串
/// @param size 大小
+ (UIImage *)createQRCodeImageWithString:(NSString *)codeString size:(CGSize)size;

/// 生成自定义样式条形码
/// @param codeString 字符串
/// @param size 大小
+ (UIImage *)createBarCodeImageWithString:(NSString *)codeString size:(CGSize)size;

/// 生成自定义样式二维码
/// @param codeString 字符串
/// @param size 大小
/// @param frontColor 前景色
/// @param backColor 背景色
/// @param centerImage 中心图片
+ (UIImage *)createQRCodeImageWithString:(NSString *)codeString size:(CGSize)size frontColor:(UIColor * __nullable)frontColor backColor:(UIColor * __nullable)backColor centerImage:(UIImage * __nullable)centerImage;

@end

NS_ASSUME_NONNULL_END
