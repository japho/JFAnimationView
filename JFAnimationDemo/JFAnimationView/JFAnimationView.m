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


