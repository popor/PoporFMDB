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

// MARK: DELETE
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

// MARK: update
+ (BOOL)updateEntity:(id)entity set:(id)setKey equal:(id)setValue where:(id)whereKey equal:(id)whereValue {
    if (!entity) {
        NSLog(@"❌❌❌ PoporFMDB Error : entity is nil");
        return NO;
    }
    NSString * tableName  = NSStringFromClass([entity class]);
    return [self updateTable:tableName set:setKey equal:setValue where:whereKey equal:whereValue];
}

+ (BOOL)updateClass:(Class)class set:(id)setKey equal:(id)setValue where:(id)whereKey equal:(id)whereValue {
    NSString * tableName  = NSStringFromClass(class);
    return [self updateTable:tableName set:setKey equal:setValue where:whereKey equal:whereValue];
}

/**
 where 仅支持 and 语法
 */
+ (BOOL)updateTable:(NSString *)tableName set:(id)setKey equal:(id)setValue where:(id)whereKey equal:(id)whereValue {
    BOOL success = NO;
    
    NSArray * setKeyArray;
    NSArray * setValueArray;
    NSArray * whereKeyArray;
    NSArray * whereValueArray;
    
    // 统一整理成数组
    if ([setKey isKindOfClass:[NSArray class]]) {
        setKeyArray   = (NSArray *)setKey;
        setValueArray = (NSArray *)setValue;
    } else {
        setKeyArray   = @[setKey];
        setValueArray = @[setValue];
    }
    if (whereKey) {
        if ([whereKey isKindOfClass:[NSArray class]]) {
            whereKeyArray   = (NSArray *)whereKey;
            whereValueArray = (NSArray *)whereValue;
        } else {
            whereKeyArray   = @[whereKey];
            whereValueArray = @[whereValue];
        }
    }
    
    // 异常排查
    if (!tableName) {
        NSLog(@"❌❌❌ PoporFMDB Error : tableName is nil");
        return success;
    }
    if (setKeyArray.count == 0) {
        NSLog(@"❌❌❌ PoporFMDB Error : setKeyArray is nil");
        return success;
    }
    if (setKeyArray.count != setValueArray.count) {
        NSLog(@"❌❌❌ PoporFMDB Error : setKeyArray.count != setValueArray.count");
        return success;
    }
    // where 可以为空
    if (whereKeyArray.count != 0 && whereKeyArray.count != whereValueArray.count) {
        NSLog(@"❌❌❌ PoporFMDB Error : whereKeyArray.count != whereValueArray.count");
        return success;
    }
    
    NSMutableString * sql = [NSMutableString new];
    [sql appendFormat:@"UPDATE %@ ", tableName];
    
    // set 循环
    [sql appendString:@"set "];
    for (int i = 0; i<setKeyArray.count; i++) {
        if (i == 0) {
            [sql appendFormat:@"%@ = ? ", setKeyArray[i]];
        } else {
            [sql appendFormat:@", %@ = ? ", setKeyArray[i]];
        }
    }
    
    // where 循环
    if (whereKeyArray.count > 0) {
        [sql appendString:@"where "];
        for (int i=0; i<whereKeyArray.count; i++) {
            if (i == 0) {
                [sql appendFormat:@"%@ = ? ", whereKeyArray[i]];
            } else {
                [sql appendFormat:@"AND %@ = ? ", whereKeyArray[i]];
            }
        }
    }
    
    // 拼接SQL
    NSMutableArray * updateArray = [NSMutableArray new];
    [updateArray addObjectsFromArray:setValueArray];
    if (whereKeyArray.count > 0) {
        [updateArray addObjectsFromArray:whereValueArray];
    }
    
    PoporFMDB * tool = [PoporFMDB share];
    [tool start];
    success = [tool.db executeUpdate:sql withArgumentsInArray:updateArray]; // https://www.thinbug.com/q/431910
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
    return [PoporFMDB updateEntity:entity set:@"value" equal:value where:@"key" equal:key];
}

@end

// 移除的函数
//+ (BOOL)updateEntity:(id)entity set:(id)setKey equal:(id)setValue where:(id)whereKey {
//    return [self updateEntity:entity set:setKey equal:setValue where:whereKey equal:nil];
//}

//+ (BOOL)updateEntity:(id)entity set:(id)setKey equal:(id)setValue where:(id)whereKey equal:(id)whereValue {
//    if (!entity) {
//        NSLog(@"❌❌❌ PoporFMDB Error : entity is nil");
//        return NO;
//    }
//    NSString * tableName  = NSStringFromClass([entity class]);
//
//    if ((whereKey && whereValue) || (!whereKey && !whereValue)) {
//        return [self updateTable:tableName set:setKey equal:setValue where:whereKey equal:whereValue];
//    } else {
//        if (!whereKey) {
//            NSLog(@"❌❌❌ PoporFMDB Error : whereKey is nil, whereValue not nil.");
//            return NO;
//        } else {
//            NSArray * whereKey_edit;
//            if ([whereKey isKindOfClass:[NSArray class]]) {
//                whereKey_edit = (NSArray *)whereKey;
//            } else {
//                whereKey_edit = @[whereKey];
//            }
//
//            NSMutableArray * whereValue_edit = [NSMutableArray new];
//            for (NSString * whereKey in whereKey_edit) {
//                NSObject * ob = [entity valueForKey:whereKey];
//                if (ob) {
//                    [whereValue_edit addObject:ob];
//                } else {
//                    NSLog(@"❌❌❌ PoporFMDB Error : create whereValueArray with nil object");
//                    return NO;
//                }
//            }
//            return [self updateTable:tableName set:setKey equal:setValue where:whereKey equal:whereValue_edit];
//        }
//    }
//}
