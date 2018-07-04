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
+ (void)addEntity:(id)entity;
+ (void)deleteEntity:(id)entity where:(NSString *)whereKey;
+ (void)deleteEntity:(id)entity where:(NSString *)whereKey equal:(id)whereValue;
+ (void)deleteClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue;
+ (void)deleteTable:(NSString *)tableName where:(NSString *)whereKey equal:(id)whereValue;

// !!!:目前没有非或者不需要wherekey的接口
+ (void)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(NSString *)whereKey;
+ (void)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue;
+ (void)updateClass:(Class)class key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue;
+ (void)updateTable:(NSString *)tableName key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue;

+ (NSMutableArray *)arrayClass:(Class)class;
+ (NSMutableArray *)arrayClass:(Class)class orderBy:(NSString *)orderKey asc:(BOOL)asc;
+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue;
+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue orderBy:(NSString *)orderKey asc:(BOOL)asc;

#pragma mark - 模仿plist数据

+ (NSString *)getPlistKey:(NSString *)key;
+ (void)addPlistKey:(NSString *)key value:(NSString *)value;
+ (void)updatePlistKey:(NSString *)key value:(NSString *)value;



@end
