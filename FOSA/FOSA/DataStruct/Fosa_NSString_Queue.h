//
//  Fosa_NSString_Queue.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Fosa_NSString_Queue : NSObject

+ (instancetype) arrayQueue;
+ (instancetype) arrayQueueWithCapacity:(NSInteger)capacity;
- (instancetype) initWithCapacity:(NSInteger)capacity;

- (void)enqueue:(NSString *)obj; ///入队列
- (id) dequeue; ///出队列
- (void) removeAllObjects; ///移除队列里边所有元素
- (void) DeleObjectByIndex:(NSInteger)i;
- (NSMutableArray *)returnArray;  //
- (int)getTheSameObjectIndex:(NSString *)obj;
-(Boolean)isContainObject:(NSString *)obj;

///firstObject
@property (nonatomic,weak) NSString *firstObject;
///size
@property (nonatomic,assign,readonly) NSInteger size;
///isEmpty
@property (nonatomic,assign,getter=isEmpty) BOOL empty;


@end

NS_ASSUME_NONNULL_END
