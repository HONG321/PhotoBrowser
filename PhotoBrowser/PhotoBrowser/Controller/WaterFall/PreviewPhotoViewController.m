//
//  PreviewPhotoViewController.m
//  Demo
//
//  Created by 郑鸿钦 on 2017/5/30.
//  Copyright © 2017年 Leedian. All rights reserved.
//

#import "PreviewPhotoViewController.h"
#import "UIImageView+WebCache.h"

@interface PreviewPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PreviewPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL]];
}

/// 预览操作项数组
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    id item1 = [UIPreviewAction actionWithTitle:@"复制" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"复制");
    }];
    
    id item2 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    return @[item1, item2];
}


@end
