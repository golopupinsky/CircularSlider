//
//  CircularSlider.h
//  CircularSlider
//
//  Created by Sergey Yuzepovich on 16.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    linearGradient,
    radialGradient,
    angularGradient
} CircularGradientType;

@interface CircularSlider : UIControl

@property CircularGradientType gradientType;
@end
