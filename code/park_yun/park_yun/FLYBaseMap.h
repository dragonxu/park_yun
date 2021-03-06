//
//  FLYBaseMap.h
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "BMapKit.h"


@protocol FLYMapDelegate <NSObject>
@required
//跟随
- (void)mapFollow:(BOOL)enable;

//定位
- (void)mapLocation;

//取消导航
- (void)mapNavigation;
@end


@interface FLYBaseMap : UIView{
    BOOL _isFollow;
}


@property(strong,nonatomic) UIButton *mapTypeBtn;
@property(strong,nonatomic) UIButton *trafficBtn;

@property(strong,nonatomic) UIButton *zoomInBtn;
@property(strong,nonatomic) UIButton *zoomOutBtn;

@property(strong,nonatomic) UIButton *locationBtn;
@property(strong,nonatomic) UIButton *followBtn;

@property(strong,nonatomic) UIButton *navigationBtn;

@property(strong,nonatomic) BMKMapView *mapView;

//@property(unsafe_unretained,nonatomic)id<FLYMapDelegate> mapDelegate;
@property(assign,nonatomic)id<FLYMapDelegate> mapDelegate;
@end


