//
//  AudioRecorder.m
//  FLAudioRecorderAndPlayer
//
//  Created by 傅浪 on 16/3/20.
//  Copyright © 2016年 傅浪. All rights reserved.
//

#import "AudioRecorderAndPlayer.h"

@interface AudioRecorderAndPlayer () <AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, copy) NSString *audioFilePath;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) VolumeLevelHandle volumeLevelHandle;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) AudioPlayComplete playComplete;
@property (nonatomic, strong) AudioPlayError playError;
@end

@implementation AudioRecorderAndPlayer

+ (instancetype)sharedRecorder {
    static AudioRecorderAndPlayer *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AudioRecorderAndPlayer alloc] init];
    });
    return _instance;
}

- (void)startRecorderWithFilePath:(NSString *)filePath {
    
    self.audioFilePath = filePath?filePath:[self getRandomAudioFilePath];
    if (self.recorder == nil) {
        [self setupRecorder];
    }else if (!self.recorder.isRecording) {
        [self resumeRecorder];
    }
}

- (void)addVolumeLevelObserveWithHandle:(VolumeLevelHandle) volumeLevelHandle {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(volumeLevelTimerHandle:) userInfo:nil repeats:YES];
    self.volumeLevelHandle = volumeLevelHandle;
}
/**
 *  初始化recorder
 */
- (void)setupRecorder {
    //不加这句话，真机运行时获取不了
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    //录音文件路径
    NSURL *audioURL = [NSURL fileURLWithPath:self.audioFilePath];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:@44100.0, AVSampleRateKey, [NSNumber  numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey, @2, AVNumberOfChannelsKey, [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
    
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:settings error:&error];
    if (error != nil) {
        Log(@"ERROR: %@", error.localizedDescription);
    }else {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        [self.recorder record];
    }
}
//随机文件路径
-(NSString *)getRandomAudioFilePath{
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.caf", (long)[[NSDate date] timeIntervalSince1970]]];
    Log(@"录音文件路径：%@", path);
    return path;
}
//获取声音等级
- (void)volumeLevelTimerHandle:(NSTimer *)timer {
    [self.recorder updateMeters];
    float level;
    float minDecibels = -60.0f;
    float decibels = [self.recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels) {
        level = 0.0f;
    }else if (decibels >= 0.0f) {
        level = 1.0f;
    }else {
        float root              = 2.0f;
        float minAmp            = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange   = 1.0f / (1.0f - minAmp);
        float amp               = powf(10.0, 0.05f * decibels);
        float adjAmp            = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    
    Log(@"声音大小：%f", level);
    !self.volumeLevelHandle?:self.volumeLevelHandle(level);
}

- (void)pauseRecorder {
    [self.timer invalidate];
    [self.recorder pause];
}

- (void)resumeRecorder {
    [self.timer fire];
    [self.recorder record];
}

//停止监听
- (NSString *)stopRecorderAndPlayAudio:(BOOL)isPlay{
    [self.timer invalidate];
    self.timer = nil;
    [self.recorder stop];
    self.recorder = nil;
    
    if (isPlay && self.audioFilePath.length > 0) {
        [self startPlayerAudioWithFile:self.audioFilePath complete:nil error:nil];
    }
    
    return self.audioFilePath;
}

- (BOOL)isRecording {
    return [self.recorder isRecording];
}

- (void)startPlayerAudioWithFile:(NSString *)filePath complete:(AudioPlayComplete)complete error:(AudioPlayError)error {
    if (filePath && ![self.player isPlaying]) {
        NSError *_error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&_error];
        if (_error) {
            Log(@"ERROR:%@", _error.localizedDescription);
            !error?:error(_error);
            return;
        }
        self.player.delegate = self;
        self.playComplete = complete;
        self.playError = error;
        [self.player prepareToPlay];
        [self.player play];
    }
}

- (void)pausePlayer {
    if (self.player && self.player.isPlaying) {
        [self.player pause];
    }
}

- (void)resumePlayer {
    if (self.player && !self.player.isPlaying) {
        [self.player play];
    }
}

- (void)stopPlayer {
    if (self.player && self.player.isPlaying) {
        [self.player stop];
    }
}

- (BOOL)isPlaying {
    return self.player?[self.player isPlaying]:NO;
}

- (NSTimeInterval)audioDuration {
    return self.player?[self.player duration]:0;
}

- (NSTimeInterval)audioCurrentTime {
    return self.player.isPlaying?self.player.currentTime:0;
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        !self.playComplete?:self.playComplete();
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    !self.playError?:self.playError(error);
}


@end
