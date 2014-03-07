//
//  TT2VincluLed.m
//  Vinclu Sample
//
//  Created by titoi2 on 2014/03/08.
//  Copyright (c) 2014年 titoi2. All rights reserved.
//

#import "TT2VincluLed.h"
#import "TT2VincluLedSoundInfo.h"
#import <AudioUnit/AudioUnit.h>


@interface TT2VincluLed ()

@end


static OSStatus renderer(void *inRef,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList *ioData);


@implementation TT2VincluLed {
    AudioUnit au;           // AudioUnit
    UInt32    BitRate;      // ビットレート
    TT2VincluLedSoundInfo *soundInfo;
}


- (id)init
{
    if(self = [super init]){
        soundInfo = [[TT2VincluLedSoundInfo alloc] init];
        
        // サンプリングレートの設定
        soundInfo.SampleRate = 44100.0f;  // 44.1KHz
        
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
        CallbackStruct.inputProcRefCon = (__bridge void*)soundInfo;
        
        // コールバックの設定をAudioUnitへ設定
        AudioUnitSetProperty(au,
                             kAudioUnitProperty_SetRenderCallback,
                             kAudioUnitScope_Input,
                             0,
                             &CallbackStruct,
                             sizeof(AURenderCallbackStruct));
        
        // AudioStreamBasicDescription(ASBD)の設定
        AudioStreamBasicDescription asbd;
        asbd.mSampleRate = soundInfo.SampleRate;
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
    return self;
}




-(void) ledOnWithFrequencyLeft:(Float64)frequencyL frequencyR:(Float64)frequencyR
{
    AudioOutputUnitStop(au);
    
    soundInfo.frequencyL = frequencyL;
    soundInfo.frequencyR = frequencyR;
    soundInfo.phaseL = 0;
    soundInfo.phaseR = 0;
    
    // 再生開始
    AudioOutputUnitStart(au);
    
}

-(void) stop
{
    AudioOutputUnitStop(au);
}

-(void) dispose
{
    // 再生停止
    AudioOutputUnitStop(au);
    
    // AudioUnitの解放
    AudioUnitUninitialize(au);
    AudioComponentInstanceDispose(au);
}


@end


static OSStatus renderer(void *inRef,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList *ioData) {
    
    // RenderOutputのインスタンスにキャストする
    TT2VincluLedSoundInfo* def = (__bridge TT2VincluLedSoundInfo*)inRef;
    
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
