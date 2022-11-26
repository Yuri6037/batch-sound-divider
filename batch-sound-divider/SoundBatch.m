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

#import <TextTools/TextTools.h>
#import "SoundBatch.h"
#import "SoundBatcher.h"

@interface SoundBatch()

- (BOOL)readLine:(NSString **)line withError:(NSError **)error;
- (BOOL)processLine:(NSString *)line withError:(NSError **)error;

@end

@implementation SoundBatch {
    NSString *_sourceAudio;
    NSString *_sourceMap;
    CSVParser *_parser;
    BufferedTextFile *_file;
    SoundBatcher *_batcher;
}

- (BOOL)readLine:(NSString **)line withError:(NSError **)error {
    NSError *tmp = nil;
    *line = [_file readLine:&tmp];
    if (tmp == nil) {
        return YES;
    }
    *error = tmp;
    return NO;
}

- (instancetype)init:(NSString *)sourceAudio withSourceMap:(NSString *)sourceMap {
    _sourceAudio = sourceAudio;
    _sourceMap = sourceMap;
    _parser = [[CSVParser alloc] init:','];
    return self;
}

- (BOOL)processLine:(NSString *)line withError:(NSError **)error {
    CSVRow row = [_parser parseRow:line];
    
    return YES;
}

- (BOOL)run:(NSError **)error {
    _batcher = [[SoundBatcher alloc] init:_sourceAudio withError:error];
    if (_batcher == nil)
        return NO;
    _file = [[BufferedTextFile alloc] init:_sourceMap withError:error];
    if (_file == nil)
        return NO;
    NSString *line;
    do {
        if (![self readLine:&line withError:error])
            return NO;
        if (line != nil && ![self processLine:line withError:error])
            return NO;
    } while (line != nil);
    [_file close];
    return [_batcher close:error];
}

@end
