//
//  VersionUpAnnounceOperation.h
//  TLines
//
//  Created by Ryu Iwasaki on 2013/08/03.
//  Copyright (c) 2013年 Ryu Iwasaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionUpAnnounceOperation : NSOperation<UIAlertViewDelegate>

@property (nonatomic)NSString *note;

@property (copy, nonatomic)void (^successBlock)();
@property (copy, nonatomic)void (^notUpdateVersionBlock)();

@property (nonatomic)BOOL ready;
@property (nonatomic)BOOL executing;
@property (nonatomic)BOOL finished;
@property (nonatomic)BOOL cancelled;

+ (id)load;
- (id)initWithNote:(NSString *)note completionBlock:(void(^)())completionBlock;
- (void)announce;
@end
