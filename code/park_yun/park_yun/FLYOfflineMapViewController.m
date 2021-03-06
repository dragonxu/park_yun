//
//  FLYOfflineMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYOfflineMapViewController.h"
#import "FLYDownloadCell.h"
#import "FLYAppDelegate.h"
#import "UIButton+Bootstrap.h"


@interface FLYOfflineMapViewController ()

@end

@implementation FLYOfflineMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"离线地图";
    }
    return self;
}


#pragma mark - UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc]init];
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *) [UIApplication sharedApplication].delegate;
    
    _searchText = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 220, 35)];
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.placeholder = @"请输入城市名称";
    if ([FLYBaseUtil isNotEmpty:appDelegate.city]) {
        _searchText.text = appDelegate.city;
    }
    [_searchText setFont:[UIFont systemFontOfSize:14.0f]];
    [self.view addSubview:_searchText];
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.frame = CGRectMake(_searchText.right + 10, 20, 60, 35);
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    _searchBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_searchBtn primaryStyle];
    [_searchBtn addTarget:self action:@selector(searchCityAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"城市列表",@"下载管理",nil];
    
    //初始化UISegmentedControl
    _segment = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segment.frame = CGRectMake(15, _searchBtn.bottom + 20 , 290, 35);
    _segment.selectedSegmentIndex = 0;//设置默认选择项索引
    _segment.tintColor= [UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1];
    [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    int top = 20 + 35 + 20 + 35;
    _cityView = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, ScreenHeight - top - 20 -44)];
    [self.view addSubview:_cityView];
    
    _downloadView = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, ScreenHeight - top - 20 -44)];
    [self.view addSubview:_downloadView];
    _downloadView.hidden = YES;
    
    
    _cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, _cityView.width, _cityView.height - 10)];
    _cityTableView.tag = 101;
    _cityTableView.delegate = self;
    _cityTableView.dataSource = self;
    
    [_cityView addSubview:_cityTableView];
    
    _downloadTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, _downloadView.width, _downloadView.height - 10)];
    _downloadTableView.tag = 102;
    _downloadTableView.delegate = self;
    _downloadTableView.dataSource = self;
    [_downloadView addSubview:_downloadTableView];
    
    //查询当前城市离线包
    if ([FLYBaseUtil isNotEmpty:_searchText.text]) {
        [self searchCityAction];
    }
}

#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 101) {
        if (_cityData == nil) {
            return 0;
        }else{
            return [_cityData count];
        }
    }else{
        if (_cityData == nil) {
            return 0;
        }else{
            return [_downloadData count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 101) {
        BMKOLSearchRecord *city = [_cityData objectAtIndex:indexPath.row];
        
        static NSString *identifier = @"cityCell";
        FLYCityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCityCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.data = city;
        cell.cellDelegate = self;
        return cell;
    }else{
        BMKOLUpdateElement *city = [_downloadData objectAtIndex:indexPath.row];
        static NSString *identifier = @"downloadCell";
        FLYDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYDownloadCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.data = city;
        cell.cellDelegate = self;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 控件事件
-(void)segmentAction:(UISegmentedControl *)segment{
    NSInteger index = segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            _cityView.hidden = NO;
            _downloadView.hidden = YES;
            break;
        case 1:
            _downloadView.hidden = NO;
            _cityView.hidden = YES;
            
            if (_offlineMap != nil) {
                //获取各城市离线地图更新信息
                _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
                [_downloadTableView reloadData];
            }
            
            break;
        default:
            break;
    }
}

-(void)switchAction{
    NSInteger index = _segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            _cityView.hidden = NO;
            _downloadView.hidden = YES;
            break;
        case 1:
            _downloadView.hidden = NO;
            _cityView.hidden = YES;
            if (_offlineMap != nil) {
                //获取各城市离线地图更新信息
                _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
                [_downloadTableView reloadData];
            }
            break;
        default:
            break;
    }
}

- (IBAction)backgroupTap:(id)sender {
    [_searchText resignFirstResponder];
}

- (void)searchCityAction{
    
    [_searchText resignFirstResponder];
    
    if ([FLYBaseUtil isNotEmpty:_searchText.text]) {
        if (_offlineMap != nil) {
            NSArray *city = [_offlineMap searchCity:_searchText.text];
            if ([city count] > 0) {
                _cityData = [city mutableCopy];
                _segment.selectedSegmentIndex = 0;
                [_cityTableView reloadData];
                
                [self switchAction];
            }else{
                [FLYBaseUtil showMsg:@"未查询到离线数据包"];
            }
        }
    }else{
        [FLYBaseUtil showMsg:@"请输入城市名称"];
    }

}

#pragma mark - FLYOfflineCellDelegate delegate
//下载
- (void)download:(int)cityID{
    
    BOOL flag = true;
    if (_downloadData != nil) {
        for (int i=0; i<[_downloadData count]; i++) {
            BMKOLUpdateElement *updateDate = _downloadData[i];
            if (updateDate.cityID == cityID && (updateDate.status == 1 || updateDate.status == 4)) {
                flag = false;
                break;
            }
        }
    }
    
    if (flag) {
        _segment.selectedSegmentIndex = 1;
        [_offlineMap start:cityID];
        _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
        [_downloadTableView reloadData];
        
        [self switchAction];
    }else{
        [FLYBaseUtil showMsg:@"该地图包已下载"];
    }
    
}

//更新
- (void)update:(int)cityID{
    [_offlineMap update:cityID];
    _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    [_downloadTableView reloadData];
}

//删除
- (void)remove:(int)cityID{
    [_offlineMap remove:cityID];
    _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    [_downloadTableView reloadData];
}

//取消
- (void)cancel:(int)cityID{
    [_offlineMap pause:cityID];
    [_offlineMap remove:cityID];
    _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    [_downloadTableView reloadData];
}

#pragma mark - BMKOfflineMapDelegate delegate
- (void)onGetOfflineMapState:(int)type withState:(int)state{
    if (type == TYPE_OFFLINE_UPDATE) {
        if (_downloadData == nil) {
            //获取各城市离线地图更新信息
            _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            [_downloadTableView reloadData];
        }
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement *updateInfo = [_offlineMap getUpdateInfo:state];
        for (int i=0; i< [_downloadData count]; i++) {
            BMKOLUpdateElement *updateDate = _downloadData[i];
            if (updateDate.cityID == updateInfo.cityID) {
                [_downloadData replaceObjectAtIndex:i withObject:updateInfo];
            }
        }
        [_downloadTableView reloadData];

    }
    if (type == TYPE_OFFLINE_NEWVER) {
        
        if (_downloadData == nil) {
            //获取各城市离线地图更新信息
            _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            [_downloadTableView reloadData];
        }
        
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement *updateInfo = [_offlineMap getUpdateInfo:state];
        for (int i=0; i< [_downloadData count]; i++) {
            BMKOLUpdateElement *updateDate = _downloadData[i];
            if (updateDate.cityID == updateInfo.cityID) {
                [_downloadData replaceObjectAtIndex:i withObject:updateInfo];
            }
        }
        [_downloadTableView reloadData];
    }
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _offlineMap.delegate = nil;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _offlineMap.delegate = self;
    
    
}

- (void)dealloc{
    if (_offlineMap != nil) {
        _offlineMap = nil;
    }
    
    NSLog(@"%s",__FUNCTION__);
}


@end
