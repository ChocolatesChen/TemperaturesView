//
//  ViewController.m
//  TemperaturesView
//
//  Created by Chocolate on 2016/12/1.
//  Copyright © 2016年 Chocolate. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UIView+Category.h"
#import "AQIPolylineView.h"//绘制折线动画
#import "ToolView.h"//绘图工具


#define appWith CGRectGetWidth([[UIScreen mainScreen] bounds])
#define appHight CGRectGetHeight([[UIScreen mainScreen] bounds])
#define appHight5 568

// tab按钮的高度
#define kTabButtonHeight  49

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_MAX_LENGTH (MAX(appWith, appHight))
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)//iphone6p
#define scrFont (IS_IPHONE_6P?1:0)  //6P上字体大几号
//导航条颜色RGB

#define navColor [UIColor colorWithRed:73.0/255.0 green:171.0/255.0 blue:1/255.0 alpha:1]


static const float UnitTemp = 3.0;
@interface ViewController ()
{
    UIView * _weatherBaseView;
}
@property (nonatomic,strong)AQIPolylineView *lineView;
@property (nonatomic,strong)NSMutableArray *pointsArr;
@property (nonatomic,strong)NSMutableArray *MaxtempArr;
@property (nonatomic,strong)NSMutableArray *MintempArr;
@property (nonatomic,strong)NSMutableArray *pointValueArr;
@property (nonatomic,assign)float Maxtemp;//最高温
@property (nonatomic,assign)float Mintemp;//最低温
@property (nonatomic,assign)float pointY;

//测试NSArray
@property (nonatomic,strong)NSArray *MaxArr;
@property (nonatomic,strong)NSArray *MinArr;
@property (nonatomic,strong)NSArray *pointArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUI];
    [self initData];
}

- (void)initData{
    _pointsArr = [NSMutableArray array];
    _MaxtempArr = [NSMutableArray array];
    _MintempArr = [NSMutableArray array];
    _pointValueArr = [NSMutableArray array];
    
    //测试
    _MaxArr = [NSArray arrayWithObjects:@"15℃",@"10℃",@"5℃",@"8℃",@"10℃",nil];
    _MinArr = [NSArray arrayWithObjects:@"-3℃",@"3℃",@"-10℃",@"1℃",@"1℃" ,nil];
    _pointArr = [NSArray arrayWithObjects:@"130",@"40",@"99",@"89",@"100", nil];
}

- (void)setUI{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width/2-35, 100, 70,40)];
    [btn setTitle:@"点一下" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn addTarget:self action:@selector(onTopViewTapped) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 0.8;
    btn.layer.masksToBounds = YES;
    [self.view addSubview: btn];
}

- (void)initWeatherBaseView
{
    _weatherBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _weatherBaseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    _weatherBaseView.userInteractionEnabled = YES;
    [self.view addSubview:_weatherBaseView];
    
    UITapGestureRecognizer * balancedetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onWeatherBaseViewTapped:)];
    [_weatherBaseView addGestureRecognizer:balancedetail];
    
    
    
    
    UIView * weatherView = [[UIView alloc] initWithFrame:CGRectMake(10, appHight-450-kTabButtonHeight-100, appWith - 20, 450)];
    weatherView.backgroundColor = [UIColor clearColor];
    weatherView.layer.cornerRadius = 5;
    weatherView.layer.masksToBounds = YES;
    [_weatherBaseView addSubview:weatherView];
    
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weatherView.width, 80)];
    topView.backgroundColor = [[UIColor colorWithRed:0.0623 green:0.0623 blue:0.0623 alpha:1.0] colorWithAlphaComponent:0.7];
    [weatherView addSubview:topView];
    
    for (NSInteger m =0; m<5; m++) {
       
        UIView * baseView = [[UIView alloc] initWithFrame:CGRectMake(topView.width / 5 * m, 0, topView.width / 5, topView.height)];
        baseView.backgroundColor = [UIColor clearColor];
        [topView addSubview:baseView];
        //微量元素1
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, baseView.width, 20)];
        topLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:17.0f+scrFont];
        topLabel.textColor = [UIColor whiteColor];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.text = @"666";
        [baseView addSubview:topLabel];
        //微量元素2
        UILabel * middleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, topLabel.bottom, baseView.width, 20)];
        middleLab.font = [UIFont systemFontOfSize:10.0f+scrFont];
        middleLab.textColor = [UIColor whiteColor];
        middleLab.textAlignment = NSTextAlignmentCenter;
        middleLab.text = @"777";
        [baseView addSubview:middleLab];
        //pm数值
        UILabel * bottomLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, baseView.width, 30)];
        bottomLab.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:19.0f+scrFont];
        bottomLab.textAlignment = NSTextAlignmentCenter;
        bottomLab.textColor = navColor;
        bottomLab.text = @"888";
        [baseView addSubview:bottomLab];
    }
    
    for (NSInteger n = 1; n <5; n++) {
        [self addLineFrame:CGRectMake(topView.width / 5 * n, 0, 1, topView.height) andColor:[UIColor blackColor]andBaseView:topView];
    }
    [self addLineFrame:CGRectMake(0, 50, topView.width, 1) andColor:[UIColor blackColor]andBaseView:topView];
    
    UIView * middView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.bottom, topView.width, 260)];
    middView.backgroundColor = [[UIColor colorWithRed:0.0745 green:0.5882 blue:0.8118 alpha:1.0] colorWithAlphaComponent:0.8];
    [weatherView addSubview:middView];
    
    UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, middView.width, 30)];
    titleLab.backgroundColor = [UIColor colorWithRed:0.0745 green:0.5882 blue:0.8118 alpha:1.0];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:15.0f+scrFont];
    titleLab.text = @"天气详情";
    [middView addSubview:titleLab];
    
    [self addLineFrame:CGRectMake(0, titleLab.bottom, middView.width, 1) andColor:[UIColor blackColor]andBaseView:middView];
    
    for (NSInteger l = 0; l<5; l++) {
        UIView * midBaseView = [[UIView alloc] initWithFrame:CGRectMake(middView.width / 5*l, titleLab.bottom, middView.width / 5, middView.height - 30)];
        midBaseView.backgroundColor = [UIColor clearColor];
        [middView addSubview:midBaseView];
        //星期
        UILabel * dayLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, midBaseView.width, 30)];
        dayLab.backgroundColor = [UIColor clearColor];
        dayLab.font = [UIFont systemFontOfSize:17.0f+scrFont];
        dayLab.textColor = [UIColor whiteColor];
        dayLab.text = @"999";
        dayLab.textAlignment = NSTextAlignmentCenter;
        [midBaseView addSubview:dayLab];
        //天气
        UILabel * weatherLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, dayLab.bottom, dayLab.width, 15)];
        weatherLabel.backgroundColor = [UIColor clearColor];
        weatherLabel.font = [UIFont systemFontOfSize:10.0f+scrFont];
        weatherLabel.textColor = [UIColor colorWithRed:1.0 green:0.8219 blue:0.3389 alpha:1.0];
        weatherLabel.text = @"000";
        weatherLabel.textAlignment = NSTextAlignmentCenter;
        [midBaseView addSubview:weatherLabel];
        //风力
        UILabel * windLab= [[UILabel alloc] initWithFrame:CGRectMake(0, weatherLabel.bottom, dayLab.width, 15)];
        windLab.backgroundColor = [UIColor clearColor];
        windLab.font = [UIFont systemFontOfSize:10.0f+scrFont];
        windLab.textColor = [UIColor colorWithRed:1.0 green:0.8219 blue:0.3389 alpha:1.0];
        windLab.text = @"444";
        windLab.textAlignment = NSTextAlignmentCenter;
        [midBaseView addSubview:windLab];
        //天气图标
        UIImageView * weatherImgV = [[UIImageView alloc] initWithFrame:CGRectMake(20, windLab.bottom + 10, midBaseView.width/2, midBaseView.width/2)];
        weatherImgV.image = [UIImage imageNamed:@"wi_00"];
        [midBaseView addSubview:weatherImgV];
        //温度视图View
        float tempH = (midBaseView.height - dayLab.height - weatherImgV.height-windLab.height-weatherLabel.height);
        NSLog(@"温度视图的高:%f",tempH);
        NSLog(@"获取temp的:%f",middView.width);
        //温差
        float tempX = [self getTempValue:_MaxArr[l] low:_MinArr[l]];
        //默认+20 计算temp其实frame.y
        float  y =([self getNowMonth]-[self getTempSub:_MaxArr[l]]) * UnitTemp;
        NSLog(@"处理后的frame.y=%f",y);
        
        UIView *temp = [[UIView alloc]initWithFrame:CGRectMake(middView.width / 5/2-3, weatherImgV.bottom + 20 +y, 6, tempX)];
        temp.backgroundColor = [UIColor yellowColor];//////////
        [UIView animateWithDuration:0.5 animations:^{
            
            temp.transform = CGAffineTransformMakeScale(1.2, 1.2);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                temp.transform = CGAffineTransformIdentity;
            }];
        }];
        [midBaseView addSubview:temp];
        
        
        //最高温
        UILabel *high = [[UILabel alloc]initWithFrame:CGRectMake(middView.width/5/2-17.5, temp.top - 11, 35, 10)];
        high.text = _MaxArr[l];
        high.textAlignment = NSTextAlignmentCenter;
        high.font = [UIFont systemFontOfSize:10.0f+scrFont];
        high.textColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:153/255.0 alpha:1.0];
        [midBaseView addSubview:high];
        //最低温
        UILabel *low = [[UILabel alloc]initWithFrame:CGRectMake(middView.width/5/2-17.5, temp.bottom + 1, 35, 10)];
//        low.backgroundColor = [UIColor blackColor];
        low.text = _MinArr[l];
        low.textAlignment = NSTextAlignmentCenter;
        low.font = [UIFont systemFontOfSize:10.0f+scrFont];
        low.textColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:153/255.0 alpha:1.0];
        [midBaseView addSubview:low];
    }
    [self addLineFrame:CGRectMake(0, 100, middView.width, 1) andColor:[UIColor blackColor]andBaseView:middView];
    
    for (NSInteger n = 1; n < 5; n++) {
        [self addLineFrame:CGRectMake(topView.width / 5 * n, titleLab.bottom, 1, middView.height-30) andColor:[UIColor blackColor]andBaseView:middView];
    }
    
    [self addLineFrame:CGRectMake(0, middView.height-1, middView.width, 1) andColor:[UIColor blackColor]andBaseView:middView];
    
    UIView * bottomBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, middView.bottom, middView.width, weatherView.height - middView.bottom)];
    bottomBaseView.backgroundColor = [[UIColor colorWithRed:0.0 green:0.7763 blue:0.0016 alpha:1.0] colorWithAlphaComponent:0.8];
    [weatherView addSubview:bottomBaseView];
    
    UILabel * healthLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, middView.width, 30)];
    healthLab.backgroundColor = [UIColor colorWithRed:0.0 green:0.7763 blue:0.0016 alpha:1.0];
    healthLab.textColor = [UIColor whiteColor];
    healthLab.textAlignment = NSTextAlignmentCenter;
    healthLab.font = [UIFont systemFontOfSize:15.0f+scrFont];
    healthLab.text = @"健康指数趋势";
    [bottomBaseView addSubview:healthLab];
    
    for (NSInteger n = 1; n < 5; n++) {
        [self addLineFrame:CGRectMake(topView.width / 5 * n, healthLab.bottom, 1, bottomBaseView.height-30)andColor:[UIColor blackColor]andBaseView:bottomBaseView];
    }
    [self addLineFrame:CGRectMake(0, healthLab.bottom, healthLab.width, 1)andColor:[UIColor blackColor]andBaseView:bottomBaseView];
    
    //折线视图  传入AQI值
    
    float h = weatherView.height-topView.height-middView.height-healthLab.height;//  view  h:80
    float oneWidth = bottomBaseView.width/5;
    float x = bottomBaseView.width/5/2;
    NSInteger count = 0;
    for (NSInteger z = 0; z<5; z++) {
        if ([_pointArr[z] floatValue]>160) {
            count++;
        }
    }
    for (NSInteger e = 0; e<5; e++) {
        float y = h/2;//中点  默认为40  上下+—frame.y
        _pointY = 0;
        if (count>=3) {
            if ([_pointArr[e] floatValue]>160) {
                _pointY = y - ([_pointArr[e] floatValue] - 160) * 0.45;
                [_pointValueArr addObject:[NSString stringWithFormat:@"%f",_pointY]];
            }else{
                _pointY = y + (160 - [_pointArr[e] floatValue]) * 0.45;
                [_pointValueArr addObject:[NSString stringWithFormat:@"%f",_pointY]];
            }
        }else{
            if ([_pointArr[e] floatValue]>80) {
                _pointY = y - ([_pointArr[e] floatValue] - 80) * 0.25;
                [_pointValueArr addObject:[NSString stringWithFormat:@"%f",_pointY]];
            }else{
                _pointY = y + (80 - [_pointArr[e] floatValue]) * 0.25;
                [_pointValueArr addObject:[NSString stringWithFormat:@"%f",_pointY]];
            }
        }
    }
    
    
    
    for (NSInteger k = 0; k<5; k++) {
        
        
        
        //api折线视图
        self.lineView = [[AQIPolylineView alloc]init];
        self.lineView.frame = CGRectMake(0, healthLab.bottom, bottomBaseView.width, h);
        self.lineView.contentMode = UIViewContentModeScaleAspectFill;
        [bottomBaseView addSubview:self.lineView];
        [self.lineView setNeedsDisplay];

       
        
        
        //绘制路径点
        CGPoint secondDot =CGPointMake(oneWidth*k+x, [_pointValueArr[k] floatValue]);
        [_pointsArr addObject:[NSValue valueWithCGPoint:secondDot]];
        //AQI值
        UILabel *aqiValue = [[UILabel alloc]initWithFrame:CGRectMake(oneWidth*k+x-15, [_pointValueArr[k] floatValue] + 15, 30, 10)];
        aqiValue.text = _pointArr[k];
        aqiValue.textAlignment = NSTextAlignmentCenter;
        aqiValue.font = [UIFont systemFontOfSize:10.0f+scrFont];
        aqiValue.textColor = [UIColor greenColor];
        [bottomBaseView addSubview:aqiValue];
    }
    [self handleRefreashEvent:nil];
    
}
- (void)handleRefreashEvent:(id)sender {
    
    for (UIView *view in [self.lineView subviews]) {
        if ([view isKindOfClass:[ToolView class]]) {
            [view removeFromSuperview];
        }
    }
    //aqi位置数组传入数据源
    [self.lineView setData:_pointsArr];
}
- (float)getTempValue:(NSString *)high low:(NSString *)low{
    //传入高低温
    float tempHigh = [self getTempSub:high];
    float tempLow = [self getTempSub:low];
    float tempX = (tempHigh-tempLow)*UnitTemp;
    return tempX;
}
- (float)getTempSub:(NSString *)value{
    NSRange range = [value rangeOfString:@"℃"];//现获取要截取的字符串位置
    float result = [[value substringToIndex:range.location] floatValue]; //截取字符串
    NSLog(@"%f",result);
    
    return result;
}
-(void)addLineFrame:(CGRect)frame andColor:(UIColor *)backColor andBaseView:(UIView *)baseView
{
    UIView * lineView = [[UIView alloc] initWithFrame:frame];
    lineView.backgroundColor = backColor;
    [baseView addSubview:lineView];
    
}
//获取当前月份
/*判断当前月份合理设置最高最低温
 3月至5月为春季，
 6月至8月为夏季，
 9月至11月为秋季，
 12月至次年2月为冬季。
 return 返回一个默认最高温度
*/
- (float)getNowMonth{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    if ([dateString integerValue]<=5&&[dateString integerValue]>=3) {
        self.Maxtemp = 20;
        self.Mintemp = -10;
    }else if ([dateString integerValue]<=8&&[dateString integerValue]>=6){
        self.Maxtemp = 40;
        self.Mintemp = 0;
    }else if ([dateString integerValue]<=11&&[dateString integerValue]>=9){
        self.Maxtemp = 30;
        self.Mintemp = 0;
    }else if (([dateString integerValue]<=2&&[dateString integerValue]>=1)||[dateString integerValue]==12){
        self.Maxtemp = 15;
        self.Mintemp = -30;
    }
    return self.Maxtemp;
}
//首页天气View  touch
-(void)onTopViewTapped{
    _weatherBaseView.hidden = NO;
    [self initWeatherBaseView];
}


-(void)onWeatherBaseViewTapped:(UITapGestureRecognizer *)tap {
    [_weatherBaseView removeFromSuperview];
    _weatherBaseView.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
