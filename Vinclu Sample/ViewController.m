//
//  ViewController.m
//  Vinclu Sample
//
//  Created by titoi2 on 2014/03/06.
//  Copyright (c) 2014年 titoi2. All rights reserved.
//

#import "ViewController.h"
#import <AudioUnit/AudioUnit.h>

@interface ViewController ()

@property (nonatomic) Float64 SampleRate;

@property (nonatomic) double phaseL;
@property (nonatomic) double phaseR;
@property (nonatomic) Float64 frequencyL;
@property (nonatomic) Float64 frequencyR;

- (IBAction)pushLightning:(UIButton *)sender;
- (IBAction)pushBlinking:(UIButton *)sender;
- (IBAction)pushViolentlyBlinking:(id)sender;
- (IBAction)pushStop:(UIButton *)sender;

@end

static OSStatus renderer(void *inRef,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                   AudioBufferList *ioData);

@implementation ViewController {
    AudioUnit au;           // AudioUnit
    UInt32    BitRate;      // ビットレート
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // サンプリングレートの設定
    _SampleRate = 44100.0f;  // 44.1KHz
    
    // ビットレートの設定
    BitRate = 8;  // 8bit


    // AudioComponentのAudioComponentDescriptionを用意する
    AudioComponentDescription acd;
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_RemoteIO;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;
    
    // AudioComponentの定義を取得
    AudioComponent ac = AudioComponentFindNext(NULL, &acd);
    
    // AudioComponentをインスタンス化
    AudioComponentInstanceNew(ac, &au);
    
    // AudioComponentを初期化
    AudioUnitInitialize(au);
    
    // コールバックの設定
    AURenderCallbackStruct CallbackStruct;
    CallbackStruct.inputProc = renderer;     // ここでコールバック時に実行するメソッドを指定
    CallbackStruct.inputProcRefCon = (__bridge void*)self;
    
    // コールバックの設定をAudioUnitへ設定
    AudioUnitSetProperty(au,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0,
                         &CallbackStruct,
                         sizeof(AURenderCallbackStruct));
    
    // AudioStreamBasicDescription(ASBD)の設定
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = _SampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    asbd.mChannelsPerFrame = 2;
    asbd.mBytesPerPacket = sizeof(AudioUnitSampleType);
    asbd.mBytesPerFrame = sizeof(AudioUnitSampleType);
    asbd.mFramesPerPacket = 1;
    asbd.mBitsPerChannel = BitRate * sizeof(AudioUnitSampleType);
    asbd.mReserved = 0;
    
    // AudioUnitにASBDを設定
    AudioUnitSetProperty(au,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &asbd,
                         sizeof(asbd));
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    // 再生停止
    AudioOutputUnitStop(au);
    
    // AudioUnitの解放
    AudioUnitUninitialize(au);
    AudioComponentInstanceDispose(au);
    
    [super viewDidUnload];
}

-(void) p_playWithFrequencyLeft:(Float64)frequencyL frequencyR:(Float64)frequencyR
{
    AudioOutputUnitStop(au);
    
    _frequencyL = frequencyL;
    _frequencyR = frequencyR;
    _phaseL = 0;
    _phaseR = 0;
    
    // 再生開始
    AudioOutputUnitStart(au);
    
}

- (IBAction)pushLightning:(UIButton *)sender {
    [self p_playWithFrequencyLeft:100 frequencyR:100];
}

- (IBAction)pushBlinking:(UIButton *)sender {
    [self p_playWithFrequencyLeft:100 frequencyR:1];
}

- (IBAction)pushViolentlyBlinking:(id)sender {
    [self p_playWithFrequencyLeft:100 frequencyR:10];
}

- (IBAction)pushStop:(UIButton *)sender {
    AudioOutputUnitStop(au);
}

@end


static OSStatus renderer(void *inRef,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList *ioData) {
    
    // RenderOutputのインスタンスにキャストする
    ViewController* def = (__bridge ViewController*)inRef;
    
    // サイン波の計算に使う数値の用意
    float freqL = def.frequencyL * 2.0 * M_PI / def.SampleRate;
    float freqR = def.frequencyR * 2.0 * M_PI / def.SampleRate;
    
    // 値を書き込むポインタ
    AudioUnitSampleType *outL = ioData->mBuffers[0].mData;
    AudioUnitSampleType *outR = ioData->mBuffers[1].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        // 周波数を計算
        float waveL = sin(def.phaseL);
        float waveR = sin(def.phaseR);
        *outL++ = waveL * (1 << kAudioUnitSampleFractionBits);
        *outR++ = waveR * (1 << kAudioUnitSampleFractionBits)*-1;
        def.phaseL += freqL;
        def.phaseR += freqR;
    }
    
    return noErr;
    
}
