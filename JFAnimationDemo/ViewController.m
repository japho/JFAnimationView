//
//  ViewController.m
//  AnimationDemo
//
//  Created by Japho on 2018/10/30.
//  Copyright © 2018 Japho. All rights reserved.
//

#import "ViewController.h"
#import "JFAnimationView.h"

@interface ViewController () <JFAnimationViewDelegate>

@property (nonatomic, strong) JFAnimationView *animationView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"JFAnimationView";
    
    UIBarButtonItem *svgaButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SVGA" style:UIBarButtonItemStyleDone target:self action:@selector(svgaAction)];
    UIBarButtonItem *lottieButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lottie" style:UIBarButtonItemStyleDone target:self action:@selector(lottieAction)];
    UIBarButtonItem *stopButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleDone target:self action:@selector(stopAction)];
    UIBarButtonItem *replaceSvgaButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Replace" style:UIBarButtonItemStyleDone target:self action:@selector(replaceSvgaAction)];
    
    self.navigationItem.rightBarButtonItems = @[replaceSvgaButtonItem, svgaButtonItem, lottieButtonItem];
    self.navigationItem.leftBarButtonItem = stopButtonItem;
    
    [self.view addSubview:self.animationView];
}

- (void)lottieAction
{
    NSArray *arrItem = @[
                         @"planeData.json",
                         @"volcanoData.json"
                         ];
    
    NSString *randomName = [arrItem objectAtIndex:arc4random() % arrItem.count];
    
    self.animationView.animationType = AnimationTypeLottie;
    
    __weak typeof(self) weakSelf = self;
    [self.animationView setAnimationResourceWithName:randomName bundle:[NSBundle mainBundle] resourceCompliton:^(CGRect animationBounds, BOOL loadFinished) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (loadFinished)
        {
            [strongSelf.animationView startAnimating];
        }
        
    }];
}

- (void)svgaAction
{
    NSArray *arrItem = @[
                         @"angel.svga",
                         @"i_love_u.svga",
                         @"tunr_over_brand.svga",
                         @"pay_wages.svga"
                         ];
    
    NSString *randomName = [arrItem objectAtIndex:arc4random() % arrItem.count];
    
    self.animationView.animationType = AnimationTypeSVGA;
    
    __weak typeof(self) weakSelf = self;
    [self.animationView setAnimationResourceWithName:randomName bundle:[NSBundle mainBundle] resourceCompliton:^(CGRect animationBounds, BOOL loadFinished) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (loadFinished)
        {
            [strongSelf.animationView startAnimating];
        }
        
    }];
}

- (void)replaceSvgaAction
{
    self.animationView.animationType = AnimationTypeSVGA;
    
    __weak typeof(self) weakSelf = self;
    [self.animationView setAnimationResourceWithName:@"online_pair" bundle:[NSBundle mainBundle] resourceCompliton:^(CGRect animationBounds, BOOL loadFinished) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (loadFinished)
        {
            [strongSelf replaceSouceImageAndText];
            [strongSelf.animationView startAnimating];
        }
        
    }];
}

- (void)stopAction
{
    [self.animationView stopAnimating];
}

#pragma mark - --- private methods ---

/**  Repalce the animation resouce
 *
 *  http://svga.io/svga-preview.html        Parse the SVGA resource file to find the required KEY to replace
 *
 */
- (void)replaceSouceImageAndText
{
    [self.animationView setImage:[self imageWithSourceImage:[UIImage imageNamed:@"about-BY-gentle.jpg"]] forSVGAAnimationWithKey:@"user1"];
    [self.animationView setImage:[self imageWithSourceImage:[UIImage imageNamed:@"about-BY-gentle.jpg"]] forSVGAAnimationWithKey:@"user2"];
    
    NSMutableAttributedString *attrStr1 = [[NSMutableAttributedString alloc] initWithString:@"UserName1"];
    [attrStr1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(0, attrStr1.length)];
    [attrStr1 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrStr1.length)];
    
    [self.animationView setAttributedText:attrStr1 forSVGAAnimationWithKey:@"username1"];
    
    NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:@"UserName2"];
    [attrStr2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(0, attrStr2.length)];
    [attrStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrStr2.length)];
    
    [self.animationView setAttributedText:attrStr2 forSVGAAnimationWithKey:@"username2"];
}

/**
 Private method - cut image
 */
- (UIImage *)imageWithSourceImage:(UIImage *)sourceImage
{
    UIGraphicsBeginImageContext(sourceImage.size);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height)];
    [path addClip];
    [sourceImage drawAtPoint:CGPointZero];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - --- JFAnimationView Delegate ---

- (void)animationViewDidFinishedAnimation:(JFAnimationView *)animationView
{
    NSLog(@"%s",__func__);
}

- (void)animationViewDidFailed:(JFAnimationView *)animationView
{
    NSLog(@"%s",__func__);
}

#pragma mark - --- Setter / Getter ---

- (JFAnimationView *)animationView
{
    if (!_animationView)
    {
        _animationView = [JFAnimationView animationViewWithFrame:self.view.frame animationType:AnimationTypeSVGA];
        _animationView.loopAnimation = NO;
        _animationView.contentMode = UIViewContentModeScaleAspectFit;
        _animationView.delegate = self;
    }
    
    return _animationView;
}

@end

