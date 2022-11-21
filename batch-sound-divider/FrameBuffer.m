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

#import "FrameBuffer.h"

@implementation FrameBuffer {
    AudioBufferList *_buffers;
}

@synthesize buffers = _buffers;

- (instancetype)init:(NSUInteger)frameCount bytesPerFrame:(NSUInteger)frameSize channelCount:(NSUInteger)channels {
    _buffers = malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
    if (_buffers == NULL) {
        return nil; //Allocation failure: return nil
    }
    _buffers->mNumberBuffers = 1;
    UInt32 bufferSize = (UInt32)frameSize * (UInt32)frameCount;
    _buffers->mBuffers[0].mDataByteSize = bufferSize;
    _buffers->mBuffers[0].mNumberChannels = (UInt32)channels;
    _buffers->mBuffers[0].mData = malloc(bufferSize);
    if (_buffers->mBuffers[0].mData == NULL) {
        free(_buffers);
        return nil;
    }
    return self;
}

- (void)dealloc {
    free(_buffers->mBuffers[0].mData);
    free(_buffers);
}

@end
