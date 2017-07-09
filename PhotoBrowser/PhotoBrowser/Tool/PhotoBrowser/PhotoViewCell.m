//
//  PhotoViewCell.m
//  14-ocWeibo
//
//  Created by 郑鸿钦 on 16/6/5.
//  Copyright © 2016年 Leedian. All rights reserved.
//

#import "PhotoViewCell.h"
#import "UIImageView+WebCache.h"

@interface PhotoViewCell ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation PhotoViewCell

- (void)setImageURL:(NSURL *)imageURL{
    // 重设scrollView
    [self resetScrollView];
    
    // 显示菊花
    [self.indicator startAnimating];
    
    _imageURL = imageURL;
    [self.imageView sd_setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // 隐藏菊花
        [self.indicator stopAnimating];
        
        // 下载完成之后，自动设置图像尺寸
        [self.imageView sizeToFit];
        
        [self imagePosition:image];
    }];
}

// 重设scrollView内容参数
- (void)resetScrollView{
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = CGSizeZero;
}

// 设置图片位置
- (void)imagePosition:(UIImage *)image{
    // 计算y值
    CGSize size = [self displaySize:image];
    
    // 判断是否是长图
    if(self.bounds.size.height < size.height){
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentSize = size;
    }else {
        // 短图
        CGFloat y = (self.frame.size.height - size.height) * 0.5;
        self.imageView.frame = CGRectMake(0, y, size.width, size.height);
        
        // 设置scrollView的边距
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    }
}

/// 根据图像计算显示的尺寸
- (CGSize)displaySize:(UIImage *)image{
    CGFloat scale = image.size.height / image.size.width;
    CGFloat h = self.scrollView.bounds.size.width * scale;
    return CGSizeMake(self.scrollView.bounds.size.width, h);
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.scrollView];
        self.scrollView.frame = [UIScreen mainScreen].bounds;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 0.5;
        self.scrollView.maximumZoomScale = 2.0;
        [self.scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [self.imageView addGestureRecognizer:tap];
        self.imageView.userInteractionEnabled = YES;
        
        [self addSubview:self.indicator];
        self.indicator.center = self.center;
    }
    return self;
}

- (void)clickImage{
    if([self.delegate respondsToSelector:@selector(photoViewCellDidTapImage)]){
        [self.delegate photoViewCellDidTapImage];
    }
}

#pragma mark - UIScrollView数据源
// 告诉scrollView缩放谁
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

///  缩放过程中，会频繁调用
/**
 var a: CGFloat  缩放
 var b: CGFloat
 var c: CGFloat
 var d: CGFloat  缩放
 var tx: CGFloat 位移
 var ty: CGFloat 位移
 
 a, b, c, d, 共同决定旋转
 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // 拿到缩放比例
    CGFloat scale = self.imageView.transform.a;
    [self.delegate photoViewCellDidZooming:scale];
}

/// 缩放结束，会执行一次
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    // 如果scale < 0.8 直接解除转场
    if(scale >= 0.8){
        // 重新计算边距
        CGFloat offsetX = (self.scrollView.frame.size.width - view.frame.size.width) * 0.5;
        
        if(offsetX < 0) {
            offsetX = 0;
        }
        
        
        CGFloat offsetY = (self.scrollView.frame.size.height - view.frame.size.height) * 0.5;
        if(offsetY < 0){
            offsetY = 0;
        }
        
        // 重新设置边距
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
    }

    // 通知代理完成缩放
    [self.delegate photoViewDidEndZoom];
}

- (UIScrollView *)scrollView{
    if(_scrollView == nil){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    }
    return _scrollView;
}

- (UIImageView *)imageView{
    if(_imageView == nil){
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIActivityIndicatorView *)indicator{
    if(_indicator == nil){
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicator;
}

@end
