// Copyright 2022 Yuri6037
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy
// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS
// IN THE SOFTWARE.

#import "SoundBatcher.h"

@implementation SoundBatcher {
    AudioFile *_inFile;
}

- (instancetype _Nullable)init:(NSString *)inAudio withError:(NSError **)error {
    _inFile = [[AudioFile alloc] init:inAudio withError:error];
    if (_inFile == nil)
        return nil;
    return self;
}

- (BOOL)writeMusic:(AudioFileMetadata *)metadata duration:(NSUInteger)seconds withError:(NSError **)error {
    NSUInteger frameCount = [_inFile getFrameCountFromTime:seconds];
    NSUInteger bytesPerFrame = [_inFile getBytesPerFrame];
    NSUInteger channelCount = [_inFile getChannelCount];
    FrameBuffer *buffer = [[FrameBuffer alloc] init:frameCount bytesPerFrame:bytesPerFrame channelCount:channelCount];
    if (buffer == nil)
        return NO;
    NSInteger framesRead = [_inFile readFrames:frameCount into:buffer withError:error];
    if (framesRead <= 0)
        return NO;
    NSString *fileName = [[[metadata.title stringByAppendingString:@" - "]
                           stringByAppendingString:metadata.composer] stringByAppendingString:@".aiff"];
    AudioFile *outFile = [[AudioFile alloc] init:fileName from:_inFile withError:error];
    if (outFile == nil)
        return NO;
    if (![outFile setMetadata:metadata withError:error])
        return NO;
    if (![outFile writeFrames:frameCount into:buffer withError:error])
        return NO;
    if (![outFile close:error])
        return NO;
    return YES;
}

- (BOOL)close:(NSError **)error {
    return [_inFile close:error];
}

@end
