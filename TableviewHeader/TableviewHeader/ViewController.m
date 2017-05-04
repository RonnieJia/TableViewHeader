//
//  ViewController.m
//  TableviewHeader
//
//  Created by jia on 2017/5/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import <Accelerate/Accelerate.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation ViewController
static NSString *kCellIdentifier = @"identifier_cell";
static CGFloat const kHeaderHeight = 200;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat navigationBarHeight = 64;
    if (offsetY >= -navigationBarHeight) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"second";
    
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:table];
    table.scrollIndicatorInsets = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);
    self.tableView = table;
    self.tableView.rowHeight = 60.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight)];
    imgView.image = [UIImage imageNamed:@"img"];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imgView];
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor orangeColor];
    self.imageView = imgView;
    [self.view bringSubviewToFront:self.imageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat navigationBarHeight = 64;
    if (offsetY <= -kHeaderHeight) {
        self.imageView.image = [UIImage imageNamed:@"img"];
        self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, fabs(offsetY));
    } else if (offsetY >= -navigationBarHeight) {
        self.imageView.frame = CGRectMake(0, -kHeaderHeight+navigationBarHeight, self.view.frame.size.width, kHeaderHeight);
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    } else {
        CGFloat viewAlpha = 1.0 - fabs(offsetY) / (kHeaderHeight-navigationBarHeight);
        self.imageView.image = [self blurryImage:[UIImage imageNamed:@"img"] withBlurLevel:viewAlpha];
        self.imageView.frame = CGRectMake(0, fabs(offsetY)-kHeaderHeight, self.view.frame.size.width, kHeaderHeight);
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i<20; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@"这是第%zd个",i+1]];
        }
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (image==nil)
    {
        NSLog(@"error:为图片添加模糊效果时，未能获取原始图片");
        return nil;
    }
    //模糊度,
    if (blur < 0.025f) {
        blur = 0.025f;
    } else if (blur > 1.0f) {
        blur = 1.0f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    NSLog(@"boxSize:%i",boxSize);
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    //CGColorSpaceRelease(colorSpace);   //多余的释放
    CGImageRelease(imageRef);
    return returnImage;
}

@end
