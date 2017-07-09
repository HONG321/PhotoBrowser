//
//  Shop.h
//  10-瀑布流
//
//  Created by apple on 15/4/29.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shop : NSObject

@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, assign) float w;
@property (nonatomic, assign) float h;

+ (instancetype)shopWithDict:(NSDictionary *)dict;
/// 根据索引加载店铺数组
+ (NSArray *)shopsWithIndex:(NSInteger)index;

@end
