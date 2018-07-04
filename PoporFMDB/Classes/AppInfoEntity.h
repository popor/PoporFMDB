//
//  AppInfoEntity.h
//  IpaTool
//
//  Created by 王凯庆 on 2017/3/1.
//  Copyright © 2017年 wanzi. All rights reserved.
//
// 用于检查DB中记录的table数据
#import <Foundation/Foundation.h>

@interface AppInfoEntity : NSObject

@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * value;

@end


@interface DBTableName : NSObject

@property (nonatomic, strong) NSString * name;

@end
