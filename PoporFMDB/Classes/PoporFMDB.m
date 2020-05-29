//
//  PoporFMDB.m
//  IpaTool
//
//  Created by 王凯庆 on 2017/3/1.
//  Copyright © 2017年 wanzi. All rights reserved.
//

#import "PoporFMDB.h"
#import "NSFMDB.h"

#import "AppInfoEntity.h"

@implementation PoporFMDB

// 第一步需要注入数据库class
+ (void)injectTableArray:(NSArray<Class> *)tableArray {
    PoporFMDB * tool = PDBShare;
    if (!tool.classDic) {
        NSMutableDictionary * classDic = [NSMutableDictionary new];
        [classDic setObject:[AppInfoEntity class] forKey:NSStringFromClass([AppInfoEntity class])];
        for (Class class in tableArray) {
            [classDic setObject:class forKey:NSStringFromClass(class)];
        }

        tool.classDic = classDic;
        
        [tool updateDBStruct];
    }else{
        NSLog(@"PoporFMDB : inject table action execute only once.");
    }
}

+ (PoporFMDB *)share {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

#pragma mark - baseMethod
+ (BOOL)addEntity:(id)entity {
    BOOL success = NO;
    if (!entity) {
        return success;
    }
    PoporFMDB * tool = [PoporFMDB share];
    [tool start];
    
    success = [tool.db executeUpdate:[NSFMDB getInsertSQLS:entity with:NSStringFromClass([entity class])]];
    
    [tool end];
    
    return success;
}

+ (BOOL)deleteEntity:(id)entity where:(NSString *)whereKey {
    return [self deleteEntity:entity where:whereKey equal:nil];
}

+ (BOOL)deleteEntity:(id)entity where:(NSString *)whereKey equal:(id)whereValue {
    BOOL success = NO;
    if (!entity || !whereKey) {
        return success;
    }
    
    NSString * tableName  = NSStringFromClass([entity class]);
    if (!whereValue) {
        whereValue = [entity valueForKey:whereKey];
    }
    
    success = [PoporFMDB deleteTable:tableName where:whereKey equal:whereValue];
    return success;
}

+ (BOOL)deleteClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue {
    NSString * tableName  = NSStringFromClass(class);
    return [PoporFMDB deleteTable:tableName where:whereKey equal:whereValue];
}

+ (BOOL)deleteTable:(NSString *)tableName where:(NSString *)whereKey equal:(id)whereValue {
    BOOL success = NO;
    if (!tableName || !whereKey) {
        return success;
    }
    
    NSString * futureSQL = [NSString stringWithFormat:@"DELETE FROM %@ where %@ = ?;", tableName, whereKey];
    
    //@"SELECT * FROM "noteBookTableName" WHERE pageIndex=?;"
    //[self.db executeUpdate:@"UPDATE "noteBookTableName" set recordText=? , recordTitle=? where recordUUID=?;"
    
    PoporFMDB * tool = [PoporFMDB share];
    [tool start];
    
    success = [tool.db executeUpdate:futureSQL, whereValue];
    
    [tool end];
    return success;
}

// !!!:目前没有非或者不需要wherekey的接口
+ (BOOL)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(id)whereKey {
    return [self updateEntity:entity key:key equal:value where:whereKey equal:nil];
}

+ (BOOL)updateEntity:(id)entity key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue {
    BOOL success = NO;
    if (!entity || !key || !whereKey) {
        return success;
    }
    
    NSString * tableName  = NSStringFromClass([entity class]);
    if (!whereValue) {
        whereValue = [entity valueForKey:whereKey];
    }
    
    return [self updateTable:tableName key:key equal:value where:whereKey equal:whereValue];
}

+ (BOOL)updateClass:(Class)class key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue {
    NSString * tableName  = NSStringFromClass(class);
    return [self updateTable:tableName key:key equal:value where:whereKey equal:whereValue];
}

// 设置1个, 条件where 1个
+ (BOOL)updateTable:(NSString *)tableName key:(NSString *)key equal:(id)value where:(NSString *)whereKey equal:(id)whereValue {
    BOOL success = NO;
    if (!tableName || !key || !whereKey) {
        return success;
    }
    
    NSString * futureSQL = [NSString stringWithFormat:@"UPDATE %@ set %@ = ? where %@ = ?;", tableName, key, whereKey];
    
    PoporFMDB * tool = [PoporFMDB share];
    [tool start];
    success = [tool.db executeUpdate:futureSQL, value, whereValue];
    [tool end];
    return success;
}

/**
 where 仅支持 and 语法
 */
+ (BOOL)updateTable:(NSString *)tableName keyS:(NSArray *)keyArray equalS:(NSArray *)valueArray whereS:(NSArray *)whereKeyArray equalS:(NSArray *)whereValueArray {
    BOOL success = NO;
    if (!tableName) {
        NSLog(@"❌❌❌ PoporFMDB Error : tableName is nil");
        return success;
    }
    if (keyArray.count == 0) {
        NSLog(@"❌❌❌ PoporFMDB Error : keyArray is nil");
        return success;
    }
    if (whereKeyArray.count == 0) {
        NSLog(@"❌❌❌ PoporFMDB Error : whereKeyArray is nil");
        return success;
    }
    
    if (keyArray.count != valueArray.count) {
        NSLog(@"❌❌❌ PoporFMDB Error : keyArray.count != valueArray.count");
        return success;
    }
    if (whereKeyArray.count != whereValueArray.count) {
        NSLog(@"❌❌❌ PoporFMDB Error : whereKeyArray.count != whereValueArray.count");
        return success;
    }
    
    
    NSMutableString * sql = [NSMutableString new];
    [sql appendFormat:@"UPDATE %@ ", tableName];
    
    // set 循环
    [sql appendString:@"set "];
    for (int i = 0; i<keyArray.count; i++) {
        if (i == 0) {
            [sql appendFormat:@"%@ = ? ", keyArray[i]];
        } else {
            [sql appendFormat:@", %@ = ? ", keyArray[i]];
        }
    }
    
    // where 循环
    [sql appendString:@"where "];
    for (int i=0; i<whereKeyArray.count; i++) {
        if (i == 0) {
             [sql appendFormat:@"%@ = ? ", whereKeyArray[i]];
        } else {
            [sql appendFormat:@"AND %@ = ? ", whereKeyArray[i]];
        }
    }
    NSMutableArray * updateArray = [NSMutableArray new];
    [updateArray addObjectsFromArray:valueArray];
    [updateArray addObjectsFromArray:whereValueArray];
    
    PoporFMDB * tool = [PoporFMDB share];
    [tool start];
    success = [tool.db executeUpdate:sql, value, whereValue];
    [tool end];
    
    return success;
}

+ (NSMutableArray *)arrayClass:(Class)class {
    return [self arrayClass:class where:nil equal:nil orderBy:nil asc:YES];
}

+ (NSMutableArray *)arrayClass:(Class)class orderBy:(NSString *)orderKey asc:(BOOL)asc {
    return [self arrayClass:class where:nil equal:nil orderBy:orderKey asc:asc];
}

+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue {
    return [self arrayClass:class where:whereKey equal:whereValue orderBy:nil asc:YES];
}

+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equal:(id)whereValue orderBy:(NSString *)orderKey asc:(BOOL)asc {
    return [self arrayClass:class where:whereKey equalSymbol:@"="    equal:whereValue orderBy:orderKey asc:asc];
}

+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey like:(id)whereValue {
    return [self arrayClass:class where:whereKey equalSymbol:@"like" equal:whereValue orderBy:nil asc:YES];
}

+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey like:(id)whereValue orderBy:(NSString *)orderKey asc:(BOOL)asc {
    return [self arrayClass:class where:whereKey equalSymbol:@"like" equal:whereValue orderBy:orderKey asc:asc];
}

+ (NSMutableArray *)arrayClass:(Class)class where:(NSString *)whereKey equalSymbol:(NSString *)equalSymbol equal:(id)whereValue orderBy:(NSString *)orderKey asc:(BOOL)asc {
    if (!class) {
        return nil;
    }
    PoporFMDB * tool = [PoporFMDB share];
    [tool start];
    
    NSString * tableName  = NSStringFromClass(class);
    NSString * ascValue = asc ? @"ASC":@"DESC";
    NSMutableArray * array = [[NSMutableArray alloc]  init];
    
    FMResultSet *rs;
    NSString * futureSQL;
    if (whereKey && !orderKey) {
        futureSQL = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ %@ ?;", tableName, whereKey, equalSymbol];
        rs = [tool.db executeQuery:futureSQL, whereValue];
        
    }else if(!whereKey && orderKey){
        futureSQL = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ %@;", tableName, orderKey, ascValue];
        rs = [tool.db executeQuery:futureSQL];
        
    } else if (whereKey && orderKey) {
        futureSQL = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ %@ ? ORDER BY %@ %@;", tableName, whereKey, equalSymbol, orderKey, ascValue];
        rs = [tool.db executeQuery:futureSQL, whereValue];
        
    }else{
        futureSQL = [NSString stringWithFormat:@"SELECT * FROM %@;", tableName];
        rs = [tool.db executeQuery:futureSQL];
    }
    
    while ([rs next]) {
        id entity = [[class alloc] init];
        [NSFMDB setFullEntity:entity withRS:rs];
        [array addObject:entity];
    }
    [tool end];
    return array;
}

#pragma mark - 模仿plist数据
+ (NSString *)getPlistKey:(NSString *)key {
    NSArray * array = [PoporFMDB arrayClass:[AppInfoEntity class] where:@"key" equal:key];
    if (array.count == 1) {
        AppInfoEntity * entity = [array firstObject];
        return entity.value;
    }else{
        return nil;
    }
}

+ (BOOL)addPlistKey:(NSString *)key value:(NSString *)value {
    
    NSMutableArray * array = [PoporFMDB arrayClass:[AppInfoEntity class] where:@"key" equal:key];
    if (array.count >= 1) {
        [PoporFMDB deleteClass:[AppInfoEntity class] where:@"key" equal:key];
    }
    
    AppInfoEntity * entity = [AppInfoEntity new];
    entity.key   = key;
    entity.value = value;
    return [PoporFMDB addEntity:entity];
}

+ (BOOL)updatePlistKey:(NSString *)key value:(NSString *)value {
    AppInfoEntity * entity = [AppInfoEntity new];
    entity.key   = key;
    entity.value = value;
    return [PoporFMDB updateEntity:entity key:@"value" equal:value where:@"key" equal:key];
}

@end
