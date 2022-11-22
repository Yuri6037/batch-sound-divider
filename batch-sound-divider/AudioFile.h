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

#import <Foundation/Foundation.h>
#import "FrameBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioFileMetadata : NSObject

@property (readwrite, assign) NSString *title;
@property (readwrite, assign) NSString *author;
@property (readwrite, assign) NSString *composer;
@property (readwrite, assign) NSString *album;

@end

@interface AudioFile : NSObject

- (instancetype _Nullable)init:(NSString *)path withError:(NSError **)error;

- (instancetype _Nullable)init:(NSString *)path from:(AudioFile *)file withError:(NSError **)error;

- (NSUInteger)getFrameCountFromTime:(NSUInteger)seconds;

- (NSUInteger)getChannelCount;

- (NSUInteger)getBytesPerFrame;

- (NSInteger)readFrames:(NSUInteger)frameCount into:(FrameBuffer *)buffer withError:(NSError **)error;

- (BOOL)writeFrames:(NSUInteger)frameCount into:(FrameBuffer *)buffer withError:(NSError **)error;

- (BOOL)setMetadata:(AudioFileMetadata *)metadata withError:(NSError **)error;

- (BOOL)close:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
