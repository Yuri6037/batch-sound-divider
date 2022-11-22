//
//  main.m
//  batch-sound-divider
//
//  Created by Yuri Edward on 11/20/22.
//

#import <Foundation/Foundation.h>
#import "SoundBatcher.h"

BOOL testDivide(NSError **error) {
    SoundBatcher *batcher = [[SoundBatcher alloc] init:@"/Users/yuri/Downloads/50 Most Beautiful Classical Music Pieces.m4a" withError:error];
    if (batcher == nil)
        return NO;
    AudioFileMetadata *metadata = [[AudioFileMetadata alloc] init];
    metadata.title = @"Test";
    metadata.author = @"test";
    metadata.composer = @"test";
    metadata.album = @"Classical Music";
    return [batcher writeMusic:metadata duration:100 withError:error];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSError *error;
        if (!testDivide(&error)) {
            NSLog(@"An error has occured %ld", error.code);
        }
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
