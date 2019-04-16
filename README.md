## 前言

在开发APP的过程中，需要在APP中实现设计同学的UE效果动画，一般都是通过代码实现的，当对于较复杂的动画时，例如直播中刷礼物时的动画，这时利用代码实现会比较复杂。而且`Android`和`iOS`两端不好统一效果，如果用gif图片来实现的话，在图片大小和动画帧数之间很难权衡。而且会导致内存吃紧。为了解决这样的问题，今天来介绍两款实现复杂动画的开源库：`Lottie`和`SVGA`。

## Lottie 

>Lottie is a mobile library for Android and iOS that parses Adobe After Effects animations exported as json with bodymovin and renders the vector animations natively on mobile and through React Native!

大致意思是：`Lottie`是一个可以解析使用【[bodymovin](https://github.com/airbnb/lottie-web)】插件从 `Adobe After Effects` 中导出的格式为`json`的文件，并在`iOS`、`Android`、`macOS`、`React Native`中进行解析使用的开源库。

[官方链接](https://github.com/airbnb/lottie-ios)

部分效果：

![](https://upload-images.jianshu.io/upload_images/1722373-7bf8a4735413147c.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/800/format/webp)

![](https://upload-images.jianshu.io/upload_images/1722373-2f17af8843802c88.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/800/format/webp)

### 优点&&缺点

**优点：**

- 开发成本低，设计师导出json后，开发同学只需引用文件即可。
- 支持服务端URL创建，服务端可以配置`json`文件，随时替换动画。
- 性能提升，替换原使用帧图完成的动画，节省客户端空间和内存。
- 跨平台，`iOS`、`Android`使用一套方案，效果统一。
- 支持转场动画

**缺点：**

- 对某些AE属性不支持。
- 对平台有限制，iOS 8.0 以上，Android API 14 以上。
- 交互动画不可行，主要是播放类型动画。

### 集成Lottie

官方地址：[https://github.com/airbnb/lottie-ios](https://github.com/airbnb/lottie-ios)，github 中有 Demo 提供学习。

集成方法可以使用Cocoapods，或手动集成。

**Cocoapods集成**

一、在podfile中添加：

```
pod 'lottie-ios'
```
二、运行

```
pod install
```

假如你的项目之前集成过其他三方，比如`Masonry`，这个时候你编译项目，可能会报`code1`错误，当然没报错最好。稍安勿躁，人家官方文档说了，还得安装`Carthage`。

>**安装Carthage**
>
>```
>brew install carthage
>```
>
>**使用Carthage安装依赖**
>
>1、前往文件夹
>
>```
>cd ~/路径/项目文件夹
>```
>
>2、创建一个空的 Carthage 文件 Cartfile
>
>```
>touch Cartfile
>```
>
>3、使用 Xcode 打开 Cartfile 文件
>
>```
>open -a Xcode Cartfile
>```
>
>4、在cartfile里面加一行代码
>
>```
>github "airbnb/lottie-ios" "master"
>```
>
>5、终端执行更新命令
>
>```
>carthage update --platform iOS
>```

**手动集成Lottie**

将`demo`中的`lottie-ios`文件夹拖入项目中即可

### Lottie的使用

Lottie头文件：

`LOTAnimationView.h`

```swift
//创建视图的几个方法
+ (instancetype)animationNamed:(NSString *)animationName NS_SWIFT_NAME(init(name:));
+ (instancetype)animationNamed:(NSString *)animationName inBundle:(NSBundle *)bundle NS_SWIFT_NAME(init(name:bundle:));
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON NS_SWIFT_NAME(init(json:));
- (instancetype)initWithContentsOfURL:(NSURL *)url;

//可用属性
@property(nonatomic,readonly)BOOLisAnimationPlaying;   //是否正在动画
@property(nonatomic,assign)BOOLloopAnimation;          //是否循环播放动画
@property(nonatomic,assign)CGFloatanimationProgress;   //动画执行进度
@property(nonatomic,assign)CGFloatanimationSpeed;      //动画速度
@property(nonatomic,readonly)CGFloatanimationDuration; //动画时间

//实例方法
- (void)playWithCompletion:(LOTAnimationCompletionBlock)completion;//动画结束后可以执行一个block
- (void)play;    //播放
- (void)pause;   //暂停
- (void)addSubview:(LOTView *)view toLayerNamed:(NSString *)layer;

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
@property(nonatomic) LOTViewContentMode contentMode;//非iOS的contentMode
#endif
```

最简单粗暴的方式就是`LOTAnimationView`来进行初始化，也是比较常用的方式：

```swift
LOTAnimationView *animation = [LOTAnimationView animationNamed:@"Lottie"];
[self.view addSubview:animation];
[animation playWithCompletion:^(BOOL animationFinished) {
  // Do Something
}];
```

当你使用了多个`bundle`文件时，可以使用以下方法：

```swift
LOTAnimationView *animation = [LOTAnimationView animationNamed:@"Lottie" inBundle:[NSBundle YOUR_BUNDLE]];
[self.view addSubview:animation];
[animation playWithCompletion:^(BOOL animationFinished) {
  // Do Something
}];
```

或者使用URL进行动态加载，注意这里json文件的图片则需要使用网络图片：

```swift
LOTAnimationView *animation = [[LOTAnimationView alloc] initWithContentsOfURL:[NSURL URLWithString:URL]];
[self.view addSubview:animation];
```

效果：

感谢老铁的火山！

![](https://ws1.sinaimg.cn/large/006tNbRwly1fwyesgf1kdg309m0jq4qr.gif)

## SVGA

[官方链接](http://svga.io/)

SVGAConverter 可以将 Flash 以及 After Effects 动画导出成 .SVGA 文件（实际上是 ZIP 包），供 SVGAPlayer 在各平台播放，SVGAPlayer 支持在 iOS / Android / Web / ReactNative / LayaBox 等平台、游戏引擎播放。

SVGA 做的事情，实际上，非常简单，Converter 会负责从 Flash 或 AE 源文件中提取所有动画元素（位图、矢量），并将其在时间轴中的每帧表现（位移、缩放、旋转、透明度）导出。 Player 会负责将这些信息还原至画布上。

因此，你会发现，SVGA 既有序列帧的特点，又有元素动画的特点。Player 逻辑极度简单，她只负责粗暴地将每一个元素，丝毫不差地渲染到屏幕上，而无须任何插值计算。（我们认为，任何插件计算的逻辑都是复杂的）

也因此，你会发现，SVGA 不同于 Lottie，Lottie 需要在 Player 一层完整地将 After Effects 所有逻辑实现，而 SVGA 则将这些逻辑免去。也因此，SVGA 可以同时支持 Flash，我们相信 Flash 以及其继承者 Animate CC 仍然有强大的生命力，以及完善的设计生态。

SVGA 最初的目标是为降低序列帧动画开销而生的，因此，性能问题一直是 SVGA 关注的焦点。如果你可以深入地探究 SVGA 的实现方式，你会发现，SVGA 实质上做了一件非常重要的事情。她会在动画播放前，一次性地上传所有纹理到 GPU，接着，在播放的过程中，这些纹理会被重复使用。CPU 与 GPU 交换的次数大大减少，同时，纹理的数目也在可控范围。内存、CPU、GPU 占用能达到最优状态。

### SVGA的集成

官方 GitHub：[https://github.com/yyued/SVGAPlayer-iOS](https://github.com/yyued/SVGAPlayer-iOS), GitHub 中有 Demo 提供学习。

一、在podfile中添加：

```
pod 'SVGAPlayer'
```
二、运行

```
pod install
```

### 手动集成踩雷

因为项目中未使用 Cocoapods ，所以要求手动集成 SVGA 到项目中，但是官方仅提供了 pods 的集成方法，下面来说下手动集成的问题：

1、在 [GitHub](https://github.com/yyued/SVGAPlayer-iOS)中下载项目工程，将以下文件夹导入工程：

>`Protobuf`,`SSZipArchive`,`SVGAPlayer`

此时 build 可能会报错头文件不存在，采用以下方法：

>Targets -> Build Settings -> Header Search Pahts 添加路径

```
"$(SRCROOT)/JFAnimationDemo/Libs/Protobuf/objectivec"
"$(SRCROOT)/JFAnimationDemo/Libs/SSZipArchive"
```

`注意：`这里根据项目中具体类的位置进行相应的修改。

解决头文件不存在问题之后，下面可能会出现内存管理方法不可调用的问题。这是因为代码库中的部分类使用的是非ARC，所以需要对部分类进行配置：

>Targets -> Build Phrases -> Compile Sources 修改以下类的 Compiler Flags
>
>设置 Compiler Flags 为 `-fno-objc-arc`

>`GPBCodedOutputStream.m`,
`GPBCodedInputStream.m`,
`GPBUnknownFieldSet.m`,
`GPBUtilities.m`,
`GPBExtensionInternals.m`,
`GPBArray.m`,
`GPBRootObject.m`,
`GPBExtensionRegistry.m`,
`GPBDescriptor.m`,
`Struct.pbobjc.m`,
`GPBWellKnownTypes.m`,
`Svga.pbobjc.m`,
`GPBDictionary.m`,
`Type.pbobjc.m`,
`GPBMessage.m`,
`GPBUnknownField.m`

### SVGA的使用

首先初始化 `SVGAPlayer` 对象：

```swift
- (SVGAPlayer *)svgaPlayer
{
    if (!_svgaPlayer)
    {
        _svgaPlayer = [[SVGAPlayer alloc] init];
        _svgaPlayer.frame = self.bounds;
        _svgaPlayer.loops = 1;
        _svgaPlayer.clearsAfterStop = YES;
        _svgaPlayer.delegate = self;
    }
    
    return _svgaPlayer;
}
```

然后初始化 `SVGAParser` 对象：

```swift
- (SVGAParser *)svgaParser
{
    if (!_svgaParser)
    {
        _svgaParser = [[SVGAParser alloc] init];
    }
    
    return _svgaParser;
}
```

加载动画，主要有三种方式：

- URL、Request
- Data
- Name

`SVGAParser.h` 头文件中有如下方法：

```swift
- (void)parseWithURL:(nonnull NSURL *)URL
     completionBlock:(void ( ^ _Nonnull )(SVGAVideoEntity * _Nullable videoItem))completionBlock
        failureBlock:(void ( ^ _Nullable)(NSError * _Nullable error))failureBlock;

- (void)parseWithURLRequest:(nonnull NSURLRequest *)URLRequest
            completionBlock:(void ( ^ _Nonnull )(SVGAVideoEntity * _Nullable videoItem))completionBlock
               failureBlock:(void ( ^ _Nullable)(NSError * _Nullable error))failureBlock;

- (void)parseWithData:(nonnull NSData *)data
             cacheKey:(nonnull NSString *)cacheKey
      completionBlock:(void ( ^ _Nullable)(SVGAVideoEntity * _Nonnull videoItem))completionBlock
         failureBlock:(void ( ^ _Nullable)(NSError * _Nonnull error))failureBlock;

- (void)parseWithNamed:(nonnull NSString *)named
              inBundle:(nullable NSBundle *)inBundle
       completionBlock:(void ( ^ _Nullable)(SVGAVideoEntity * _Nonnull videoItem))completionBlock
          failureBlock:(void ( ^ _Nullable)(NSError * _Nonnull error))failureBlock;
```

调用此方法后，将返回的 `videoItem` 对象赋值，然后开始加载动画：

```swift
__weak __typeof(&*self)weakSelf = self;

[self.svgaParser parseWithNamed:self.animationName inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                
	__strong __typeof(self)strongSelf = weakSelf;
	strongSelf.svgaPlayer.videoItem = videoItem;
	[strongSelf.svgaPlayer startAnimation];
                
} failureBlock:^(NSError * _Nonnull error) {
                
	NSLog(@"Error: %@",error);
                
}];
```

**效果：**

感谢老铁的香吻！

![](https://ws4.sinaimg.cn/large/006tNbRwly1fwyfwpw7t2g309m0jqkbn.gif)

### One More Thing

SVGA 的官方库中提供了替换图层的 API ，什么意思呢？

可能我们会有这样的需求：我们所需要的动画中，部分图层是需要可配置的，例如以下效果：

![](https://ws4.sinaimg.cn/large/006tNbRwly1fwygdezcjng308a08g75k.gif)

需求要求配对双方的头像可配置，而且需配置他们的用户名，这时我们可以调用以下方法进行实现。

```swift
#pragma mark - Dynamic Object

- (void)setImage:(UIImage *)image forKey:(NSString *)aKey;
- (void)setImageWithURL:(NSURL *)URL forKey:(NSString *)aKey;
- (void)setImage:(UIImage *)image forKey:(NSString *)aKey referenceLayer:(CALayer *)referenceLayer; // deprecated from 2.0.1
- (void)setAttributedText:(NSAttributedString *)attributedText forKey:(NSString *)aKey;
```

这里的 key 是事先和设计同学商定的，也可以拿到 SVGA 文件后进行解析，这里官网提供了一个在线的解析网址：[http://svga.io/svga-preview.html](http://svga.io/svga-preview.html),

可以解析 SVGA 文件中用户头像的图层名称为 “user1” 调用相应方法进行替换即可。

![](https://ws1.sinaimg.cn/large/006tNbRwly1fwygi4g5lkj31kw0v5gt3.jpg)

替换图层之后的效果：

![](https://ws3.sinaimg.cn/large/006tNbRwly1fwyglyds7jg308a08gdhx.gif)

## The Last 

项目中同时集成了 SVGA、Lottie 两套代码库，为了平时更高效的进行开发，将其封装为同一工具类，暴露出共有部分，方便使用。写的不好的地方，大家多提意见😉


`JFAnimationView.h`

```swift
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

```

`JFAnimationView.m`

```swift
//
//  JFAnimationView.m
//  AnimationDemo
//
//  Created by Japho on 2018/10/31.
//  Copyright © 2018 Japho. All rights reserved.
//

#import "JFAnimationView.h"
#import "SVGA.h"
#import "Lottie.h"

@interface JFAnimationView () <SVGAPlayerDelegate>

@property (nonatomic, strong) SVGAPlayer *svgaPlayer;
@property (nonatomic, strong) SVGAParser *svgaParser;
@property (nonatomic, strong) LOTAnimationView *lotAnimationView;
@property (nonatomic, assign) BOOL hasSVGALoad;
@property (nonatomic, assign) BOOL hasLottieLoad;

@end

@implementation JFAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _animationType = -1;
    }
    
    return self;
}

+ (instancetype)animationViewWithFrame:(CGRect)frame animationType:(JFAnimationType)animationType
{
    return [[JFAnimationView alloc] initWithFrame:frame animationType:animationType];
}

- (instancetype)initWithFrame:(CGRect)frame animationType:(JFAnimationType)animationType
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.animationType = animationType;
    }
    
    return self;
}

- (void)setAnimationResourceWithName:(NSString *)name bundle:(NSBundle *)bundle resourceCompliton:(nonnull JFAnimationResourceCompletionBlcok)resourceComplition
{
    NSArray *components = [name componentsSeparatedByString:@"."];
    name = components.firstObject;
    
    switch (self.animationType)
    {
        case AnimationTypeSVGA:
        {
            __weak __typeof(&*self)weakSelf = self;
            
            [self.svgaParser parseWithNamed:name inBundle:bundle completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                
                __strong __typeof(self)strongSelf = weakSelf;
                strongSelf.svgaPlayer.videoItem = videoItem;
                
                CGRect bounds = CGRectMake(0, 0, videoItem.videoSize.width, videoItem.videoSize.height);
                resourceComplition(bounds, YES);
                
            } failureBlock:^(NSError * _Nonnull error) {
                
                NSLog(@"Error: %@",error);
                resourceComplition(CGRectZero, NO);
                
            }];
            
            break;
        }
        case AnimationTypeLottie:
        {
            if (bundle == nil)
            {
                bundle = [NSBundle mainBundle];
            }
            
            LOTComposition *comp = [LOTComposition animationNamed:name inBundle:bundle];
            [self.lotAnimationView setSceneModel:comp];
            resourceComplition(comp.compBounds, YES);
            
            break;
        }
        default:
            break;
    }
}

- (void)setAnimationResourceWithUrlString:(NSString *)urlString resourceComplition:(JFAnimationResourceCompletionBlcok)resourceComplition
{
    switch (self.animationType)
    {
        case AnimationTypeSVGA:
        {
            __weak __typeof(&*self)weakSelf = self;
            
            NSData *data = [NSData dataWithContentsOfFile:urlString];
            
            [self.svgaParser parseWithData:data cacheKey:urlString completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                
                __strong __typeof(self)strongSelf = weakSelf;
                strongSelf.svgaPlayer.videoItem = videoItem;
                
                CGRect bounds = CGRectMake(0, 0, videoItem.videoSize.width, videoItem.videoSize.height);
                resourceComplition(bounds, YES);
                
            } failureBlock:^(NSError * _Nonnull error) {
                
                NSLog(@"Error: %@",error);
                
                resourceComplition(CGRectZero, NO);
                
            }];
            
            break;
        }
        case AnimationTypeLottie:
        {
            LOTComposition *laScene = [[LOTAnimationCache sharedCache] animationForKey:urlString];
            if (laScene)
            {
                laScene.cacheKey = urlString;
                [self.lotAnimationView setSceneModel:laScene];
                resourceComplition(laScene.compBounds, YES);
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    
                    LOTComposition *laScene = [LOTComposition animationWithFilePath:urlString];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [[LOTAnimationCache sharedCache] addAnimation:laScene forKey:urlString];
                        laScene.cacheKey = urlString;
                        [self.lotAnimationView setSceneModel:laScene];
                        resourceComplition(laScene.compBounds, YES);
                    });
                });
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)startAnimating
{
    if (self.animationType == AnimationTypeSVGA)
    {
        [self.svgaPlayer startAnimation];
    }
    else if (self.animationType == AnimationTypeLottie)
    {
        __weak __typeof(&*self)weakSelf = self;
        
        [self.lotAnimationView playWithCompletion:^(BOOL animationFinished) {
            
            __strong __typeof(self)strongSelf = weakSelf;
            
            if (animationFinished)
            {
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(animationViewDidFinishedAnimation:)])
                {
                    [strongSelf.delegate animationViewDidFinishedAnimation:strongSelf];
                }
            }
            else
            {
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(animationViewDidFailed:)])
                {
                    [strongSelf.delegate animationViewDidFailed:strongSelf];
                }
            }
        }];
    }
}

- (void)startAnimatingWithCompletion:(JFAnimationCompletionBlock)completion
{
    self.completionBlock = completion;
    
    if (self.animationType == AnimationTypeSVGA)
    {
        [self.svgaPlayer startAnimation];
    }
    else if (self.animationType == AnimationTypeLottie)
    {
        [self.lotAnimationView playWithCompletion:^(BOOL animationFinished) {
            
            self.completionBlock(animationFinished);
            
        }];
    }
}

- (void)stopAnimating
{
    if (self.animationType == AnimationTypeSVGA)
    {
        [self.svgaPlayer stopAnimation];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(animationViewDidFinishedAnimation:)])
        {
            [self.delegate animationViewDidFinishedAnimation:self];
        }
    }
    else if (self.animationType == AnimationTypeLottie)
    {
        [self.lotAnimationView stop];
    }
}

- (void)setImage:(UIImage *)image forSVGAAnimationWithKey:(NSString *)key
{
    if (self.animationType == AnimationTypeSVGA)
    {
        [self.svgaPlayer setImage:image forKey:key];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText forSVGAAnimationWithKey:(NSString *)key
{
    if (self.animationType == AnimationTypeSVGA)
    {
        [self.svgaPlayer setAttributedText:attributedText forKey:key];
    }
}

- (void)setDrawingBlock:(SVGAPlayerDynamicDrawingBlock)drawingBlock forSVGAAnimationWithKey:(NSString *)key
{
    if (self.animationType == AnimationTypeSVGA)
    {
        [self.svgaPlayer setDrawingBlock:drawingBlock forKey:key];
    }
}

#pragma mark - --- SVGAPlayer Delegate ---

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    [player clear];

    if (self.delegate && [self.delegate respondsToSelector:@selector(animationViewDidFinishedAnimation:)])
    {
        [self.delegate animationViewDidFinishedAnimation:self];
    }
    
    if (self.completionBlock)
    {
        self.completionBlock(YES);
    }
}

#pragma mark - --- Setter & Getter ---

- (SVGAPlayer *)svgaPlayer
{
    if (!_svgaPlayer)
    {
        _svgaPlayer = [[SVGAPlayer alloc] initWithFrame:self.bounds];
        _svgaPlayer.contentMode = self.contentMode;
        _svgaPlayer.loops = 1;
        _svgaPlayer.clearsAfterStop = YES;
        _svgaPlayer.delegate = self;
    }
    
    return _svgaPlayer;
}

- (SVGAParser *)svgaParser
{
    if (!_svgaParser)
    {
        _svgaParser = [[SVGAParser alloc] init];
    }
    
    return _svgaParser;
}

- (LOTAnimationView *)lotAnimationView
{
    if (!_lotAnimationView)
    {
        _lotAnimationView = [[LOTAnimationView alloc] initWithFrame:self.bounds];
        _lotAnimationView.contentMode = self.contentMode;
    }
    
    return _lotAnimationView;
}

- (void)setLoopAnimation:(BOOL)loopAnimation
{
    _loopAnimation = loopAnimation;
    
    if (self.animationType == AnimationTypeSVGA)
    {
        self.svgaPlayer.loops = loopAnimation ? 0 : 1;
    }
    else if (self.animationType == AnimationTypeLottie)
    {
        self.lotAnimationView.loopAnimation = loopAnimation;
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    
    _lotAnimationView.contentMode = contentMode;
    _svgaPlayer.contentMode = contentMode;
}

- (void)setAnimationType:(JFAnimationType)animationType
{
    _animationType = animationType;
    
    if (animationType == AnimationTypeLottie)
    {
        if (!_hasLottieLoad)
        {
            [self addSubview:self.lotAnimationView];
            _hasLottieLoad = YES;
        }
        
        _lotAnimationView.hidden = NO;
        _svgaPlayer.hidden = YES;
    }
    else if (animationType == AnimationTypeSVGA)
    {
        if (!_hasSVGALoad)
        {
            [self addSubview:self.svgaPlayer];
            _hasSVGALoad = YES;
        }
        
        _lotAnimationView.hidden = YES;
        _svgaPlayer.hidden = NO;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _lotAnimationView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _svgaPlayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

@end


```

## 结语

大概简单的介绍了当前比较好用的两个动画加载库，希望大家对大家着手开发有所帮助，如果有问题也可以在评论区留言会这联系我的邮箱，收到后会及时回复。喜欢的老铁收藏下，双击666。好了，我们本期博客到此结束，我们下次再见。

![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1541506562699&di=92c038149b2185df3db6216ac3f69259&imgtype=0&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F8b13632762d0f703fb8b190102fa513d2697c536.jpg)
