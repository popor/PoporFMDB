//
//  TestEntity.m
//  PoporFMDB_Example
//
//  Created by apple on 2018/7/4.
//  Copyright © 2018年 wangkq. All rights reserved.
//

#import "TestEntity.h"

@implementation TestEntity

- (NSString *)description {
    return [NSString stringWithFormat:@"title: %@, subtitle: %@, content: %@, t1: %@, t2: %i", self.title, self.subtitle, self.content, self.t1, self.t2];
}

@end
