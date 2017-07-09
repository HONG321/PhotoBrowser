//
//  WaterfallLayout.h
//  10-瀑布流
//
//  Created by apple on 15/4/29.
//  Copyright (c) 2015年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterfallLayout : UICollectionViewFlowLayout

/// 列数
@property (nonatomic, assign) NSInteger columnCount;
/// 数据数组(w, h)
@property (nonatomic, strong) NSArray *dataList;

@end
