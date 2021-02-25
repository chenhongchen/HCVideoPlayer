//
//  HCSelectTvDevController.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/7.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCSelectTvDevController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HCGoogleCastTool.h"
#import <SmartView/SmartView.h>
#import "HCVediosCastManualController.h"

@interface HCSelectTvDevController () <CLUPnPServerDelegate, UITableViewDataSource, UITableViewDelegate, ServiceSearchDelegate>
/// Dlna
@property (nonatomic, strong) CLUPnPServer *upd;
@property (nonatomic, strong) NSArray <CLUPnPDevice *> *dlnaDevs;
/// Samsung
@property (nonatomic, strong) ServiceSearch *ss;
@property (nonatomic, strong) NSArray <Service *> *samsungDevs;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) UIStatusBarStyle fromStatusBarStyle;
@end

@implementation HCSelectTvDevController
#pragma mark - 懒加载
- (CLUPnPServer *)upd
{
    if (_upd == nil) {
        _upd = [CLUPnPServer shareServer];
        _upd.delegate = self;
        _upd.searchTime = 10;
    }
    return _upd;
}

- (ServiceSearch *)ss
{
    if (_ss == nil) {
        _ss = [Service search];
        _ss.delegate = self;
    }
    return _ss;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc] init];
        [self.view addSubview:tableView];
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
//        if (@available(iOS 11.0, *)) {
//            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
//        else
//        {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
    }
    return _tableView;
}

#pragma mark - 初始化
+ (void)initialize
{
    [HCGoogleCastTool initCast];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [HCGoogleCastTool initCast];
    [self setupUI];
    [self setupTableHeaderView];
    [self setupTableFooterView];
    self.fromStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [self startAll];
}

- (void)dealloc
{
    VPLog(@"dealloc - HCSelectTvDevController");
    [self stopAll];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.fromStatusBarStyle;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"投电视";
    UIImage *image = [[UIImage vp_imageWithName:@"vp_backNav"] vp_imageMaskWithColor:kVP_TextBlackColor];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    UIColor *color = kVP_TextBlackColor;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage vp_imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addCastItemForNavigationBar];
}

- (void)setupTableHeaderView
{
    UIView *headerView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"请选择要投射的设备";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = kVP_TextGrayColor;
    titleLabel.frame = CGRectMake(12, 22, kVP_ScreenWidth - 24, 26);
    [headerView addSubview:titleLabel];
    
    headerView.bounds = CGRectMake(0, 0, kVP_ScreenWidth, 48);
    self.tableView.tableHeaderView = headerView;
}

- (void)setupTableFooterView
{
    UIView *tableFooterView = [[UIView alloc] init];
    tableFooterView.backgroundColor = kVP_BgColor;
    
    // searchingView
    UIView *searchingView = [[UIView alloc] init];
    searchingView.backgroundColor = [UIColor whiteColor];
    CGFloat searchViewHeight = (self.dlnaDevs.count + self.samsungDevs.count) ? 0 : 48;
    searchingView.frame = CGRectMake(0, 0, kVP_ScreenWidth, searchViewHeight);
    searchingView.clipsToBounds = YES;
    [tableFooterView addSubview:searchingView];
    
    UIView *hLine = [[UIView alloc] init];
    hLine.backgroundColor = kVP_LineColor;
    hLine.frame = CGRectMake(0, 0, kVP_ScreenWidth, 0.5);
    [searchingView addSubview:hLine];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];//指定进度轮的大小
    [activity startAnimating];
    [searchingView addSubview:activity];
    
    UILabel *searchLabel = [[UILabel alloc] init];
    searchLabel.text = @"正在搜索设备...";
    searchLabel.font = [UIFont systemFontOfSize:16];
    searchLabel.textColor = kVP_TextBlackColor;
    [searchingView addSubview:searchLabel];
    
    CGSize size = [searchLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, searchViewHeight)];
    CGFloat width = activity.bounds.size.width;
    CGFloat height = activity.bounds.size.height;
    CGFloat padding = 10;
    CGFloat totalWidth = width + size.width + padding;
    CGFloat x = (kVP_ScreenWidth - totalWidth) * 0.5;
    CGFloat y = (searchViewHeight - height) * 0.5;
    activity.frame = CGRectMake(x, y, width, height);
    
    x = floor(CGRectGetMaxX(activity.frame) + padding);
    y = floor((searchViewHeight - size.height) * 0.5);
    width = size.width;
    height = size.height;
    searchLabel.frame = CGRectMake(x, y, width, height);
    
    // imageView
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [tableFooterView addSubview:bgView];
    
    UIButton *castCueBtn = [[UIButton alloc] init];
    [bgView addSubview:castCueBtn];
    castCueBtn.backgroundColor = kVP_Color(41, 149, 231,1);
    [castCueBtn setTitle:@"点我查看投屏步骤" forState:UIControlStateNormal];
    castCueBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    width = 200;
    height = 36;
    x = (kVP_ScreenWidth - width) * 0.5;
    y = 15;
    castCueBtn.layer.cornerRadius = height * 0.5;
    castCueBtn.clipsToBounds = YES;
    castCueBtn.frame = CGRectMake(x, y, width, height);
    [castCueBtn addTarget:self action:@selector(didClickCastCueBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage vp_imageWithName:@"vp_tv_description"]];
    size = [imageView sizeThatFits:CGSizeMake(kVP_ScreenWidth, CGFLOAT_MAX)];
    width = size.width;
    height = size.height;
    x = (kVP_ScreenWidth - width) * 0.5;
    imageView.frame = CGRectMake(x, CGRectGetMaxY(castCueBtn.frame), width, height);
    
    bgView.frame = CGRectMake(0, CGRectGetMaxY(castCueBtn.frame) + 20, kVP_ScreenWidth, CGRectGetMaxY(imageView.frame));
    [bgView addSubview:imageView];
    bgView.backgroundColor = [UIColor whiteColor];
    tableFooterView.frame = CGRectMake(0, 0, kVP_ScreenWidth, CGRectGetMaxY(bgView.frame));
    _imageView = imageView;
    self.tableView.tableFooterView = tableFooterView;
}

#pragma mark - 事件
- (void)backAction {
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForSelectTvDevController:)]) {
        [self.delegate didClickBackBtnForSelectTvDevController:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickCastCueBtn
{
    HCVediosCastManualController *vc = [[HCVediosCastManualController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - googleCast通知
- (void)setCastControlBarsEnabled:(BOOL)notificationsEnabled {
    _castContainerVC.miniMediaControlsItemEnabled = notificationsEnabled;
}

- (BOOL)castControlBarsEnabled {
    return _castContainerVC.miniMediaControlsItemEnabled;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _samsungDevs.count;
    }
    else {
        return _dlnaDevs.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textColor = kVP_TextBlackColor;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        UIView *hLine = [[UIView alloc] init];
        hLine.backgroundColor = kVP_LineColor;
        hLine.frame = CGRectMake(0, 0, kVP_ScreenWidth, 0.5);
        [cell.contentView addSubview:hLine];
    }
    
    if (indexPath.section == 0) {
        Service *samsungDev = self.samsungDevs[indexPath.row];
        cell.textLabel.text = samsungDev.name;
    }
    else {
        CLUPnPDevice *dlnaDev = self.dlnaDevs[indexPath.row];
        cell.textLabel.text = dlnaDev.friendlyName;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        Service *samsungDev = self.samsungDevs[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(selectTvDevController:didSelectSamsungDev:)]) {
            [self.delegate selectTvDevController:self didSelectSamsungDev:samsungDev];
        }
    }
    else {
        CLUPnPDevice *device = self.dlnaDevs[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(selectTvDevController:didSelectDlnaDev:)]) {
            [self.delegate selectTvDevController:self didSelectDlnaDev:device];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLUPnPServerDelegate
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    if (devices.count > 0) {
        self.dlnaDevs = [devices mutableCopy];
        // 去重：主要是dlna中包含三星设备，要去掉
        [self duplicateDevsRemoval];
        [self.tableView reloadData];
        [self setupTableFooterView];
    }
    VPLog(@"upnpSearchChangeWithResults %ld", devices.count);
}

- (void)upnpSearchErrorWithError:(NSError *)error{
    VPLog(@"error==%@", error);
}


#pragma mark - ServiceSearchDelegate
- (void)onServiceFound:(Service * __nonnull)service
{
    _samsungDevs = [_ss getServices];
    // 去重：主要是dlna中包含三星设备，要去掉
    [self duplicateDevsRemoval];
    [self.tableView reloadData];
    [self setupTableFooterView];
}

/// The ServiceSearch will call this delegate method when a service is lost
///
/// \param service The lost service
- (void)onServiceLost:(Service * __nonnull)service
{
    _samsungDevs = [_ss getServices];
    [self.tableView reloadData];
}

/// If BLE device is found
- (void)onFoundOnlyBLE:(NSString * _Nonnull)NameOfTV
{
}

/// Find other network (other than BLE)
- (void)onFoundOtherNetwork:(NSString * _Nonnull)NameOfTV
{
}

/// The ServiceSearch will call this delegate method after stopping the search
- (void)onStop
{
}

/// The ServiceSearch will call this delegate method after the search has started
- (void)onStart{
}

#pragma mark - 内部方法
- (void)startAll
{
    [self.upd start];
    [self.ss start];
}

- (void)stopAll
{
    [self.upd stop];
    [self.ss stop];
}

/// 为导航栏添加google投屏和AirPlay投屏按钮
- (void)addCastItemForNavigationBar
{
    // 添加Airplay投屏 按钮
    MPVolumeView *volume = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 100, 44, 44)];
    volume.showsVolumeSlider = NO;
    [volume sizeToFit];
    UIImage *airPlayImage = [UIImage vp_imageWithName:@"vp_airplay"];
    UIImage *airPlayImageNor = [airPlayImage vp_imageMaskWithColor:kVP_TextBlackColor];
    UIImage *airPlayImageSel = [airPlayImage vp_imageMaskWithColor:[UIColor blueColor]];
    [volume setRouteButtonImage:airPlayImageNor forState:UIControlStateNormal];
    [volume setRouteButtonImage:airPlayImageSel forState:UIControlStateSelected];
    [volume setRouteButtonImage:airPlayImageSel forState:UIControlStateHighlighted];
    UIBarButtonItem *airPlayCastItem = [[UIBarButtonItem alloc] initWithCustomView:volume];
    
    if (kVP_IOS9 && [GCKCastContext isSharedInstanceInitialized]) { // iOS9 及以上才兼容，且初始化
        // 添加google投屏 按钮
        GCKUICastButton *googleCastButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        googleCastButton.tintColor = kVP_TextBlackColor;
        UIBarButtonItem *googleCastItem = [[UIBarButtonItem alloc] initWithCustomView:googleCastButton];
        
        self.navigationItem.rightBarButtonItems = @[airPlayCastItem, googleCastItem];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[airPlayCastItem];
    }
}

- (void)duplicateDevsRemoval
{
    NSMutableArray *dlnaDevsM = [NSMutableArray arrayWithArray:_dlnaDevs];
    for (CLUPnPDevice *dlnaDev in _dlnaDevs) {
        for (Service *samsumDev in _samsungDevs) {
            if ([samsumDev.name isEqualToString:dlnaDev.friendlyName]) {
                [dlnaDevsM removeObject:dlnaDev];
                break;
            }
        }
    }
    _dlnaDevs = dlnaDevsM;
}
@end
