//
//  main.m
//  batch-sound-divider
//
//  Created by Yuri Edward on 11/20/22.
//

#import <Foundation/Foundation.h>
#import "SoundBatch.h"

SoundBatch *parseArguments(int argc, const char *argv[]) {
    NSString *sourceAudio = nil;
    NSString *sourceMap = nil;
    NSString *album = nil;
    for (int i = 0; i + 1 != argc; ++i) {
        if (strcmp(argv[i], "-i") == 0)
            sourceAudio = [NSString stringWithCString:argv[i + 1] encoding:NSUTF8StringEncoding];
        else if (strcmp(argv[i], "-s") == 0)
            sourceMap = [NSString stringWithCString:argv[i + 1] encoding:NSUTF8StringEncoding];
        else if (strcmp(argv[i], "-a") == 0)
            album = [NSString stringWithCString:argv[i + 1] encoding:NSUTF8StringEncoding];
    }
    if (sourceAudio == nil || sourceMap == nil || album == nil) {
        fprintf(stderr, "No album and/or source audio and/or source map selected, aborting");
        return nil;
    }
    return [[SoundBatch alloc] init:sourceAudio withSourceMap:sourceMap withAlbum:album];
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
