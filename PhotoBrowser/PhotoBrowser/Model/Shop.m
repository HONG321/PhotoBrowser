//
//  Shop.m
//  10-瀑布流
//
//  Created by apple on 15/4/29.
//  Copyright (c) 2015年. All rights reserved.
//

#import "Shop.h"

@implementation Shop

+ (instancetype)shopWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}

+ (NSArray *)shopsWithIndex:(NSInteger)index {
    NSString *fileName = [NSString stringWithFormat:@"%zd.plist", (index % 3) + 1];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [arrayM addObject:[self shopWithDict:obj]];
    }];
    
    // 提示：之所以返回 copy，建立一个不可变的数组，外界无法修改
    // 否则，外面可以通过 id 其他的方法修改数组内容，不够安全！
    return arrayM.copy;
}

@end
