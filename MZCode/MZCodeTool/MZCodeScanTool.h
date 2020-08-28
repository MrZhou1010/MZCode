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
typedef void (^MZCodeScanFinishedBlock)(NSString * _Nullable scanString);

/**
 *  监听环境光感的回调
 *  @param brightness 亮度值
 */
typedef void (^MZCodeMonitorLightBlock)(float brightness);

@interface MZCodeScanTool : NSObject

/** 扫描出结果后的回调,注意循环引用的问题 */
@property (nonatomic, copy) MZCodeScanFinishedBlock _Nullable scanFinishedBlock;

/** 监听环境光感的回调,如果!= nil表示开启监测环境亮度功能  */
@property (nonatomic, copy) MZCodeMonitorLightBlock _Nullable monitorLightBlock;

/**
 *  初始化 扫描工具
 *  @param preview 展示输出流的视图
 *  @param scanFrame 扫描识别区域
 */
- (instancetype)initWithPreview:(UIView *)preview andScanFrame:(CGRect)scanFrame;

/**
 *  开启扫描
 */
- (void)sessionStartRunning;

/**
 *  停止扫描
 */
- (void)sessionStopRunning;

/**
 *  闪光灯开关
 */
+ (void)openFlashSwitch:(BOOL)on;


/**
 *  识别图中二维码
 *  @param imageCode 二维码图片
 */
- (void)scanImageQRCode:(UIImage *)imageCode failure:(void (^)(NSString * _Nullable errString))failure;

/**
 生成自定义样式二维码

 @param codeString 字符串
 @param size 大小
 @return image 二维码
 */
+ (UIImage *)createQRCodeImageWithString:(NSString *)codeString andSize:(CGFloat)size;

/**
 生成自定义样式二维码

 @param codeString 字符串
 @param size 大小
 @param backColor 背景色
 @param frontColor 前景色
 @param centerImage 中心图片
 @return image 二维码
 */
+ (UIImage *)createQRCodeImageWithString:(NSString *)codeString andSize:(CGSize)size andBackColor:(nullable UIColor *)backColor andFrontColor:(nullable UIColor *)frontColor andCenterImage:(nullable UIImage *)centerImage;

@end

NS_ASSUME_NONNULL_END
