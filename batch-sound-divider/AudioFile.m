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

#import <AudioToolbox/ExtendedAudioFile.h>
#import "AudioFile.h"

@implementation AudioFileMetadata

@end

@interface AudioFile()
- (BOOL)getProperty:(ExtAudioFilePropertyID)property withSize:(UInt32)size into:(void *)buffer withError:(NSError **)error;
- (BOOL)getAFProperty:(AudioFilePropertyID)property withSize:(UInt32)size into:(void *)buffer withError:(NSError **)error;
- (BOOL)setAFProperty:(AudioFilePropertyID)property withSize:(UInt32)size from:(void *)buffer withError:(NSError **)error;
@end

@implementation AudioFile {
    ExtAudioFileRef _file;
    AudioStreamBasicDescription _description;
}

- (instancetype _Nullable)init:(NSString *)path withError:(NSError **)error {
    NSURL *url = [NSURL fileURLWithPath:path];
    OSStatus status = ExtAudioFileOpenURL((__bridge CFURLRef)url, &_file);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return nil;
    }
    if (![self getProperty:kExtAudioFileProperty_FileDataFormat
                  withSize:sizeof(AudioStreamBasicDescription) into:&_description withError:error]) {
        ExtAudioFileDispose(_file);
        return nil;
    }
    return self;
}

- (BOOL)getProperty:(ExtAudioFilePropertyID)property withSize:(UInt32)size into:(void *)buffer withError:(NSError **)error {
    UInt32 ioSize = size;
    OSStatus status = ExtAudioFileGetProperty(_file, property, &ioSize, buffer);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

- (BOOL)getAFProperty:(AudioFilePropertyID)property withSize:(UInt32)size into:(void *)buffer withError:(NSError **)error {
    AudioFileID afile;
    if (![self getProperty:kExtAudioFileProperty_AudioFile withSize:sizeof(AudioFileID) into:&afile withError:error])
        return NO;
    UInt32 ioSize = size;
    OSStatus status = AudioFileGetProperty(afile, property, &ioSize, buffer);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

- (BOOL)setAFProperty:(AudioFilePropertyID)property withSize:(UInt32)size from:(void *)buffer withError:(NSError **)error {
    AudioFileID afile;
    if (![self getProperty:kExtAudioFileProperty_AudioFile withSize:sizeof(AudioFileID) into:&afile withError:error])
        return NO;
    OSStatus status = AudioFileSetProperty(afile, property, size, buffer);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

- (instancetype _Nullable)init:(NSString *)path from:(AudioFile *)file withError:(NSError **)error {
    AudioChannelLayout channelLayout;
    if (![file getProperty:kExtAudioFileProperty_FileChannelLayout
                  withSize:sizeof(AudioChannelLayout) into:&channelLayout withError:error])
        return nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    OSStatus status = ExtAudioFileCreateWithURL((__bridge CFURLRef)url, kAudioFileAIFFType, &file->_description, &channelLayout, kAudioFileFlags_EraseFile, &_file);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return nil;
    }
    return self;
}

- (NSUInteger)getFrameCountFromTime:(NSUInteger)seconds {
    return seconds * _description.mSampleRate;
}

- (NSUInteger)getChannelCount {
    return _description.mChannelsPerFrame;
}

- (NSUInteger)getBytesPerFrame {
    return _description.mChannelsPerFrame * sizeof(SInt32);
}

- (NSInteger)readFrames:(NSUInteger)frameCount into:(FrameBuffer *)buffer withError:(NSError **)error {
    UInt32 ioFrameCount = (UInt32)frameCount;
    OSStatus status = ExtAudioFileRead(_file, &ioFrameCount, buffer.buffers);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return -1;
    }
    return ioFrameCount;
}

- (BOOL)writeFrames:(NSUInteger)frameCount into:(FrameBuffer *)buffer withError:(NSError **)error {
    OSStatus status = ExtAudioFileWrite(_file, (UInt32)frameCount, buffer.buffers);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

- (BOOL)setMetadata:(AudioFileMetadata *)metadata withError:(NSError **)error {
    CFDictionaryRef infoDic;
    if (![self getAFProperty:kAudioFilePropertyInfoDictionary withSize:sizeof(CFDictionaryRef) into:&infoDic withError:error])
        return NO;
    NSDictionary *dic = (__bridge NSDictionary *)infoDic;
    [dic setValue:metadata.title forKey:@kAFInfoDictionary_Title];
    [dic setValue:metadata.author forKey:@kAFInfoDictionary_Artist];
    [dic setValue:metadata.composer forKey:@kAFInfoDictionary_Composer];
    [dic setValue:metadata.album forKey:@kAFInfoDictionary_Album];
    infoDic = (__bridge CFDictionaryRef)dic;
    if (![self setAFProperty:kAudioFilePropertyInfoDictionary withSize:sizeof(CFDictionaryRef) from:&infoDic withError:error]) {
        CFRelease(infoDic);
        return NO;
    }
    //TODO: if this fails, use https://id3.org/id3v2.4.0-frames and manually craft the ID3 tag.
    return YES;
}

- (BOOL)close:(NSError **)error {
    OSStatus status = ExtAudioFileDispose(_file);
    if (status != noErr) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

@end
