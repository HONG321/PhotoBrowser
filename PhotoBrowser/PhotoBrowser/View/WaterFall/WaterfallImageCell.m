//
//  WaterfallImageCell.m
//  10-瀑布流
//
//  Created by apple on 15/4/29.
//  Copyright (c) 2015年. All rights reserved.
//

#import "WaterfallImageCell.h"
#import "UIImageView+WebCache.h"
#import "Shop.h"

@interface WaterfallImageCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation WaterfallImageCell

- (void)setShop:(Shop *)shop {
    _shop = shop;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:shop.img]];
    self.priceLabel.text = shop.price;
}

@end
