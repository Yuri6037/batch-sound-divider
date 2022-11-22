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

#import "AudioFileMetadata.h"

#define SYNCHSAFE_MASK 0x0000007F

@interface AudioFileMetadata()

+ (UInt32)synchsafe:(UInt32)value;
+ (NSData *)buildID3Frame:(const char[4])frameId content:(NSString *)str;

@end

@implementation AudioFileMetadata

+ (NSData *)buildID3Frame:(const char[4])frameId content:(NSString *)str {
    char head[10] = { frameId[0], frameId[1], frameId[2], frameId[3], 0x00, 0x00, 0x00, 0x00, 0x03, 0x00 /* UTF 8*/ };
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:(10 + str.length)];
    NSRange sizeRange;
    sizeRange.location = 4;
    sizeRange.length = 4;
    [data appendBytes:head length:10];
    const char *content = [str cStringUsingEncoding:NSUTF8StringEncoding];
    UInt32 size = (UInt32)strlen(content);
    [data appendBytes:content length:size];
    UInt32 synchsafe = [AudioFileMetadata synchsafe:size];
    [data replaceBytesInRange:sizeRange withBytes:&synchsafe length:4];
    return data;
}

+ (UInt32)synchsafe:(UInt32)value {
    UInt32 result = 0;
    for (int i = 0; i != 4; ++i) {
        UInt32 tmp = value >> (i << 3);
        tmp &= SYNCHSAFE_MASK;
        tmp <<= (i << 3);
        result |= tmp;
        value <<= 1;
    }
    return result;
}

- (NSData *)build {
    char head[10] = { 'I', 'D', '3', 0x04, 0x00, 0x10 /* only set a footer in the tag */, 0x00, 0x00, 0x00, 0x00 };
    NSRange sizeRange;
    sizeRange.location = 6;
    sizeRange.length = 4;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:20];
    [data appendBytes:head length:10];
    NSData *title = [AudioFileMetadata buildID3Frame:"TIT2" content:self.title];
    NSData *album = [AudioFileMetadata buildID3Frame:"TALB" content:self.album];
    NSData *artist = [AudioFileMetadata buildID3Frame:"TPE1" content:self.author];
    NSData *composer = [AudioFileMetadata buildID3Frame:"TCOM" content:self.composer];
    UInt32 totalSize = [AudioFileMetadata synchsafe:(UInt32)(title.length + album.length + artist.length + composer.length)];
    [data replaceBytesInRange:sizeRange withBytes:&totalSize length:4];
    [data appendData:title];
    [data appendData:album];
    [data appendData:artist];
    [data appendData:composer];
    [data appendBytes:head length:10];
    return data;
}

@end
