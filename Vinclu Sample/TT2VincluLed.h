//
//  TT2VincluLed.h
//  Vinclu Sample
//
//  Created by titoi2 on 2014/03/08.
//  Copyright (c) 2014年 titoi2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TT2VincluLed : NSObject
-(void) ledOnWithFrequencyLeft:(Float64)frequencyL frequencyR:(Float64)frequencyR;
-(void) stop;
-(void) dispose;


@end
