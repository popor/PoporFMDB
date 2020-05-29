//
//  PoporFMDB.h
//  IpaTool
//
//  Created by 王凯庆 on 2017/3/1.
//  Copyright © 2017年 wanzi. All rights reserved.
//

#import "PoporFMDBBase.h"

#define PDBShare [PoporFMDB share]

#define PDB      PoporFMDB

@interface PoporFMDB : PoporFMDBBase

// 1.first you need update and check DB table array.
+ (void)injectTableArray:(NSArray<Class> *)tableArray;

// 2.use it.
+ (PoporFMDB *)share;

#pragma mark - baseMethod
+ (BOOL)addEntity:(id)entity;
+ (BOOL)deleteEntity:(id)entity where:(NSString *)whereKey;
+ (BOOL)deleteEntity:(id)entity where:(NSString *)whereKey equal:(id)whereValue;
+ (BOOL)deleteClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue;
+ (BOOL)deleteTable:(NSString *)tableName where:(NSString *)whereKey equal:(id)whereValue;

// !!!:目前没有非或者不需要wherekey的接口
+ (BOOL)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(NSString *)whereKey;
+ (BOOL)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue;
+ (BOOL)updateClass:(Class)class key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue;

// 设置1个, 条件where 1个
+ (BOOL)updateTable:(NSString *)tableName key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue;

// 设置1个, 条件where N个
//+ (BOOL)updateTable:(NSString *)tableName key:(NSString *)key equal:(id)value whereS:(NSString *)whereKeyArray equalS:(id)whereValueArray;

// 设置N个, 条件where 1个
//+ (BOOL)updateTable:(NSString *)tableName keyS:(NSString *)keyArray equalS:(id)valueArray where:(NSString *)whereKey equal:(id)whereValue;

// 设置N个, 条件where N个
+ (BOOL)updateTable:(NSString *)tableName keyS:(NSArray *)keyArray equalS:(NSArray *)valueArray whereS:(NSArray *)whereKeyArray equalS:(NSArray *)whereValueArray;

// 一次性更新entity所有参数
+ (BOOL)updateEntity:(id)entity where:(NSString *)whereKey;

+ (NSMutableArray *)arrayClass:(Class)class;
+ (NSMutableArray *)arrayClass:(Class)class orderBy:(NSString *)orderKey asc:(BOOL)asc;
+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue;
+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue orderBy:(NSString *)orderKey asc:(BOOL)asc;

+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey like:(id)whereValue;
+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey like:(id)whereValue orderBy:(NSString *)orderKey asc:(BOOL)asc;

#pragma mark - 模仿plist数据

+ (NSString *)getPlistKey:(NSString *)key;
+ (BOOL)addPlistKey:(NSString *)key value:(NSString *)value;
+ (BOOL)updatePlistKey:(NSString *)key value:(NSString *)value;



@end
