//
//  PhotoViewCell.h
//  14-ocWeibo
//
//  Created by 郑鸿钦 on 16/6/5.
//  Copyright © 2016年 Leedian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoViewCellDelegate <NSObject>

- (void)photoViewCellDidTapImage;

// 照片视图正在缩放
- (void)photoViewCellDidZooming:(CGFloat)scale;
// 照片视图完成缩放
- (void)photoViewDidEndZoom;

@end

@interface PhotoViewCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<PhotoViewCellDelegate> delegate;
@end
