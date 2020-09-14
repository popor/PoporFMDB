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

@interface PoporFMDB <PoporFMDB_T>: PoporFMDBBase

// 1.first you need update and check DB table array.
+ (void)injectTableArray:(NSArray<Class> *)tableArray;

// 2.use it.
+ (PoporFMDB *)share;

#pragma mark - baseMethod
+ (BOOL)addEntity:(id)entity;

// MARK: DELETE
//+ (BOOL)deleteEntity:(id)entity         where:(NSString *)whereKey;// 不再支持此函数, 满足函数单一原则, 维护太麻烦了, 而且比较浪费cpu.
+ (BOOL)deleteEntity:(id)entity           where:(PoporFMDB_T)whereKey equal:(id)whereValue;
+ (BOOL)deleteClass:(Class)class          where:(PoporFMDB_T)whereKey equal:(id)whereValue;
+ (BOOL)deleteTable:(NSString *)tableName where:(PoporFMDB_T)whereKey equal:(id)whereValue;

+ (BOOL)deleteEntity:(id)entity           where:(PoporFMDB_T)whereKey like:(id)whereValue;
+ (BOOL)deleteClass:(Class)class          where:(PoporFMDB_T)whereKey like:(id)whereValue;
+ (BOOL)deleteTable:(NSString *)tableName where:(PoporFMDB_T)whereKey like:(id)whereValue;

/**
 equalSymbol: = 或者 like
 */
+ (BOOL)deleteTable:(NSString *)tableName where:(PoporFMDB_T)whereKey equalSymbol:(NSString *)equalSymbol value:(id)whereValue;

// MARK: update
/**
 setKey 是数组的话, setValue必须是数组; setKey是NSString的话,setValuebi不能是数组.  SQL value本身不支持数组.
 同样针对于whereKey和whereValue.
 */
+ (BOOL)updateEntity:(id)entity           set:(PoporFMDB_T)setKey equal:(id)setValue where:(PoporFMDB_T)whereKey equal:(id)whereValue;
+ (BOOL)updateClass:(Class)class          set:(PoporFMDB_T)setKey equal:(id)setValue where:(PoporFMDB_T)whereKey equal:(id)whereValue;
+ (BOOL)updateTable:(NSString *)tableName set:(id)setKey          equal:(id)setValue where:(id)whereKey          equal:(id)whereValue;

// 升降序功能失效了, 否则会出错.
+ (NSMutableArray *)arrayClass:(Class)class;
+ (NSMutableArray *)arrayClass:(Class)class where:(id)whereKey equal:(id)whereValue;

+ (NSMutableArray *)arrayClass:(Class)class where:(id)whereKey like:(id)whereValue;

#pragma mark - 模仿plist数据

+ (NSString *)getPlistKey:(NSString *)key;
+ (BOOL)addPlistKey:(NSString *)key    value:(NSString *)value;
+ (BOOL)updatePlistKey:(NSString *)key value:(NSString *)value;



@end
