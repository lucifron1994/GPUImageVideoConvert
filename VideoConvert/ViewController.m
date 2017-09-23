//
//  ViewController.m
//  VideoConvert
//
//  Created by WangHong on 2017/8/4.
//  Copyright © 2017年 wanghong. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (strong, nonatomic) GPUImageMovie *movie;
@property (strong, nonatomic) UIAlertController *alert;

@end

@implementation ViewController{
    NSTimeInterval _startTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.textField.text = @"2462.5";    
}
- (IBAction)to720:(id)sender {
    [self convertWithSize:CGSizeMake(1280, 720)];
}

- (IBAction)to480:(id)sender {
    [self convertWithSize:CGSizeMake(720, 480)];

}
- (IBAction)to1080:(id)sender {
    [self convertWithSize:CGSizeMake(1920, 1080)];
}

- (void)convertWithSize:(CGSize)size{
    CGFloat bitrate = [self.textField.text floatValue];
    if (!bitrate) {
        [self.textView insertText:@"\nbitrate invalid\n"];
        return;
    }
    
    self.alert = [UIAlertController alertControllerWithTitle:@"转码中..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:self.alert animated:YES completion:nil];
    
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    
    
    self.movie = [[GPUImageMovie alloc]initWithAsset:asset];
    self.movie.runBenchmark = YES;
    
//    self.movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:[self getOutputFilePath] size:size];
    NSDictionary *outputSetting = @{AVVideoCodecKey:AVVideoCodecH264,
                                    AVVideoWidthKey:@(size.width),
                                    AVVideoHeightKey:@(size.height),
                                    AVVideoCompressionPropertiesKey:
                                        @{ AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel,
                                           AVVideoAverageBitRateKey:@(bitrate * 1000),
                                           AVVideoMaxKeyFrameIntervalKey:@(24)}
                                    };
    self.movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:[self getOutputFilePath] size:size fileType:AVFileTypeQuickTimeMovie outputSettings:outputSetting];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [self.movie addTarget:progressFilter];
    
    
    self.movieWriter.hasAudioTrack = NO;
//    self.movieWriter.shouldPassthroughAudio = NO;
//    self.movie.audioEncodingTarget = self.movieWriter;
    [self.movie enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    [progressFilter addTarget:self.movieWriter];
    
    _startTime = [[NSDate date]timeIntervalSince1970];
    
    [self.movieWriter startRecording];
    [self.movie startProcessing];
    
    __weak typeof(self) weakSelf = self;
    [self.movieWriter setCompletionBlock:^{
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _startTime;
        NSString *des = [NSString stringWithFormat:@"\n转换为：%@ 耗时：%.2fs\n",NSStringFromCGSize(size),duration];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.textView insertText:des];
            [weakSelf.alert dismissViewControllerAnimated:YES completion:nil];
        });
        
        [weakSelf.movieWriter finishRecording];
        [weakSelf.movie endProcessing];
    }];
}


- (NSURL *)getOutputFilePath{
    int ts = [[NSDate date] timeIntervalSince1970];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ouput-%d.mp4",ts]];
    NSLog(@"Output Path %@",path);
    return [NSURL fileURLWithPath:path];
}



@end
