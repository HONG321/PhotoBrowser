//
//  PhotoBrowserViewController.h
//  14-ocWeibo
//
//  Created by 郑鸿钦 on 16/6/4.
//  Copyright © 2016年 Leedian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserViewController : UIViewController
// 图像的数据
@property (nonatomic,strong) NSArray *imageURLs;
// 用户选中照片的索引
@property (nonatomic,assign) int currentIndex;

- (instancetype)initWithUrls:(NSArray *)urls index:(NSInteger)index;

// 返回当前显示图片的索引
- (NSInteger)currentImageIndex;
// 获得当前显示的 图像视图
- (UIImageView *)currentImageView;
@end
