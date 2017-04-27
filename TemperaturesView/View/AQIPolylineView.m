//
//  AQIPolylineView.m
//  TestHealthy
//
//  Created by Chocolate on 2016/11/30.
//  Copyright © 2016年 Chocolate. All rights reserved.
//

#import "AQIPolylineView.h"
#import "ToolView.h"

static CFTimeInterval const kDuration = 2.0;
static CGFloat const kPointDiameter = 7.0;

@interface AQIPolylineView ()

@property (nonatomic, strong) NSMutableArray *allPoints;
@property (nonatomic, strong) NSMutableArray *curPoints;
@property (nonatomic, strong) NSArray *arr;
@end


@implementation AQIPolylineView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
//    // Drawing code
    //绘制代码
    //获取画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGFloat redColor[4] = {1.0,0,0,1.0};
    CGContextSetStrokeColor(context, redColor);
    CGContextStrokePath(context);
    
}
//数据源
-(void)setData:(NSArray *)array{
    self.allPoints = [NSMutableArray arrayWithObjects:array, nil];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self showLinesAnimationBegin];
    
}
//显示线条动画
- (void)showLinesAnimationBegin
{
    self.curPoints = [self.allPoints objectAtIndex:_lindex];
    //添加path的UIView
    ToolView  *pathNewView = [[ToolView alloc] init];
    pathNewView.backgroundColor = [UIColor clearColor];
    pathNewView.opaque = NO;
    pathNewView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:pathNewView];
    
    //设置线条的颜色
    UIColor *pathColor = nil;
    switch (_lindex) {
        case 0:
            pathColor = [UIColor yellowColor];
            break;
        default:
            break;
    }
    pathNewView.shapeLayer.fillColor = nil;
    pathNewView.shapeLayer.strokeColor = pathColor.CGColor;
    
    //创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.duration = kDuration;
    [pathNewView.shapeLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [self updatePathsWithPathShapeView:pathNewView];
}
#pragma mark - 更新路径视图
- (void)updatePathsWithPathShapeView:(ToolView *)pathNewView
{
    if ([self.curPoints count] >= 2) {
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:[[self.curPoints firstObject] CGPointValue]];
        
        //设置路径的颜色和动画
        CGPoint point = [[self.curPoints firstObject] CGPointValue];
        [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [self.curPoints count] - 1)];
        [self.curPoints enumerateObjectsAtIndexes:indexSet
                                          options:0
                                       usingBlock:^(NSValue *pointValue, NSUInteger idx, BOOL *stop) {
                                           [path addLineToPoint:[pointValue CGPointValue]];
                                           [path appendPath:[UIBezierPath bezierPathWithArcCenter:[pointValue CGPointValue] radius:kPointDiameter / 2.0 startAngle:0.0 endAngle:2 * M_PI clockwise:YES]];
                                           
                                       }];
        path.usesEvenOddFillRule = YES;
        pathNewView.shapeLayer.path = path.CGPath;
    }
    else {
        pathNewView.shapeLayer.path = nil;
    }
}
//动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _lindex++;
    if (_lindex == [self.allPoints count]) {
        _lindex = 0;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        return;
    }
    [self showLinesAnimationBegin];
}

@end
