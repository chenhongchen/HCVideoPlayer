//
//  HCProgressImageView.m
//  FLAnimatedImage
//
//  Created by chc on 2020/3/2.
//
#define kPicsMaxCol 10
#define kPicsMaxRow 10
#define kPicsSpanSec 10
#define kSmallPicW 160
#define kSmallPicH 90

#import "HCProgressImageView.h"
#import "HCVideoPlayerConst.h"
#import "UIImageView+WebCache.h"
#import "NSString+VP.h"

@interface HCProgressImageView ()
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, weak) UIView *imageContentView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, strong) NSMutableArray *cacheImageViewsM;
@end

@implementation HCProgressImageView

#pragma mark - 懒加载
- (UIView *)imageContentView
{
    if (_imageContentView == nil) {
        UIView *imageContentView = [[UIView alloc] init];
        [self addSubview:imageContentView];
        _imageContentView = imageContentView;
        imageContentView.clipsToBounds = YES;
        imageContentView.layer.cornerRadius = 6;
    }
    return _imageContentView;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.imageContentView addSubview:imageView];
        _imageView = imageView;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.vp_width = kSmallPicW * kPicsMaxCol;
        imageView.vp_height = kSmallPicH * kPicsMaxRow;
    }
    return _imageView;
}

- (UILabel *)label
{
    if (_label == nil) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        _label = label;
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (NSMutableArray *)cacheImageViewsM
{
    if (_cacheImageViewsM == nil) {
        _cacheImageViewsM = [NSMutableArray array];
    }
    return _cacheImageViewsM;
}

#pragma mark - 外部方法
- (void)setPlayUrl:(NSString *)playUrl
{
    _playUrl = playUrl;
    [self cacheAllImages];
    [self loadCurImage];
}

- (void)setTotalSec:(NSTimeInterval)totalSec
{
    _totalSec = totalSec;
    [self cacheAllImages];
}

- (void)setCurSec:(NSTimeInterval)curSec
{
    _curSec = curSec;
    [self loadCurImage];
    [self setLabelTimeText];
    [self setupFrame];
}

- (void)showWithCurSec:(NSTimeInterval)curSec
{
    self.curSec = curSec;
    self.hidden = NO;
    self.alpha = 1;
}

- (void)hiddenSelf
{
    if (self.alpha == 0) {
        return;
    }
    [UIView animateWithDuration:0.15 delay:0.5 options:0 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0;
        self.hidden = YES;
        self.backgroundColor = kVP_ColorWithHexValueA(0x000000, 0.5);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickSelf)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

- (void)dealloc
{
}

#pragma mark - 事件
- (void)didClickSelf
{
    [self hiddenSelf];
}

#pragma mark - 内部方法
- (void)setupFrame {
    BOOL isZoomOutShow = (self.vp_width == MAX(kVP_ScreenWidth, kVP_ScreenHeight));
    if (self.imageView.image && isZoomOutShow) {
        self.imageContentView.vp_width = kSmallPicW;
        self.imageContentView.vp_height = kSmallPicH;
        self.imageContentView.vp_x = (self.vp_width - self.imageContentView.vp_width) * 0.5;
        self.imageContentView.vp_y = (self.vp_height - self.imageContentView.vp_height) * 0.5;
        
        self.label.vp_height = 25;
        self.label.vp_width = self.vp_width;
        self.label.vp_x = 0;
        self.label.vp_y = CGRectGetMinY(self.imageContentView.frame) - 8 - self.label.vp_height;
        self.label.font = kVP_Font(18);
    }
    else {
        self.imageContentView.frame = CGRectZero;
        self.label.vp_height = 40;
        self.label.vp_width = self.vp_width;
        self.label.vp_x = 0;
        self.label.vp_y = (self.vp_height - self.label.vp_height) * 0.5;
    }
}

- (void)cacheAllImages
{
    if (_totalSec <= 0) {
        return;
    }
    if (![_playUrl containsString:@"play.m3u8"]) {
        return;
    }
    NSInteger totalCount = ceil(_totalSec / (kPicsMaxCol * kPicsMaxRow * kPicsSpanSec));
    
    for (int i = 1; i <= totalCount; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%d.jpg", i];
        NSString *picUrl = [_playUrl componentsSeparatedByString:@"play.m3u8"].firstObject;
        picUrl = [picUrl stringByAppendingPathComponent:fileName];
//        NSLog(@"cacheAllImages picUrl %d = %@", i, picUrl);
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.cacheImageViewsM addObject:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:picUrl]];
    }
}

- (void)loadCurImage
{
    if (_curSec <= 0) {
        return;
    }
    if (![_playUrl containsString:@"play.m3u8"]) {
        return;
    }
    int intSec = (int)_curSec;
    int fileIndex = (intSec / (kPicsMaxCol * kPicsMaxRow * kPicsSpanSec)) + 1;
    NSString *fileName = [NSString stringWithFormat:@"%d.jpg", fileIndex];
    
    NSString *picUrl = [self.playUrl componentsSeparatedByString:@"play.m3u8"].firstObject;
    picUrl = [picUrl stringByAppendingPathComponent:fileName];

//    NSLog(@"loadCurImage picUrl %d = %@", fileIndex, picUrl);
    if (![_picUrl isEqualToString:picUrl] || self.imageView.image == nil) {
        _picUrl = picUrl;
        self.imageView.image = nil;
        __weak typeof(self) weakSelf = self;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:_picUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf setupFrame];
            [weakSelf setSmallPicShow];
        }];
    }
    else {
        [self setSmallPicShow];
    }
}

- (void)setSmallPicShow
{
    int intSec = (int)_curSec;
    int leftSec = intSec % (kPicsMaxCol * kPicsMaxRow * kPicsSpanSec);
    int index = leftSec / 10;
    
    NSInteger col = index % kPicsMaxCol;
    NSInteger row = index / kPicsMaxCol;
    self.imageView.vp_x = -col * kSmallPicW;
    self.imageView.vp_y = -row * kSmallPicH;
//    NSLog(@"imageView.frame = %@", NSStringFromCGRect(self.imageView.frame));
}

- (void)setLabelTimeText
{
    NSString *curTimeText = [NSString vp_formateStringFromSec:_curSec];
    NSString *totalTimeText = [NSString vp_formateStringFromSec:_totalSec];
    NSString *text = [NSString stringWithFormat:@"%@/%@", curTimeText, totalTimeText];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSForegroundColorAttributeName] = kVP_ColorWithHexValueA(0x1F93EA, 1);
    NSRange range = [text rangeOfString:curTimeText];
    [attrString setAttributes:attrDict range:range];
    self.label.attributedText = attrString;
}
@end
