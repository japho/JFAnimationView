//
//  JFAnimationView.h
//  AnimationDemo
//
//  Created by Japho on 2018/10/31.
//  Copyright © 2018 Japho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGAPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@class JFAnimationView;

typedef NS_ENUM(NSUInteger, JFAnimationType) {
    AnimationTypeSVGA = 0,
    AnimationTypeLottie
};

typedef void (^JFAnimationCompletionBlock)(BOOL animationFinished);
typedef void (^JFAnimationResourceCompletionBlcok)(CGRect animationBounds, BOOL loadFinished);

@protocol JFAnimationViewDelegate <NSObject>


/**
 动画结束回调代理

 @param animationView 动画视图
 */
- (void)animationViewDidFinishedAnimation:(JFAnimationView *)animationView;


/**
 动画调用失败

 @param animationView 动画视图
 */
- (void)animationViewDidFailed:(JFAnimationView *)animationView;

@end

@interface JFAnimationView : UIView

@property (nonatomic, assign) JFAnimationType animationType; //在设置其他属性之前，需设置此属性
@property (nonatomic, assign) BOOL loopAnimation;   //动画是否循环
@property (nonatomic, assign) id<JFAnimationViewDelegate> delegate;
@property (nonatomic, copy) JFAnimationCompletionBlock completionBlock; //动画完成回调block
@property (nonatomic, copy) JFAnimationResourceCompletionBlcok resourceComplitionBlock; //动画资源加载完成动画


/**
 类初始化方法

 @param frame frame
 @param animationType 动画类型
 @return 动画视图
 */
+ (instancetype)animationViewWithFrame:(CGRect)frame animationType:(JFAnimationType)animationType;

/**
 对象初始化方法

 @param frame frame
 @param animationType 动画类型
 @return 动画视图
 */
- (instancetype)initWithFrame:(CGRect)frame animationType:(JFAnimationType)animationType;

/**
 设置本地动画资源

 @param name 本地动画名称
 @param bundle 图片bundle
 @param resourceComplition 资源加载完成回调 返回动画bounds，及是否加载完成状态（完成状态只有SVGA会返回）
 */
- (void)setAnimationResourceWithName:(NSString *)name bundle:(NSBundle *)bundle resourceCompliton:(JFAnimationResourceCompletionBlcok)resourceComplition;

/**
 设置网络动画资源

 @param urlString urlString
 @param resourceComplition 资源加载完成回调 返回动画bounds，及是否加载完成状态（完成状态只有SVGA会返回）
 */
- (void)setAnimationResourceWithUrlString:(NSString *)urlString resourceComplition:(JFAnimationResourceCompletionBlcok)resourceComplition;

/**
 开始动画
 */
- (void)startAnimating;


/**
 结束动画
 */
- (void)stopAnimating;


/**
 开始动画

 @param completion 动画完成后回调 （只有Lottie会返回是否成功状态）
 */
- (void)startAnimatingWithCompletion:(JFAnimationCompletionBlock)completion;


/**
 替换SGVA动画中的图片

 解析SVGA资源文件：http://svga.io/svga-preview.html
 
 @param image 将要替换的资源图片
 @param key SVGA动画中被替换资源图片的key
 */
- (void)setImage:(UIImage *)image forSVGAAnimationWithKey:(NSString *)key;


/**
 设置SVGA动画中图片上方文字

 解析SVGA资源文件：http://svga.io/svga-preview.html
 
 @param attributedText attributedText
 @param key SVGA动画中添加文字于资源图片的key
 */
- (void)setAttributedText:(NSAttributedString *)attributedText forSVGAAnimationWithKey:(NSString *)key;


/**
 设置SVGA动画中替换Layer
 
 解析SVGA资源文件：http://svga.io/svga-preview.html

 @param drawingBlock 将自定义Layer添加至contentLayer上
 @param key SVGA动画中替换layer的key
 */
- (void)setDrawingBlock:(SVGAPlayerDynamicDrawingBlock)drawingBlock forSVGAAnimationWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
