//
//  ViewController.m
//  5-地图搜索附近
//
//  Created by qianfeng on 15/12/26.
//  Copyright (c) 2015年 李庆生. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
#import "DetailViewController.h"
#import "MyButton.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>{
    MKMapView *_mapView;
    CLLocationManager *_locationManager;
}

@property (nonatomic, strong) NSMutableArray *titlesArr;

@end

@implementation ViewController
- (void)requestLocation
{
    _locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        //在info.plist里面, 配置
        [_locationManager requestWhenInUseAuthorization];
    
        //[_locationManager requestAlwaysAuthorization];
    }
    
    //设置
    _locationManager.delegate = self;
    
    _locationManager.distanceFilter = 100.0f;
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //启动定位
    [_locationManager startUpdatingLocation];
    
}

- (void)initMkmapView
{
    _mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _mapView.delegate = self;
    
    //设置地图样式
    _mapView.mapType = MKMapTypeStandard;
    
    _mapView.showsUserLocation = YES;
    
    [self.view addSubview:_mapView];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search Poi" style:UIBarButtonItemStylePlain target:self action:@selector(searchPoint:)];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    
    [self requestLocation];
    
    [self initMkmapView];
}


#pragma mark  搜索Event method
- (void)searchPoint:(UIBarButtonItem *)bbi
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    [actionSheet addButtonWithTitle:@"取消"];
    for (NSInteger i = 0; i < self.titlesArr.count; i ++) {
        [actionSheet addButtonWithTitle:self.titlesArr[i]];
    }
    
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}



#pragma mark actionSheet的代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"buttonIndex = %ld", buttonIndex);
    
    if (buttonIndex == 0) {
        return;
    }
    
    //搜索请求对象
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    //设置搜索参数
    //设置搜索区域
    request.region = _mapView.region;
    //设置搜索主题
    request.naturalLanguageQuery = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    //启动搜索
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error == nil) {
            
            //清楚地图上的所有的大头针
            [_mapView removeAnnotations:_mapView.annotations];
            
            
            //返回搜索到的所有的位置, 是一个数组
            //response.mapItems
            //数组里面每一项： MKPlacemark ： CLPlacemark
            for (MKMapItem *placeItem in response.mapItems) {
                MyAnnotation *annotation = [[MyAnnotation alloc] init];
                
                annotation.title = placeItem.name;
                
                annotation.coordinate = placeItem.placemark.location.coordinate;
                
                annotation.subtitle = placeItem.phoneNumber;
                
                //官网的主页
                annotation.url = placeItem.url;
                
                
                [_mapView addAnnotation:annotation];
            }
        }
    }];
    
}



#pragma mark - 定制大头针
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //MKUserLocation: 显示用户标注
    
    if (![annotation isKindOfClass:[MyAnnotation class]]) {
        return nil;
    }
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MyAnnotaion"];
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyAnnotaion"];
    }
    
    
    
    //定制样式
    MyAnnotation *myAnnotion = (MyAnnotation *)annotation;
    
    NSLog(@"%@", myAnnotion.url);
    
    if ([myAnnotion.title isEqualToString:@"酒店"]) {
        annotationView.image = [UIImage imageNamed:@"hotel@2x"];
    } else if ([myAnnotion.title isEqualToString:@"KTV"]) {
        annotationView.image = [UIImage imageNamed:@"ktv@2x"];
    } else if ([myAnnotion.title isEqualToString:@"加油站"]) {
        annotationView.image = [UIImage imageNamed:@"car@2x"];
    } else {
        annotationView.image = [UIImage imageNamed:@"location@2x"];
    }
    // 弹出信息框
    annotationView.canShowCallout = YES;
    
    
    //设置左右视图
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(0, 0, 30, 30);
    imgView.image = [UIImage imageNamed:@"019@2x"];
    annotationView.leftCalloutAccessoryView = imgView;
    
    
    
    MyButton *button = [MyButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    [button setTitle:@"官网" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    
    button.url = myAnnotion.url;
    
    
    [button addTarget:self action:@selector(gotoHomeNet:) forControlEvents:UIControlEventTouchUpInside];
    
    annotationView.rightCalloutAccessoryView = button;
    
    
    return annotationView;
}


- (void)gotoHomeNet:(MyButton *)btn
{
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    
    NSLog(@"-%@", btn.url);
    detailVC.url = btn.url;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}



#pragma mark - 定位的回调函数
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations firstObject];
    
    //设置地图的位置
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    
    //
    [_mapView setRegion:region animated:YES];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}



//创建数组
- (NSMutableArray *)titlesArr
{
    
    if (!_titlesArr) {
        
        _titlesArr = [[NSMutableArray alloc] init];
        [_titlesArr addObject:@"酒店"];
        [_titlesArr addObject:@"学校"];
        [_titlesArr addObject:@"地铁站"];
        [_titlesArr addObject:@"KTV"];
        [_titlesArr addObject:@"加油站"];
        [_titlesArr addObject:@"网吧"];
    }
    
    return _titlesArr;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end







