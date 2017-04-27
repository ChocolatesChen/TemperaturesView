//
//  AQIPolylineView.m
//  TestHealthy
//
//  Created by Chocolate on 2016/11/30.
//  Copyright © 2016年 Chocolate. All rights reserved.
//

#import "ToolView.h"

@implementation ToolView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)self.layer;
}

@end
