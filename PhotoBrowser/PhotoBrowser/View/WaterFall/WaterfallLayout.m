//
//  WaterfallLayout.m
//  10-瀑布流
//
//  Created by apple on 15/4/29.
//  Copyright (c) 2015年. All rights reserved.
//

#import "WaterfallLayout.h"
#import "Shop.h"

@interface WaterfallLayout()
// 所有 item 的属性数组
@property (nonatomic, strong) NSArray *layoutAttributes;
@end

@implementation WaterfallLayout

/// 准备布局，当 collectionView 的布局发生变化时，会被调用
/// 通常是做布局的准备工作，itemSize,....
/// 准备布局的时候，dataList 已经有值
/// UICollectionView 的 contentSize 是根据 itemSize 动态计算出来的！
- (void)prepareLayout {
    // 1. item 的宽度，根据列数，每个列的宽度是固定
    CGFloat contentWidth = self.collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right;
    CGFloat itemWidth = (contentWidth - (self.columnCount - 1) * self.minimumInteritemSpacing) / self.columnCount;
    
    // 2. 计算布局属性
    [self attributes:itemWidth];
}

/// 计算布局属性
/**
 1. 找到最高的列
 2. 知道最高列中的 item 的个数
 
 为了避免出现某一列特别短，应该每次追加列的时候，应该向最短的列追加
 */
- (void)attributes:(CGFloat)itemWidth {
    
    // 定义一个列高的数组，记录每一列最大的高度
    CGFloat colHeight[self.columnCount];
    // 每列中 item 的计数
    NSInteger colCount[self.columnCount];
    for (int i = 0; i < self.columnCount; ++i) {
        colHeight[i] = self.sectionInset.top;
        colCount[i] = 0;
    }
    
    // 定义总item高
    CGFloat totoalItemHeight = 0;
    
    // 遍历 dataList 数组计算相关的属性
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:self.dataList.count];
    
    NSInteger index = 0;
    for (Shop *shop in self.dataList) {
        
        // 1> 建立布局属性
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
        
        // 2> 计算当前列数
//        NSInteger col = index % self.columnCount;
        NSInteger col = [self shortestCol:colHeight];
        
        // 将对应列数的数组计数+1
        colCount[col]++;
        
        // 3> 设置frame
        // X
        CGFloat x = self.sectionInset.left + col * (itemWidth + self.minimumInteritemSpacing);
        // Y
        CGFloat y = colHeight[col];
        // height
        CGFloat h = [self itemHeightWith:CGSizeMake(shop.w, shop.h) itemWidth:itemWidth];
        totoalItemHeight += h;
        
        attr.frame = CGRectMake(x, y, itemWidth, h);
        
        // 4> 累加列高
        colHeight[col] += h + self.minimumLineSpacing;
        
        index++;
        
        [arrayM addObject:attr];
    }
    
    // 设置 itemSize，使用总高度的平均值
    // 找到最高的列
    NSInteger highestCol = [self highestCol:colHeight];
    CGFloat h = (colHeight[highestCol] - colCount[highestCol] * self.minimumLineSpacing) / colCount[highestCol];
    
    // collectionView 的 contentSize 是由 itemSize 来计算获得
    self.itemSize = CGSizeMake(itemWidth, h);
    
    // 添加页脚属性
    UICollectionViewLayoutAttributes *footerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    footerAttr.frame = CGRectMake(0, colHeight[highestCol] - self.minimumLineSpacing, self.collectionView.bounds.size.width, 50);
    
    [arrayM addObject:footerAttr];
    
    // 给属性数组设置数值
    self.layoutAttributes = arrayM.copy;
}

/// 计算最短的列
- (NSInteger)shortestCol:(CGFloat *)colHeight {
    
    CGFloat min = MAXFLOAT;
    NSInteger col = 0;
    
    for (int i = 0; i < self.columnCount; ++i) {
        if (colHeight[i] < min) {
            min = colHeight[i];
            col = i;
        }
    }
    return col;
}

/// 计算最高列
- (NSInteger)highestCol:(CGFloat *)colHeigth {
    
    CGFloat max = 0;
    NSInteger col = 0;
    
    for (int i = 0; i < self.columnCount; ++i) {
        if (colHeigth[i] > max) {
            max = colHeigth[i];
            col = i;
        }
    }
    return col;
}

/// 等比例计算 item 高度
- (CGFloat)itemHeightWith:(CGSize)size itemWidth:(CGFloat)itemWidth {
    return size.height * itemWidth / size.width;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 直接返回计算完成的 属性数组
    return self.layoutAttributes;
}

@end
