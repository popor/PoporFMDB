//
//  NSFMDB.m
//  villas
//
//  Created by popor on 14-3-27.
//  Copyright (c) 2014年 Crystal Digital Technology Co.,LTD (Shanghai). All rights reserved.
//

#import "NSFMDB.h"
#import <objc/runtime.h>
#import <PoporFoundation/NSString+pTool.h>

@implementation NSFMDB

/*
 S:Statement
 只支持全额属性集
 */
+ (NSString *)getCreateSQLS:(NSObject *)theClassEntity with:(NSString *)theTableName
{
    NSMutableString * sql_all      = [NSMutableString new];
    NSMutableString * sql_property = [NSMutableString new];
    NSString * idAutoIncrement     = @"id INTEGER PRIMARY KEY AUTOINCREMENT,";
    
    [sql_all appendFormat:@"CREATE TABLE %@ (", theTableName];// 开头
    
    unsigned propertyCount;
    BOOL isHasId = NO;
    objc_property_t *properties = class_copyPropertyList([theClassEntity class],&propertyCount);
    for(int i=0;i<propertyCount;i++){
        NSString * propNameString;
        NSString * propAttributesString;
        
        objc_property_t prop=properties[i];
        
        const char *propName = property_getName(prop);
        propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        // 如果entity包含id,则忽略
        if ([propNameString isEqualToString:@"id"]) {
            isHasId = YES;
        }
        const char * propAttributes=property_getAttributes(prop);
        propAttributesString =[NSString stringWithCString:propAttributes encoding:NSASCIIStringEncoding];
        // 根据各个情况处理.
        if ([propAttributesString hasPrefix:@"T@\"NSString\""]
            || [propAttributesString hasPrefix:@"T@\"NSMutableString\""]){
            // 字符类型
            [sql_property appendString:[NSString stringWithFormat:@"%@ TEXT,",propNameString]];
        }
        if ([propAttributesString hasPrefix:@"Tf"]){
            // 字符类型
            [sql_property appendString:[NSString stringWithFormat:@"%@ Float,",propNameString]];
        }
        if ([propAttributesString hasPrefix:@"Tc"]
            || [propAttributesString hasPrefix:@"TB"]
            || [propAttributesString hasPrefix:@"Ti"]
            || [propAttributesString hasPrefix:@"Tq"]
            
            || [propAttributesString hasPrefix:@"T@\"NSNumber\""]){
            // int类型
            // Tc: BOOL;
            // Ti: int;
            // 新增
            // TB:BOOL(64位)
            // Tq: NSIntger(64位)
            [sql_property appendString:[NSString stringWithFormat:@"%@ integer,",propNameString]];
        }
    } // end for.
    
    if (!isHasId) {
        [sql_all appendString:idAutoIncrement];
    }
    [sql_all appendString:sql_property];
    [sql_all setString:[sql_all substringToIndex:sql_all.length-1]];
    [sql_all appendString:@")"];// 结尾.
    
    free(properties);
    //NSLog(@"sql_all: %@", sql_all);
    
    return sql_all;
}

// 只支持全额属性集
+ (NSString *)getInsertSQLS:(id)theClassEntity with:(NSString *)theTableName
{
    NSMutableString * tempSQLS=[[NSMutableString alloc] init];
    
    NSMutableString * parameterIDs=[[NSMutableString alloc] init];
    NSMutableString * parameterValues=[[NSMutableString alloc] init];
    
    [tempSQLS appendString:@"INSERT INTO "];// 开头
    [tempSQLS appendString:theTableName];    // tableName
    
    [parameterIDs appendString:@"("];
    [parameterValues appendString:@"("];
    
    unsigned propertyCount;
    
    objc_property_t *properties = class_copyPropertyList([theClassEntity class],&propertyCount);
    for(int i=0;i<propertyCount;i++){
        NSString * propNameString;
        NSString * propAttributesString;
        
        objc_property_t prop=properties[i];
        
        const char *propName = property_getName(prop);
        propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];

        const char * propAttributes=property_getAttributes(prop);
        propAttributesString =[NSString stringWithCString:propAttributes encoding:NSASCIIStringEncoding];

        id value = [theClassEntity valueForKey:propNameString];
        NSString * valueString;
        
        // 根据各个情况处理.
        // 新增
        // TB:BOOL(64位)
        // Tq: NSIntger(64位)
        if ([propAttributesString hasPrefix:@"T@\"NSString\""]
            || [propAttributesString hasPrefix:@"T@\"NSMutableString\""]){
            valueString = [NSString stringWithFormat:@"%@",value];
            valueString = [valueString replaceWithREG:@"'" newString:@"''"];
        }
        if ([propAttributesString hasPrefix:@"Tc"]
            || [propAttributesString hasPrefix:@"Ti"]
            || [propAttributesString hasPrefix:@"TB"]
            || [propAttributesString hasPrefix:@"Tq"]
            ){
            valueString=[NSString stringWithFormat:@"%i",[value intValue]];
        }
        if ([propAttributesString hasPrefix:@"Tf"]){
            valueString=[NSString stringWithFormat:@"%f",[value floatValue]];
        }
        if ([propAttributesString hasPrefix:@"T@\"NSNumber\""]){
            
            NSNumber * oneNumber=(NSNumber *)value;
            valueString=[NSString stringWithFormat:@"%i",[oneNumber intValue]];
        }
        if (valueString==nil) {
            continue;
        }else {
            // 修改,加上单引号
            valueString=[NSString stringWithFormat:@"'%@'",valueString];
            // 赋值
            if (i==0) {
                [parameterIDs appendString:propNameString];
                [parameterValues appendString:valueString];
            }else {
                [parameterIDs appendString:[NSString stringWithFormat:@", %@",propNameString]];
                [parameterValues appendString:[NSString stringWithFormat:@", %@",valueString]];
            }
        }
    } // end for.
    {
        // 组装
        [parameterIDs appendString:@")"];
        [parameterValues appendString:@")"];
        
        [tempSQLS appendString:parameterIDs];
        [tempSQLS appendString:@"VALUES "];
        [tempSQLS appendString:parameterValues];
    }
    parameterIDs    = nil;
    parameterValues = nil;
    free(properties);
    return tempSQLS;
}

+ (NSString *)getInsertEmojSQLS:(id)theClassEntity     with:(NSString *)theTableName{
    NSMutableString * tempSQLS=[[NSMutableString alloc] init];
    
    NSMutableString * parameterIDs    = [NSMutableString new];
    NSMutableString * parameterValues = [NSMutableString new];
    
    [tempSQLS appendString:@"INSERT INTO "];// 开头
    [tempSQLS appendString:theTableName];    // tableName
    
    [parameterIDs appendString:@"("];
    [parameterValues appendString:@"("];
    
    unsigned propertyCount;
    
    objc_property_t *properties = class_copyPropertyList([theClassEntity class],&propertyCount);
    for(int i=0;i<propertyCount;i++){
        NSString * propNameString;
        NSString * propAttributesString;
        
        objc_property_t prop=properties[i];
        
        const char *propName = property_getName(prop);
        propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        const char * propAttributes=property_getAttributes(prop);
        propAttributesString =[NSString stringWithCString:propAttributes encoding:NSASCIIStringEncoding];
        
        id value = [theClassEntity valueForKey:propNameString];
        NSString * valueString;
        
        // 根据各个情况处理.
        // 新增
        // TB:BOOL(64位)
        // Tq: NSIntger(64位)
        if ([propAttributesString hasPrefix:@"T@\"NSString\""]
            || [propAttributesString hasPrefix:@"T@\"NSMutableString\""]){
            valueString = [NSString stringWithFormat:@"%@",value];
            valueString = [valueString replaceWithREG:@"'" newString:@"''"];
        }
        if ([propAttributesString hasPrefix:@"Tc"]
            || [propAttributesString hasPrefix:@"Ti"]
            || [propAttributesString hasPrefix:@"TB"]
            || [propAttributesString hasPrefix:@"Tq"]
            ){
            valueString=[NSString stringWithFormat:@"%i",[value intValue]];
        }
        if ([propAttributesString hasPrefix:@"Tf"]){
            valueString=[NSString stringWithFormat:@"%f",[value floatValue]];
        }
        if ([propAttributesString hasPrefix:@"T@\"NSNumber\""]){
            
            NSNumber * oneNumber=(NSNumber *)value;
            valueString=[NSString stringWithFormat:@"%i",[oneNumber intValue]];
        }
        if (valueString==nil) {
            continue;
        }else {
            // 修改,加上单引号
            valueString=[NSString stringWithFormat:@"'%@'",valueString];
            // 赋值
            if (i==0) {
                [parameterIDs appendString:propNameString];
                [parameterValues appendString:valueString];
            }else {
                [parameterIDs appendString:[NSString stringWithFormat:@", %@",propNameString]];
                [parameterValues appendString:[NSString stringWithFormat:@", %@",valueString]];
            }
        }
    } // end for.
    {
        // 组装
        [parameterIDs appendString:@")"];
        [parameterValues appendString:@")"];
        
        [tempSQLS appendString:parameterIDs];
        [tempSQLS appendString:@"VALUES "];
        [tempSQLS appendString:parameterValues];
    }
    parameterIDs    = nil;
    parameterValues = nil;
    free(properties);
    return tempSQLS;
}


// 只支持全额属性集
+ (void)setFullEntity:(id)theClassEntity withRS:(FMResultSet *)rs
{
    unsigned propertyCount;
    
    objc_property_t *properties = class_copyPropertyList([theClassEntity class],&propertyCount);
    for(int i=0;i<propertyCount;i++){
        NSString * propNameString;
        NSString * propAttributesString;
        
        objc_property_t prop = properties[i];
        
        const char *propName = property_getName(prop);
        propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        const char * propAttributes=property_getAttributes(prop);
        propAttributesString =[NSString stringWithCString:propAttributes encoding:NSASCIIStringEncoding];
        
        // TB:BOOL(64位)
        // Tq: NSIntger(64位)
        if ([propAttributesString hasPrefix:@"T@\"NSString\""]
            || [propAttributesString hasPrefix:@"T@\"NSMutableString\""]
            || [propAttributesString hasPrefix:@"T@\"NSNumber\""])
        {
            [theClassEntity setValue:[rs stringForColumn:propNameString] forKey:propNameString];
        }
        if ([propAttributesString hasPrefix:@"Tc"]
            || [propAttributesString hasPrefix:@"Ti"]
            || [propAttributesString hasPrefix:@"TB"]
            || [propAttributesString hasPrefix:@"Tq"]
        ){
            [theClassEntity setValue:[NSNumber numberWithInt:[[rs stringForColumn:propNameString] intValue]] forKey:propNameString];
        }
        if ([propAttributesString hasPrefix:@"Tf"])
        {
            [theClassEntity setValue:[NSNumber numberWithFloat:[[rs stringForColumn:propNameString] floatValue]] forKey:propNameString];
        }
        
    }
    free(properties);
    // end.
}

+ (NSMutableDictionary *)getPropertyArray:(id)theClassEntity
{
    NSMutableDictionary * oneDic=[[NSMutableDictionary alloc] init];
    unsigned propertyCount;
    
    objc_property_t *properties = class_copyPropertyList([theClassEntity class],&propertyCount);
    for(int i=0;i<propertyCount;i++){
        NSString * propNameString;
        objc_property_t prop=properties[i];
        const char *propName = property_getName(prop);
        propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        [oneDic setObject:NeedAdd forKey:propNameString];
    } // end for.
    free(properties);
    return oneDic;
}

+ (NSString *)getPropertyAttributesString:(id)theClassEntity with:(NSString *)propertyName
{
    NSString * propertyAttributesString;
    unsigned propertyCount;
    
    objc_property_t *properties = class_copyPropertyList([theClassEntity class],&propertyCount);
    for(int i=0;i<propertyCount;i++){
        NSString * propNameString;
        NSString * propAttributesString;
        
        objc_property_t prop=properties[i];
        
        const char *propName = property_getName(prop);
        propNameString =[NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        
        if (![propNameString isEqualToString:propertyName]) {
            continue;
        }
        const char * propAttributes=property_getAttributes(prop);
        propAttributesString =[NSString stringWithCString:propAttributes encoding:NSASCIIStringEncoding];
        // 根据各个情况处理.
        // TB:BOOL(64位)
        // Tq: NSIntger(64位)
        if ([propAttributesString hasPrefix:@"T@\"NSString\""]
            || [propAttributesString hasPrefix:@"T@\"NSMutableString\""]){
            // 字符类型
            propertyAttributesString=@"TEXT";
        }
        if ([propAttributesString hasPrefix:@"Tf"]){
            // 字符类型
            propertyAttributesString=@"Float";
        }
        if ([propAttributesString hasPrefix:@"Tc"]
            || [propAttributesString hasPrefix:@"Ti"]
            || [propAttributesString hasPrefix:@"T@\"NSNumber\""]
            || [propAttributesString hasPrefix:@"TB"]
            || [propAttributesString hasPrefix:@"Tq"]
            ){
            // int类型
            // Tc: BOOL;
            // Ti: int;
            propertyAttributesString=@"integer";
        }
        if (![propNameString isEqualToString:propertyName]) {
            break;
        }
    } // end for.
    
    free(properties);
    
    //NSLog(@"Sql = %@ \n",sql);
    
    return propertyAttributesString;
}


@end
