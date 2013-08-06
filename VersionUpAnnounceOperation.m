//
//  VersionUpAnnounceOperation.m
//  TLines
//
//  Created by Ryu Iwasaki on 2013/08/03.
//  Copyright (c) 2013年 Ryu Iwasaki. All rights reserved.
//

#import "VersionUpAnnounceOperation.h"

NSString *VersionKey = @"VersionKey";
@implementation VersionUpAnnounceOperation{
    NSString *_version;
}

- (void)announce{
    DEBUG_LOG(@"announce");
    [[[NSOperationQueue alloc]init]addOperation:self];
}

- (id)initWithNote:(NSString *)note completionBlock:(void(^)())completionBlock{
    
    self = [super init];
    
    if (self) {
        _note = note;
        [self setCompletionBlock:completionBlock];       
        [self load];

    }
    
    return self;
}

- (void)start{
    if (_finished || _cancelled) {
        [self cancel];
        return;
    }
    
    [self setReady:NO];
    [self setExecuting:YES];
    [self setFinished:NO];
    [self setCancelled:NO];
    
    [self main];
    
}

- (void)main{
    [self showAlert];
    [self save];
}

- (void)showAlert{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if ([self isUpdatedVersion]) {
            
            NSString *title = [[NSString alloc]initWithFormat:@"Ver.%@",[self thisVersion]];
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:title
                                                          message:_note
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];

            [view show];
            
        } else {
            self.notUpdateVersionBlock();
            [self setReady:NO];
            [self setExecuting:NO];
            [self setFinished:YES];
            [self setCancelled:NO];
        }
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.successBlock();
    [self setReady:NO];
    [self setExecuting:NO];
    [self setFinished:YES];
    [self setCancelled:NO];
}

- (BOOL)isUpdatedVersion{
    
    
    if ([_version isEqualToString:[self thisVersion]]) {
        return NO;
    } else {
        return YES;
    }
    
    return NO;
}

+ (id)load {
    VersionUpAnnounceOperation *announce = [[VersionUpAnnounceOperation alloc]initWithNote:@"" completionBlock:nil];

    return announce;
}

- (void)load{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *archiveDataPath = [self archiveDataPath];
    
    if ( archiveDataPath && [fileManager fileExistsAtPath:archiveDataPath] ){
        
    } else {
        
        return;
    }
    
    NSDictionary *unarchiveItem = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveDataPath];
    
    if ( !unarchiveItem ) {
        return;
    }
    
    [self updateWithData:unarchiveItem];
    
    return;
}

- (void)updateWithData:(NSDictionary *)data{
    
    _version = data[VersionKey];
}

- (NSString *)thisVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (void)save{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *targetDirPath = [self targetDirPath];
    
    if (![fileManager fileExistsAtPath:targetDirPath]) {
        
        NSError*    error;
        [fileManager createDirectoryAtPath:targetDirPath
               withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [self archiveWithObject:[self archiveData]];
}

- (NSDictionary *)archiveData{
    
    NSDictionary *data = @{
                           VersionKey : [self thisVersion],
                           };
    
    return data;
    
}

- (void)archiveWithObject:(id)archiveObject{
    
    NSString *archiveDataPath = [self archiveDataPath];
    [NSKeyedArchiver archiveRootObject:archiveObject toFile:archiveDataPath];
}

- (NSString *)targetDirPath{
    
    NSArray *documentsDirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    
    if (documentsDirPaths.count < 1) {
        return nil;
    }
    
    NSString *documentsDirPath = documentsDirPaths[0];
    
    NSString *targetDirPath = [documentsDirPath stringByAppendingPathComponent:@".versionUpAnnouncement"];
    
    return targetDirPath;
    
}

- (NSString *)archiveDataPath{
    NSString *path = [[self targetDirPath] stringByAppendingPathComponent:@".data"];
    
    return path;
}

//--------------------------------------------------------------//
#pragma mark  - KVO
//--------------------------------------------------------------//

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
}

- (void)setReady:(BOOL)isReady {
    if (_ready != isReady) {
        [self willChangeValueForKey:@"isReady"];
        _ready = isReady;
        [self didChangeValueForKey:@"isReady"];
    }
}
- (void)setExecuting:(BOOL)isExecuting {
    if (_executing != isExecuting) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = isExecuting;
        [self didChangeValueForKey:@"isExecuting"];
    }
}
- (void)setFinished:(BOOL)isFinished {
    if (_finished != isFinished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = isFinished;
        [self didChangeValueForKey:@"isFinished"];
    }
}
- (void)setCancelled:(BOOL)isCancelled {
    if (_cancelled != isCancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = isCancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
}

//--------------------------------------------------------------//
#pragma mark  - Status
//--------------------------------------------------------------//

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished{
    return _finished;
}

- (BOOL)isExecuting{
    return _executing;
}

@end
