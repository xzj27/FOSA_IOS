//
//  Fosa_Queue.m
//  fosa1.0
//
//  Created by hs on 2019/11/1.
//  Copyright © 2019 hs. All rights reserved.
//
#import "Fosa_Queue.h"
@interface Fosa_Queue(){
    NSMutableArray *_array;
}
@end

@implementation Fosa_Queue

+ (instancetype)arrayQueue {
    return [[Fosa_Queue alloc] initWithCapacity:10];
}

+ (instancetype)arrayQueueWithCapacity:(NSInteger)capacity {
    return [[Fosa_Queue alloc] initWithCapacity:capacity];
}

- (instancetype)initWithCapacity:(NSInteger)numItems {
    if (self = [super init]) {
        _array = [NSMutableArray arrayWithCapacity:numItems];
    }
    return self;
}

- (void)enqueue:(id)obj {
    [_array addObject:obj];
}

- (id)dequeue {
    [_array removeObjectAtIndex:0];
    return nil;
}

- (id)firstObject {
    return [_array firstObject];
}
- (NSMutableArray *)returnArray{
    return _array;
}

//返回在array中与obj相同的元素的索引，不存在则返回-1
-(int)getTheSameObjectIndex:(AVMetadataMachineReadableCodeObject *)obj{
    int index;
    if (_array.count > 0) {
        for (int i = 0; i< _array.count; i++) {
            if ([_array[i] isEqual:obj]) {
                index = i;
                return index;
            }
        }
    }
    return -1;
}

- (void)removeAllObjects {
    [_array removeAllObjects];
}

- (NSInteger)size {
    return _array.count;
}
- (BOOL)isEmpty {
    return _array.count == 0;
}

- (NSString *)description {
    
    NSMutableString *res = [NSMutableString string];
    [res appendFormat:@"ArrayQueue: %p \n",self];
    [res appendString:@"front [ "];
    for (int i = 0; i<_array.count; i++) {
        id object = [_array objectAtIndex:i];
        [res appendFormat:@"%@",object];
        if (i != _array.count - 1) {
            [res appendString:@" , "];
        }
    }
    [res appendString:@" ] tail "];
    return res;
}

- (void)dealloc
{
    
}

@end
