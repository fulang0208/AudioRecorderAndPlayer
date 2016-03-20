//
//  ViewController.m
//  FLAudioRecorderAndPlayer
//
//  Created by 傅浪 on 16/3/20.
//  Copyright © 2016年 傅浪. All rights reserved.
//

#import "ViewController.h"
#import "VolumeLevelView.h"
#import "AudioRecorderAndPlayer.h"

@interface ViewController ()
@property (nonatomic, strong) VolumeLevelView *levelView;
@property (nonatomic, copy) NSString *audioFilePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.levelView = [[VolumeLevelView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    self.levelView.center = self.view.center;
    [self.levelView setLevel:0];
    [self.view addSubview:self.levelView];
    
    CGFloat buttonY = CGRectGetMaxY(self.levelView.frame) + 20;
    UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(12, buttonY, 50, 30)];
    [recordButton setTitle:@"录音" forState:UIControlStateNormal];
    recordButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:recordButton];
    [recordButton addTarget:self action:@selector(recordHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(74, buttonY, 50, 30)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.view addSubview:playButton];
    playButton.backgroundColor = [UIColor blueColor];
    [playButton addTarget:self action:@selector(playHandle) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(136, buttonY, 50, 30)];
    [pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [self.view addSubview:pauseButton];
    pauseButton.backgroundColor = [UIColor blueColor];
    [pauseButton addTarget:self action:@selector(pausePlayHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectMake(198, buttonY, 50, 30)];
    [stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [self.view addSubview:stopButton];
    stopButton.backgroundColor = [UIColor blueColor];
    [stopButton addTarget:self action:@selector(stopPlayHandle) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)recordHandle:(UIButton *)sender {
    AudioRecorderAndPlayer *manager = [AudioRecorderAndPlayer sharedRecorder];
    if ([manager isRecording]) {
        [sender setTitle:@"录音" forState:UIControlStateNormal];
        self.audioFilePath = [manager stopRecorderAndPlayAudio:YES];
    }else {
        [manager addVolumeLevelObserveWithHandle:^(CGFloat level) {
            NSInteger l = ceil(level * 5.0);
            [self.levelView setLevel:l];
        }];
        [manager startRecorderWithFilePath:nil];
        [sender setTitle:@"停止" forState:UIControlStateNormal];
    }
    
}
- (void)playHandle {
    [[AudioRecorderAndPlayer sharedRecorder] startPlayerAudioWithFile:self.audioFilePath complete:nil error:^(NSError *error) {
        if (error) {
            Log(@"%@", error.localizedDescription);
        }
    }];
}
- (void)pausePlayHandle:(UIButton *)sender {
    AudioRecorderAndPlayer *manager = [AudioRecorderAndPlayer sharedRecorder];
    if ([manager isPlaying]) {
        [manager pausePlayer];
        [sender setTitle:@"继续" forState:UIControlStateNormal];
    }else {
        [manager resumePlayer];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
- (void)stopPlayHandle {
    [[AudioRecorderAndPlayer sharedRecorder] stopPlayer];
}

@end
