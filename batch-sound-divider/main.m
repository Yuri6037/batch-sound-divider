//
//  main.m
//  batch-sound-divider
//
//  Created by Yuri Edward on 11/20/22.
//

#import <Foundation/Foundation.h>
#import "SoundBatch.h"

/*BOOL testDivide(NSError **error) {
    SoundBatcher *batcher = [[SoundBatcher alloc] init:@"/Users/yuri/Downloads/50 Most Beautiful Classical Music Pieces.m4a" withError:error];
    if (batcher == nil)
        return NO;
    AudioFileMetadata *metadata = [[AudioFileMetadata alloc] init];
    metadata.title = @"Test";
    metadata.author = @"test";
    metadata.composer = @"test";
    metadata.album = @"Classical Music";
    return [batcher writeMusic:metadata duration:100 withError:error];
}*/

SoundBatch *parseArguments(int argc, const char *argv[]) {
    NSString *sourceAudio = nil;
    NSString *sourceMap = nil;
    for (int i = 0; i + 1 != argc; ++i) {
        if (strcmp(argv[i], "-i") == 0)
            sourceAudio = [NSString stringWithCString:argv[i + 1] encoding:NSUTF8StringEncoding];
        else if (strcmp(argv[i], "-s") == 0)
            sourceMap = [NSString stringWithCString:argv[i + 1] encoding:NSUTF8StringEncoding];
    }
    if (sourceAudio == nil || sourceMap == nil) {
        fprintf(stderr, "No source audio and/or no source map selected, aborting");
        return nil;
    }
    return [[SoundBatch alloc] init:sourceAudio withSourceMap:sourceMap];
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSError *error;
        SoundBatch *batch = parseArguments(argc, argv);
        if (batch == nil)
            return 1;
        if (![batch run:&error]) {
            NSLog(@"An error has occured while running sound batch: %@", [error description]);
            return 1;
        }
    }
    return 0;
}
