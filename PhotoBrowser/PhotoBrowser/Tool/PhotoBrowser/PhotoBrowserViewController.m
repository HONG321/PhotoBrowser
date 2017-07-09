//
//  PhotoBrowserViewController.m
//  14-ocWeibo
//
//  Created by 郑鸿钦 on 16/6/4.
//  Copyright © 2016年 Leedian. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "UIButton+CZAddition.h"
#import "PhotoViewCell.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface PhotoBrowserViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,PhotoViewCellDelegate,UIViewControllerInteractiveTransitioning,UIViewControllerContextTransitioning>
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *closeButton;

// 照片的缩放比例
@property (nonatomic, assign) CGFloat photoScale;
@end

@implementation PhotoBrowserViewController

#pragma mark - 转场动画代理方法
// transitionContext 提供转场所需要的所有信息
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    // 缩放视图
    self.view.transform = CGAffineTransformMakeScale(self.photoScale, self.photoScale);
    // 设置透明度
    self.view.alpha = self.photoScale;
}

 ///  转场动画中，这个函数很重要，告诉转场动画结束
- (void)completeTransition:(BOOL)didComplete{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)containerView{
    return self.view.superview;
}

- (BOOL)isAnimated{
    return YES;
}

- (BOOL)isInteractive{
    return YES;
}

- (BOOL)transitionWasCancelled{
    return YES;
}

- (UIModalPresentationStyle)presentationStyle{
    return UIModalPresentationCustom;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete{
    
}

- (void)finishInteractiveTransition{
    
}

- (void)cancelInteractiveTransition{
    
}

- (void)pauseInteractiveTransition {
    
}

- (UIViewController *)viewControllerForKey:(NSString *)key{
    return self;
}

- (UIView *)viewForKey:(NSString *)key{
    return self.view;
}

- (CGAffineTransform)targetTransform{
    return CGAffineTransformIdentity;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc{
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc{
    return CGRectZero;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

// 完成布局子视图
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self prepareLayout];
    
    // 跳转到用户选定的页面
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)prepareLayout{
    self.layout.itemSize = self.collectionView.bounds.size;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.minimumLineSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.pagingEnabled = YES;
}

- (void)loadView{
    // 将视图的大小“设大”
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    screenBounds.size.width += 20;
    
    self.view = [[UIView alloc] initWithFrame:screenBounds];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.closeButton];
    self.collectionView.frame = self.view.bounds;
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.bottom.equalTo(self.view.mas_bottom).offset(-12);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    [self.saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self prepareCollectionView];
}

static NSString *HMPhotoBrowserCellReuseIdentifier = @"HMPhotoBrowserCellReuseIdentifier";
- (void)prepareCollectionView{
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[PhotoViewCell class] forCellWithReuseIdentifier:HMPhotoBrowserCellReuseIdentifier];
}

- (void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save{
    // 1、拿到图像
    UIImage *image = [self currentImageView].image;
    
    // 2、保存图像 - 回调方法的参数是固定的
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

// 返回当前显示图片的索引
- (NSInteger)currentImageIndex{
    return self.collectionView.indexPathsForVisibleItems.lastObject.item;
}

// 获得当前显示的 图像视图
- (UIImageView *)currentImageView{
    // 0、拿到当前的cell
    NSIndexPath *indexPath = self.collectionView.indexPathsForVisibleItems.lastObject;
    PhotoViewCell *cell = (PhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    // 1、拿到图像
    return cell.imageView;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error != nil){
        [SVProgressHUD showErrorWithStatus:@"保存出错"];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    }
}

- (instancetype)initWithUrls:(NSArray *)urls index:(NSInteger)index{
    if(self =[super initWithNibName:nil bundle:nil]){
        self.imageURLs = urls;
        self.currentIndex = (int)index;
    }
    return self;
}

#pragma mark - UICollectionView数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HMPhotoBrowserCellReuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageURL = self.imageURLs[indexPath.item];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - 代理方法
// 点击关闭
- (void)photoViewCellDidTapImage{
    [self close];
}


// 缩放进行中
- (void)photoViewCellDidZooming:(CGFloat)scale{
    // 交互式转场
    // 记录缩放比例
    self.photoScale = scale;
    
    // 隐藏控件
    [self hideControl:self.photoScale < 1.0];
    // 判断如果缩放比例小于 1，开始交互式转场
    if(self.photoScale < 1.0){
        [self startInteractiveTransition:self];
    }else{
        // 恢复形变
        self.view.transform = CGAffineTransformIdentity;
        self.view.alpha = 1.0;
    }
}


- (void)photoViewDidEndZoom{
    // 判断当前的缩放比例
    if(self.photoScale < 0.8){
        // 直接关闭 － 告诉转场动画结束
        [self completeTransition:YES];
    }else{
        // 恢复控件
        [self hideControl:NO];
        // 恢复形变
        self.view.transform = CGAffineTransformIdentity;
        self.view.alpha = 1.0;
    }
}

- (void)hideControl:(BOOL)isHidden{
    self.view.backgroundColor = isHidden ? [UIColor clearColor] : [UIColor blackColor];
    self.saveButton.hidden = isHidden;
    self.closeButton.hidden = isHidden;
}

#pragma mark - 懒加载控件
- (UICollectionViewFlowLayout *)layout{
    if(_layout == nil){
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (UICollectionView *)collectionView{
    if(_collectionView == nil){
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    }
    return _collectionView;
}

- (UIButton *)saveButton{
    if(_saveButton == nil){
        _saveButton = [UIButton cz_textButton:@"保存" fontSize:14 normalColor:[UIColor whiteColor] highlightedColor:[UIColor brownColor]];
    }
    return _saveButton;
}

- (UIButton *)closeButton{
    if(_closeButton == nil){
        _closeButton = [UIButton cz_textButton:@"关闭" fontSize:14 normalColor:[UIColor whiteColor] highlightedColor:[UIColor brownColor]];
    }
    return _closeButton;
}
@end
