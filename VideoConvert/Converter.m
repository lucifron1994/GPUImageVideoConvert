//
//  Converter.m
//  VideoCompressionDemo
//
//  Created by WangHong on 2017/8/4.
//  Copyright © 2017年 wanghong. All rights reserved.
//

#import "Converter.h"
@import AVFoundation;

@implementation Converter{
    NSTimeInterval _startTime;
}


- (void)compressDebug{
    /*
     Test0:
     
     Stream #0:0(und): Video: h264 (Main) (avc1 / 0x31637661), yuv420p(tv, bt709), 1366x768 [SAR 1:1 DAR 683:384], 4651 kb/s, 60 fps, 60 tbr, 6k tbn, 50 tbc (default)
     test0 -> AVAssetExportPreset640x480  16s
     
     Stream #0:0(und): Video: h264 (Main) (avc1 / 0x31637661), yuv420p(tv, bt709), 640x360 [SAR 1:1 DAR 16:9], 1825 kb/s, 60.03 fps, 60 tbr, 6k tbn, 12k tbc (default)
     
     test0 -> AVAssetExportPreset1280x720 44s
     
     Stream #0:0(und): Video: h264 (Main) (avc1 / 0x31637661), yuv420p(tv, bt709), 1280x720 [SAR 1:1 DAR 16:9], 5399 kb/s, 60.03 fps, 60 tbr, 6k tbn, 12k tbc (default)
     */
    
    /*
     Test1:
     
     Stream #0:0(eng): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 1920x1080 [SAR 2049:2048 DAR 683:384], 905 kb/s, 60 fps, 60 tbr, 15360 tbn, 120 tbc (default)
     
     test1 -> AVAssetExportPreset640x480  20s
     
     Stream #0:0(eng): Video: h264 (Main) (avc1 / 0x31637661), yuv420p(tv, smpte170m/smpte170m/bt709), 640x360 [SAR 1:1 DAR 16:9], 1813 kb/s, 60 fps, 60 tbr, 15360 tbn, 30720 tbc (default)
     
     test1 -> AVAssetExportPreset1280x720 47s
     
     Stream #0:0(eng): Video: h264 (Main) (avc1 / 0x31637661), yuv420p(tv, smpte170m/smpte170m/bt709), 1280x720 [SAR 1:1 DAR 16:9], 5125 kb/s, 60 fps, 60 tbr, 15360 tbn, 30720 tbc (default)
     */
    
    
    NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:@"test1.mov" withExtension:nil];
    NSLog(@"Original %@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[sourceURL path]]]);
    
    NSDate *date = [NSDate date];
    NSTimeInterval interval =[date timeIntervalSince1970];
    
    NSURL *outUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%d.mp4",(int)interval]];
    NSLog(@"outUrl : %@",outUrl);
    [self convertVideoQuailtyWithInputURL:sourceURL outputURL:outUrl completeHandler:nil];
}


- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    //    NSLog(@"presetName：%@", [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset]);
    //AVAssetExportPreset1920x1080
    //AVAssetExportPreset1280x720
    //AVAssetExportPreset640x480
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                 
                 NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
                 
                 NSLog(@"End ====== Duration : %f",(endTime - _startTime));
                 break;
             case AVAssetExportSessionStatusFailed:
                 
                 
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
         
     }];
    
}

- (CGFloat) getFileSize:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;//in kb
    
    self.test(@"666");
}


@end
