//
//  Fosa_Queue.h
//  fosa1.0
//
//  Created by hs on 2019/11/1.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Fosa_Queue : NSObject


+ (instancetype) arrayQueue;
+ (instancetype) arrayQueueWithCapacity:(NSInteger)capacity;
- (instancetype) initWithCapacity:(NSInteger)capacity;

- (void)enqueue:(AVMetadataMachineReadableCodeObject *)obj; ///入队列
- (id) dequeue; ///出队列
- (void) removeAllObjects; ///移除队列里边所有元素
- (NSMutableArray *)returnArray;  //
- (int)getTheSameObjectIndex:(AVMetadataMachineReadableCodeObject *)obj;

///firstObject
@property (nonatomic,weak) AVMetadataMachineReadableCodeObject *firstObject;
///size
@property (nonatomic,assign,readonly) NSInteger size;
///isEmpty
@property (nonatomic,assign,getter=isEmpty) BOOL empty;

@end

NS_ASSUME_NONNULL_END
