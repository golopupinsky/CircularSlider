//
//  ViewController.m
//  CircularSlider
//
//  Created by Sergey Yuzepovich on 16.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "ViewController.h"
#import "CircularSlider.h"
@interface ViewController ()

@end

@implementation ViewController
{
    __weak IBOutlet CircularSlider *circularGradientView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleGradient:(id)sender {
    circularGradientView.gradientType = (circularGradientView.gradientType+1) % 3;
    [circularGradientView setNeedsDisplay];
}

@end
