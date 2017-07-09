//
//  LDWaterFallCollectionViewController.m
//  Demo
//
//  Created by 郑鸿钦 on 2017/5/30.
//  Copyright © 2017年 Leedian. All rights reserved.
//

#import "LDWaterFallCollectionViewController.h"
#import "Shop.h"
#import "WaterfallLayout.h"
#import "WaterfallImageCell.h"
#import "WaterfallFooterView.h"
#import "PhotoBrowserViewController.h"
#import "UIImageView+WebCache.h"
#import "PhotoViewCell.h"
#import "PreviewPhotoViewController.h"

@interface LDWaterFallCollectionViewController ()<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning,
    UIViewControllerPreviewingDelegate>
@property (nonatomic, strong) NSMutableArray *shops;
@property (weak, nonatomic) IBOutlet WaterfallLayout *layout;

// 页脚视图
@property (nonatomic, weak) WaterfallFooterView *footerView;
// 正在加载标记
@property (nonatomic, assign, getter=isLoading) BOOL loading;

// 当前的数据索引
@property (nonatomic, assign) NSInteger index;

// 1、临时的图片视图
@property (nonatomic, strong) UIImageView *presentedImageView;
// 2、目标位置
@property (nonatomic, assign) CGRect presentedFrame;

@property (nonatomic, assign) BOOL isPresented;

@property (nonatomic, assign) NSUInteger currentImageIndex;
@end

@implementation LDWaterFallCollectionViewController
#pragma mark - 转场动画代理方法
// 返回提供转场 Modal 动画的对象
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    self.isPresented = YES;
    return self;
}

// 返回提供转场 Dismiss 动画的对象
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresented = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

// 一旦实现，需要程序员提供动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    // 1、获取目标视图
    NSString *viewKey = self.isPresented ? UITransitionContextToViewKey : UITransitionContextFromViewKey;
    UIView *targetView = [transitionContext viewForKey:viewKey];
    if(targetView == nil){
        return;
    }
    
    if(self.isPresented){
        // 2、添加toView
        [[transitionContext containerView] addSubview:targetView];
        targetView.alpha = 0;
        
        // 2.1 添加临时的图片视图
        [[transitionContext containerView] addSubview:self.presentedImageView];
        
        
        // 3、动画
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.presentedImageView.frame = self.presentedFrame;
        } completion:^(BOOL finished) {
            // 删除临时图片视图
            [self.presentedImageView removeFromSuperview];
            targetView.alpha = 1.0;
            // 告诉动画完成
            [transitionContext completeTransition:YES];
        }];
    }else{
        // 0、获取要缩放的图片
        PhotoBrowserViewController *targetVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIImageView *iv = [targetVC currentImageView];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        
        // 叠加形变
        iv.transform = CGAffineTransformScale(iv.transform, targetView.transform.a, targetView.transform.a);
        // 设置图像视图的中心点
        iv.frame = [targetView convertRect:iv.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
        
        // 1、添加到容器视图
        [[transitionContext containerView] addSubview:iv];
        // 2、将目标视图直接删除
        [targetView removeFromSuperview];
        
        // 3、恢复的位置
        // 获取图片查看器的图片下标
        NSInteger photoIndex = [targetVC currentImageIndex];
        NSInteger targetIndex = self.currentImageIndex + photoIndex;
        CGRect targetFrame = [self screenFrame:targetIndex];
        
        // 4、动画
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                        targetView.frame = targetFrame;
                        targetView.alpha = 0;
            iv.frame = targetFrame;
        } completion:^(BOOL finished) {
            [targetView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}


static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // 判断设备是否支持 force touch
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 注册代理 - source View 是来源视图，用户按压的视图
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    }
    
    // 加载数据
    [self loadData];
}

/// 加载数据
- (void)loadData {
    [self.shops addObjectsFromArray:[Shop shopsWithIndex:self.index]];
    
    self.index++;
    
    // 设置布局的属性
    self.layout.columnCount = 3;
    self.layout.dataList = self.shops;
    
    // 刷新数据
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shops.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WaterfallImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    
    cell.shop = self.shops[indexPath.item];
    
    return cell;
}

/**
 参数
 kind：类型
 页头 UICollectionElementKindSectionHeader
 页脚 UICollectionElementKindSectionFooter
 
 Supplementary 追加视图
 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    // 判断是否是页脚
    if (kind == UICollectionElementKindSectionFooter) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        return self.footerView;
    }
    
    return nil;
}

// 只要滚动视图滚动，就会执行
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.footerView == nil || self.isLoading) {
        return;
    }
    
    if ((scrollView.contentOffset.y + scrollView.bounds.size.height) > self.footerView.frame.origin.y) {
        NSLog(@"开始刷新");
        // 如果正在刷新数据，不需要再次刷新
        self.loading = YES;
        [self.footerView.indicator startAnimating];
        
        // 模拟数据刷新
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 释放掉 footerView
            self.footerView = nil;
            
            [self loadData];
            self.loading = NO;
        });
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",indexPath);
    NSInteger index = indexPath.item;
    self.currentImageIndex = index;
    
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSInteger i = index; i < index + 3; i++) {
        if (i<0) {
            i=0;
        }
        Shop *shop = self.shops[i];
        [photoArray addObject:shop.img];
    }
    
    PhotoBrowserViewController *vc = [[PhotoBrowserViewController alloc] initWithUrls:photoArray.copy index:0];
    
    Shop *shop = self.shops[index];
    [self.presentedImageView sd_setImageWithURL:[NSURL URLWithString:shop.img]];
    self.presentedImageView.frame = [self screenFrame:index];
    self.presentedImageView.contentMode = UIViewContentModeScaleAspectFill;
    // 目标位置
    self.presentedFrame = [self fullScreenFrame:index];
    
    // 1、设置转场代理
    vc.transitioningDelegate = self;
    // 2、设置转场样式
    vc.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:vc animated:YES completion:nil];
}

/// 取得指定图片索引的屏幕frame
- (CGRect)screenFrame:(NSInteger)photoIndex{
   NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoIndex inSection:0];
    PhotoViewCell *cell = (PhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return [self.collectionView convertRect:cell.frame toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
}

/// 返回大图对应的全屏之后的屏幕位置
- (CGRect)fullScreenFrame:(NSInteger)photoIndex{
    Shop *shop = self.shops[photoIndex];
    // 0、取得已经缓存的图片
    NSString *urlString = shop.img;
    UIImage *image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:urlString];
    
    // 1、计算比例
    CGFloat scale = image.size.height / image.size.width;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat w = screenSize.width;
    CGFloat h = w * scale;
    CGFloat y = 0;
    if(h<screenSize.height){
        y = (screenSize.height - h) * 0.5;
    }
    return CGRectMake(0, y, w, h);
}

#pragma mark - Peek & Pop 代理
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:location];
    if (index == nil) {
        return nil;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"WaterFall" bundle:nil];
    PreviewPhotoViewController *previewVC = [sb instantiateViewControllerWithIdentifier:@"PreviewPhotoVC"];
    Shop *shop = self.shops[index.item];
    previewVC.imageURL = shop.img;
    previewVC.indexPath = index;
    previewVC.preferredContentSize = CGSizeMake(0, 280);
    return previewVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    if (![viewControllerToCommit isKindOfClass:[PreviewPhotoViewController class]]) {
        return;
    }
    PreviewPhotoViewController *preVc = (PreviewPhotoViewController *)viewControllerToCommit;
    NSUInteger index = preVc.indexPath.item;
    self.currentImageIndex = index;
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSInteger i = index; i < index + 3; i++) {
        if (i<0) {
            i=0;
        }
        Shop *shop = self.shops[i];
        [photoArray addObject:shop.img];
    }

    
    PhotoBrowserViewController *vc = [[PhotoBrowserViewController alloc] initWithUrls:photoArray.copy index:0];
    // 目标位置
    self.presentedFrame = [self fullScreenFrame:index];
    
    // 1、设置转场代理
    vc.transitioningDelegate = self;
    // 2、设置转场样式
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}



#pragma mark - 懒加载
- (NSMutableArray *)shops {
    if (_shops == nil) {
        _shops = [[NSMutableArray alloc] init];
    }
    return _shops;
}

- (UIImageView *)presentedImageView{
    if(_presentedImageView == nil){
        _presentedImageView = [[UIImageView alloc] init];
    }
    return _presentedImageView;
}

@end
