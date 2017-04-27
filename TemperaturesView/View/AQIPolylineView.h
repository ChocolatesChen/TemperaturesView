//
//  AQIPolylineView.h
//  TestHealthy
//
//  Created by Chocolate on 2016/11/30.
//  Copyright © 2016年 Chocolate. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToolView;
@interface AQIPolylineView : UIView
{
    NSString *_curString;//当前要画得那个String
    CGPoint   _curPoint;
    int       _lindex;//线条的索引
}

@property (nonatomic,strong,readonly)ToolView *pathnewView;

- (void)setData:(NSArray *)array;

@end
