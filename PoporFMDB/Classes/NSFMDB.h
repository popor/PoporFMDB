//
//  NSFMDB.h
//  villas
//
//  Created by popor on 14-3-27.
//  Copyright (c) 2014年 Crystal Digital Technology Co.,LTD (Shanghai). All rights reserved.
//
// 生成sql常用语句
#import <Foundation/Foundation.h>

#import <FMDB/FMDatabase.h>

#define NeedDrop	@"NeedDrop"
#define NeedAdd		@"NeedAdd"

@interface NSFMDB : NSObject

+ (NSString *)getCreateSQLS:(id)theClassEntity 	with:(NSString *)theTableName;
+ (NSString *)getInsertSQLS:(id)theClassEntity 	with:(NSString *)theTableName;
+ (NSString *)getInsertEmojSQLS:(id)theClassEntity 	with:(NSString *)theTableName;
+ (void)setFullEntity:(id)theClassEntity withRS:(FMResultSet *)rs;
+ (NSMutableDictionary *)getPropertyArray:(id)theClassEntity;
+ (NSString *)getPropertyAttributesString:(id)theClassEntity with:(NSString *)propertyName;

@end
