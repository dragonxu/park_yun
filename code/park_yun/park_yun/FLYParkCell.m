//
//  FLYParkCell.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkCell.h"
#import "UIImageView+WebCache.h"
#import "FLYUtils.h"


@implementation FLYParkCell



- (void)awakeFromNib
{
    [super awakeFromNib];
    _parkLabel = (UILabel *)[self viewWithTag:101];
    _distanceImage = (UIImageView *)[self viewWithTag:102];
    _distanceLabel = (UILabel *)[self viewWithTag:103];
    _scoreView = (UILabel *)[self viewWithTag:104];
    _seatIdle = (UILabel *)[self viewWithTag:105];
    _capacity = (UILabel *)[self viewWithTag:106];
    _free_time = (UILabel *)[self viewWithTag:107];
    _feelevelImage = (UIImageView *)[self viewWithTag:108];
    _parkImage = (UIImageView *)[self viewWithTag:109];
    _statusImage = (UIImageView *)[self viewWithTag:110];
    
    _sep = (UILabel *)[self viewWithTag:111];
    _countImage = (UIImageView *)[self viewWithTag:112];
    
    _fz = (UILabel *)[self viewWithTag:113];
    _freetimeImage = (UIImageView *)[self viewWithTag:114];
    _typeImage = (UIImageView *)[self viewWithTag:115];
    
    _parkImage.layer.masksToBounds = YES;
    _parkImage.layer.cornerRadius = 2.0;
    _parkImage.layer.borderWidth = 0.1;
    _parkImage.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //1路内2路外
    if ([self.parkModel.parkType isEqualToString:@"1"]) {
        _typeImage.hidden = NO;
        _parkLabel.left = _typeImage.right + 2;
        _parkLabel.width = 120;
        
    }else{
        _typeImage.hidden = YES;
        _parkLabel.left = _typeImage.left;
        _parkLabel.width = 138;
    }
    
    //停车场名称
    _parkLabel.text = self.parkModel.parkName;
    
    //空位数
    _seatIdle.text = [self.parkModel.seatIdle stringValue];
    //容量
    _capacity.text = [self.parkModel.parkCapacity stringValue];
    //免费时间
    NSString *freeTime = [self.parkModel.parkFreetime stringValue];
    if (freeTime == nil || [freeTime isEqualToString:@"0"]) {
        _fz.hidden = YES;
        _free_time.text = @"";
        _freetimeImage.hidden = YES;
    }else{
        _free_time.text = freeTime;
        _fz.hidden = NO;
        _freetimeImage.hidden = NO;
    }
    
    
    //加盟标示
    if ([self.parkModel.parkStatus isEqualToString:@"0"]) {
        _statusImage.hidden = NO;
        
    }else if([self.parkModel.parkStatus isEqualToString:@"1"]){
        _statusImage.hidden = YES;
        _seatIdle.text = @"-";
    }else{
        _statusImage.hidden = YES;
        _seatIdle.text = @"-";
    }
    
    //收费评级
    if ([self.parkModel.parkFeelevel isEqualToString:@"0"]) {
        _feelevelImage.image = [UIImage imageNamed:@"mfpparking_rmb_all_0.png"];
    }else if([self.parkModel.parkFeelevel isEqualToString:@"1"]){
        _feelevelImage.image = [UIImage imageNamed:@"mfpparking_rmb2_all_0.png"];
    }else if([self.parkModel.parkFeelevel isEqualToString:@"2"]){
        _feelevelImage.image = [UIImage imageNamed:@"mfpparking_rmb3_all_0.png"];
    }
    
    //图片
    UIImage *defaultParkPhoto = [UIImage imageNamed:@"mfpparking_jiazai_all_0.png"];
    NSString *photoUrl = self.parkModel.photo.photoPath;
    if ([FLYBaseUtil isNotEmpty:photoUrl]) {
        NSString *smallUrl = [FLYUtils getSmallImage:photoUrl width:@"120" height:@"90"];
        [_parkImage setImageWithURL:[NSURL URLWithString:smallUrl] placeholderImage:defaultParkPhoto];
    }else{
        _parkImage.image = defaultParkPhoto;
    }
    
    //评分
    NSString *scoreString = self.parkModel.parkScore;
    float scorefloat = [scoreString floatValue];
    int scoreint = scorefloat * 2 / 1;
    
    for(id subView in _scoreView.subviews)
    {
        [subView removeFromSuperview]; //删除子视图
    }
    
    //满❤
    UIImage *start2 = [UIImage imageNamed:@"mfpparking_star_all_0.png"];
    //半❤
    UIImage *start1 = [UIImage imageNamed:@"mfpparking_star2_all_0.png"];
    
    UIImageView *tempStar = nil;
    while (scoreint > 0) {
        if (scoreint > 2) {
            UIImageView *startView = [[UIImageView alloc] initWithImage:start2];
            if (tempStar != nil) {
                startView.left = tempStar.right;
            }
            [_scoreView addSubview:startView];
            scoreint = scoreint - 2;
            tempStar = startView;
        }else{
            UIImageView *startView = [[UIImageView alloc] initWithImage:start1];
            if (tempStar != nil) {
                startView.left = tempStar.right;
            }
            [_scoreView addSubview:startView];
            break;
        }
    }
    
    
    [_sep sizeToFit];
    [_seatIdle sizeToFit];
    [_capacity sizeToFit];
    //CGFloat fl = _p_count.right;
    _seatIdle.left = _countImage.right + 2;
    _sep.left = _seatIdle.right + 2;
    _capacity.left = _sep.right + 2;
    
    [_free_time sizeToFit];
    _free_time.left = _freetimeImage.right + 2;
    _fz.left = _free_time.right + 2;
    
    BMKMapPoint point1 = BMKMapPointForCoordinate(self.coordinate);
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([self.parkModel.parkLat doubleValue],[self.parkModel.parkLng doubleValue]));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    if (distance > 1000) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1fK",distance / 1000];
    }else{
        _distanceLabel.text = [NSString stringWithFormat:@"%.0f",distance];
    }
    
    [_distanceLabel sizeToFit];
    _distanceLabel.right = 310;
    _distanceImage.right = _distanceLabel.left;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
