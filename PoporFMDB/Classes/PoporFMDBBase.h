//
//  VCDao.h
//  Course
//
//  Created by popor on 12-6-7.
//  Copyright (c) 2012年 popor. All rights reserved.
//
/**
 * V1.1 开始处理用户数据缓存.
 */

#import <Foundation/Foundation.h>

#import "NSFMDB.h"
#import "PoporFMDBPath.h"

@class FMDatabase;
@class FMResultSet;

/**
 *这是一个只读VCTable的数据库dao.
 */
@interface PoporFMDBBase : NSObject

@property (nonatomic, strong) FMDatabase * db;
@property (nonatomic, strong) NSMutableDictionary * classDic;

- (void)start;

- (void)end;

#pragma mark - 更新DB结构
- (void)updateDBStruct;

@end
