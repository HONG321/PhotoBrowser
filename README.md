# PhotoBrowser
基于控制器交互式转场动画实现的图片查看器，集成略微复杂，可做为学习用。主界面是瀑布流布局，同时添加了Peek & Pop操作。

## 文件描述：
### Model
  主界面瀑布流对象模型。
 
### Tool
#### Additions
 按钮的便利构造方法
#### PhotoBrowser
 图片查看器的实现。如果图片缩放比例小于1，开始交互式转场。如果小于0.8，结束转场动画。

### View
 主界面瀑布流界面相关。

### Controller
 主界面瀑布流控制器。在LDWaterFallCollectionViewController实现转场动画的具体实现，包括点击图片时，图片放大的动画；结束转场动画时，计算目标cell的frame,将图片查看器cell中的图片动画叠加形变到主界面目标cell上。  
 在viewDidLoad方法中注册Peek&Pop的代理。  
 在- (UIViewController *)previewingContext:中实现peek的代理方法，在WaterFall.storyboard中添加要显示的界面样式。  
 在- (void)previewingContext:中实现pop的代理方法。pop到图片查看控制器。  

在PreviewPhotoViewController中实现预览操作项数组（即peed的时候向上滑动出现的“复制”和“关闭”菜单）。
