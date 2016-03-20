//
//  VolumeLevelView.m
//  FLAudioRecorderAndPlayer
//
//  Created by 傅浪 on 16/3/20.
//  Copyright © 2016年 傅浪. All rights reserved.
//

#import "VolumeLevelView.h"

@interface VolumeLevelView ()

@property (nonatomic, strong) NSArray<UIImageView *> *images;

@end

@implementation VolumeLevelView

- (NSArray<UIImageView *> *)images {
    if (_images == nil) {
        NSMutableArray<UIImageView *> *array = [[NSMutableArray alloc] init];
        CGFloat height = self.frame.size.height;
        for (int i = 0; i < 5; i++) {
            
            CGFloat x = i * 20;
            CGFloat w = 15;
            CGFloat h = i * 5 + 5;
            CGFloat y = height - h;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            imageView.backgroundColor = [UIColor whiteColor];
            [array addObject:imageView];
            [self addSubview:imageView];
            _images = array;
        }
    }
    return _images;
}

- (void)setLevel:(NSInteger)level {
    for (int i = 0; i < self.images.count; i++) {
        UIImageView *imageView = self.images[i];
        imageView.backgroundColor = i > level?[UIColor whiteColor]:[UIColor greenColor];
    }
}
@end
