//
//  NSFMDB.h
//  villas
//
//  Created by popor on 14-3-27.
//  Copyright (c) 2014年 Crystal Digital Technology Co.,LTD (Shanghai). All rights reserved.
//
// 生成sql常用语句
#import <Foundation/Foundation.h>

#import <fmdb/FMDatabase.h>

#define NeedDrop @"NeedDrop"
#define NeedAdd  @"NeedAdd"

@interface NSFMDB : NSObject

/**
 假如theClassEntity 包含 id 且不为string, 则默认为 INTEGER PRIMARY KEY AUTOINCREMENT
 */
+ (NSString *)getCreateSQLS:(id)theClassEntity with:(NSString *)theTableName;

/**
 假如theClassEntity 包含 id 且不为string, 则忽略该项, 让其执行自增长
*/
+ (NSString *)getInsertSQLS:(id)theClassEntity with:(NSString *)theTableName;

/**
 暂且不考虑 emoj 表情
 */
//+ (NSString *)getInsertEmojSQLS:(id)theClassEntity with:(NSString *)theTableName;

+ (void)setFullEntity:(id)theClassEntity withRS:(FMResultSet *)rs;
+ (NSMutableDictionary *)getPropertyArray:(id)theClassEntity;
+ (NSString *)getPropertyAttributesString:(id)theClassEntity with:(NSString *)propertyName;

@end

