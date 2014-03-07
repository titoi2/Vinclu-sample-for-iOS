//
//  ViewController.m
//  Vinclu Sample
//
//  Created by titoi2 on 2014/03/06.
//  Copyright (c) 2014年 titoi2. All rights reserved.
//

#import "ViewController.h"
#import "TT2VincluLed.h"

@interface ViewController ()
- (IBAction)pushLightning:(UIButton *)sender;
- (IBAction)pushBlinking:(UIButton *)sender;
- (IBAction)pushViolentlyBlinking:(id)sender;
- (IBAction)pushStop:(UIButton *)sender;

@end


@implementation ViewController {
    TT2VincluLed *vincluLed;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    vincluLed = [[TT2VincluLed alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [vincluLed dispose];
    [super viewDidUnload];
}



- (IBAction)pushLightning:(UIButton *)sender {
    [vincluLed ledOnWithFrequencyLeft:100 frequencyR:100];
}

- (IBAction)pushBlinking:(UIButton *)sender {
    [vincluLed ledOnWithFrequencyLeft:100 frequencyR:1];
}

- (IBAction)pushViolentlyBlinking:(id)sender {
    [vincluLed ledOnWithFrequencyLeft:100 frequencyR:10];
}

- (IBAction)pushStop:(UIButton *)sender {
    [vincluLed stop];
}

@end

