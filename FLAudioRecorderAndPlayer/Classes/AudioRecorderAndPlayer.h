//
//  AudioRecorderAndPlayer.h
//  FLAudioRecorderAndPlayer
//
//  Created by 傅浪 on 16/3/20.
//  Copyright © 2016年 傅浪. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#ifdef DEBUG
#define Log(...) NSLog(__VA_ARGS__)
#else
#define Log(...) {}
#endif

typedef void(^VolumeLevelHandle)(CGFloat level);
typedef void(^AudioPlayComplete)();
typedef void(^AudioPlayError)(NSError *error);

@interface AudioRecorderAndPlayer : NSObject

+ (instancetype)sharedRecorder;
/**
 *  添加麦克风音量大小监听
 *
 *  @param volumeLevelHandle 音量监听回调函数
 */
- (void)addVolumeLevelObserveWithHandle:(VolumeLevelHandle) volumeLevelHandle;

/**
 *  开始录音
 *
 *  @param filePath 录音文件的保存地址，传入nil，默认存放在temp中
 */
- (void)startRecorderWithFilePath:(NSString *)filePath;
/**
 *  暂停录音
 */
- (void)pauseRecorder;
/**
 *  恢复录音
 */
- (void)resumeRecorder;
/**
 *  停止录音
 *
 *  @param isPlay 是否播放录音
 *  @return 录音文件的地址
 */
- (NSString *)stopRecorderAndPlayAudio:(BOOL)isPlay;
/**
 *  是否在录音中
 *
 *  @return BOOL
 */
- (BOOL)isRecording;

/**
 *  播放语音文件
 *
 *  @param filePath 文件路径
 */
- (void)startPlayerAudioWithFile:(NSString *)filePath complete:(AudioPlayComplete) complete error:(AudioPlayError) error;
/**
 *  暂停播放
 */
- (void)pausePlayer;
/**
 *  恢复播放
 */
- (void)resumePlayer;
/**
 *  停止播放
 */
- (void)stopPlayer;
/**
 *  是否在播放中
 *
 *  @return BOOL
 */
- (BOOL)isPlaying;
/**
 *  返回正在播放的音频的时长，若没有音频数据，则返回0
 *
 *  @return 音频持续时间
 */
- (NSTimeInterval)audioDuration;
/**
 *  返回正在播放的音频的当前时间点，如果没有在播放状态，则返回0
 *
 *  @return 当前时间
 */
- (NSTimeInterval)audioCurrentTime;
@end
