//
//  MZCodeScanTool.m
//  MZCode
//
//  Created by Mr.Z on 2019/8/6.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "MZCodeScanTool.h"
#import <AVFoundation/AVFoundation.h>

@interface MZCodeScanTool () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

/** 捕获设备,默认后置摄像头 */
@property (nonatomic, strong) AVCaptureDevice *device;
/** 输入设备,摄像头捕捉到的信息 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 输出设备,需要指定他的输出类型及扫描范围 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
/** 框架捕获类的中心枢纽,协调输入输出设备以获得数据 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 展示输出流的视图——即照相机镜头下的内容 */
@property (nonatomic, strong) UIView *preview;
/** 扫描识别区域 */
@property (nonatomic, assign) CGRect scanFrame;

@end

@implementation MZCodeScanTool

#pragma mark - Lazy
- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureSession *)session {
    if (!_session) {
        // 获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input) {
            return nil;
        }
        // 创建二维码扫描输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        // 设置代理,在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        CGFloat x = CGRectGetMinX(self.scanFrame) / CGRectGetWidth(self.preview.frame);
        CGFloat y = CGRectGetMinY(self.scanFrame) / CGRectGetHeight(self.preview.frame);
        CGFloat width = CGRectGetWidth(self.scanFrame) / CGRectGetWidth(self.preview.frame);
        CGFloat height = CGRectGetHeight(self.scanFrame) / CGRectGetHeight(self.preview.frame);
        [output setRectOfInterest:CGRectMake(y, x, height, width)];
        // 创建环境光感输出流
        AVCaptureVideoDataOutput *lightOutput = [[AVCaptureVideoDataOutput alloc] init];
        [lightOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        if ([_session canAddInput:input]) {
            [_session addInput:input];
        }
        if ([_session canAddOutput:output]) {
            [_session addOutput:output];
            [_session addOutput:lightOutput];
        }
        // 设置扫码支持的编码格式(条形码和二维码)
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    }
    return _session;
}

- (instancetype)initWithPreview:(UIView *)preview andScanFrame:(CGRect)scanFrame {
    if (self == [super init]) {
        self.preview = preview;
        self.scanFrame = scanFrame;
        [self configureCodeScanTool];
    }
    return self;
}

- (void)configureCodeScanTool {
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    previewLayer.frame = self.preview.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.preview.layer insertSublayer:previewLayer atIndex:0];
}

- (void)sessionStartRunning {
    [self.session startRunning];
}

- (void)sessionStopRunning {
    [self.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        [[self class] openFlashSwitch:NO];
        if (self.scanFinishedBlock) {
            self.scanFinishedBlock(metadataObject.stringValue);
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    if (brightnessValue < -8.0) {
        [[self class] openFlashSwitch:YES];
    }
    if (self.monitorLightBlock) {
        self.monitorLightBlock(brightnessValue);
    }
}

/// 闪光灯开关
+ (void)openFlashSwitch:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]) {
        [device lockForConfiguration:nil];
        if (on) {
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
        } else {
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
        }
        [device unlockForConfiguration];
    } else {
        // 当前设备没有闪光灯,不能提供手电筒功能
    }
}

/// 识别图中二维码
- (void)scanQRCodeImage:(UIImage *)codeImage failure:(void (^)(NSString * __nullable errString))failure {
    // 创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *featureArray = [detector featuresInImage:codeImage.CIImage options:nil];
    if (featureArray.count > 0) {
        CIQRCodeFeature *codeFeature = (CIQRCodeFeature *)featureArray.firstObject;
        if(self.scanFinishedBlock) {
            self.scanFinishedBlock(codeFeature.messageString);
        }
    } else {
        // 无法识别图中二维码
        if (failure) {
            failure(@"无法识别当前图片");
        }
    }
}

#pragma mark - 生成二维码和条形码
+ (UIImage *)createQRCodeImageWithString:(NSString *)codeString size:(CGSize)size {
    CIImage *codeCIImage = [self createQRCodeImageWithString:codeString];
    UIImage *codeImage = [self resizeCodeImage:codeCIImage size:size];
    return codeImage;
}

+ (UIImage *)createBarCodeImageWithString:(NSString *)codeString size:(CGSize)size {
    CIImage *codeCIImage = [self createBarCodeImageWithString:codeString];
    UIImage *codeImage = [self resizeCodeImage:codeCIImage size:size];
    return codeImage;
}

+ (UIImage *)createQRCodeImageWithString:(NSString *)codeString size:(CGSize)size frontColor:(UIColor * __nullable)frontColor backColor:(UIColor * __nullable)backColor centerImage:(UIImage * __nullable)centerImage {
    CIImage *codeCIImage = [self createQRCodeImageWithString:codeString];
    CIImage *colorCodeCIImage = [self drawCodeImage:codeCIImage frontColor:frontColor backColor:backColor];
    CGRect extent = CGRectIntegral(colorCodeCIImage.extent);
    CGImageRef codeCGImage = [[CIContext contextWithOptions:nil] createCGImage:colorCodeCIImage fromRect:extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), codeCGImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(codeCGImage);
    // 添加中心图片
    if (centerImage) {
        UIGraphicsBeginImageContext(codeImage.size);
        [codeImage drawInRect:CGRectMake(0, 0, codeImage.size.width, codeImage.size.height)];
        CGFloat imageX = (codeImage.size.width - centerImage.size.width) * 0.5;
        CGFloat imgaeY = (codeImage.size.height - centerImage.size.height) * 0.5;
        UIImage *tempCenterImage = centerImage;
        [tempCenterImage drawInRect:CGRectMake(imageX, imgaeY, centerImage.size.width, centerImage.size.height)];
        UIImage *centerCodeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return centerCodeImage;
    }
    return codeImage;
}

/// 生成二维码图
+ (CIImage *)createQRCodeImageWithString:(NSString *)codeString {
    NSData *codeData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:codeData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    return filter.outputImage;
}

/// 生成条形码图
+ (CIImage *)createBarCodeImageWithString:(NSString *)codeString {
    NSData *codeData = [codeString dataUsingEncoding:NSASCIIStringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setDefaults];
    [filter setValue:codeData forKey:@"inputMessage"];
    [filter setValue:@(0) forKey:@"inputQuietSpace"];
    return filter.outputImage;
}

/// 处理生成的码
+ (UIImage *)resizeCodeImage:(CIImage *)codeCIImage size:(CGSize)size {
    CGRect extent = CGRectIntegral(codeCIImage.extent);
    CGFloat widthScale = size.width / CGRectGetWidth(extent);
    CGFloat heightScale = size.height / CGRectGetHeight(extent);
    size_t width = CGRectGetWidth(extent) * widthScale;
    size_t height = CGRectGetHeight(extent) * heightScale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8.0, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:codeCIImage fromRect:extent];
    CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
    CGContextScaleCTM(contentRef, widthScale, heightScale);
    CGContextDrawImage(contentRef, extent, imageRef);
    CGImageRef scaledImage = CGBitmapContextCreateImage(contentRef);
    UIImage *codeImage = [UIImage imageWithCGImage:scaledImage];
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(contentRef);
    CGImageRelease(imageRef);
    CGImageRelease(scaledImage);
    return codeImage;
}

/// 绘制颜色
+ (CIImage *)drawCodeImage:(CIImage *)codeCIImage frontColor:(UIColor *)frontColor backColor:(UIColor *)backColor {
    CIColor *frontCIColor = [CIColor colorWithCGColor:!frontColor ? [UIColor clearColor].CGColor : frontColor.CGColor];
    CIColor *backCIColor = [CIColor colorWithCGColor:!backColor ? [UIColor blackColor].CGColor : backColor.CGColor];
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage", codeCIImage, @"inputColor0", frontCIColor, @"inputColor1", backCIColor, nil];
    return colorFilter.outputImage;
}

@end
