//
//  NSFMDB.m
//  villas
//
//  Created by popor on 14-3-27.
//  Copyright (c) 2014年 Crystal Digital Technology Co.,LTD (Shanghai). All rights reserved.
//

#import "NSFMDB.h"
#import <objc/runtime.h>
#import <PoporFoundation/NSString+Tool.h>

@implementation NSFMDB

/*
 S:Statement
 只支持全额属性集
 */
+ (NSString *)getCreateSQLS:(id)theClassEntity with:(NSString *)theTableName
{
    NSMutableString * tempSQLS=[[NSMutableString alloc] init];
    [tempSQLS appendString:@"CREATE TABLE "];// 开头
    [tempSQLS appendString:theTableName];    // tableName// truncate
    //NSLog(@"theTableName: %@", theTableName);
    [tempSQLS appendString:@"(id INTEGER PRIMARY KEY AUTOINCREMENT "];// 自增ID
    
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
        // 根据各个情况处理.
        if ([propAttributesString hasPrefix:@"T@\"NSString\""]
            || [propAttributesString hasPrefix:@"T@\"NSMutableString\""]){
            // 字符类型
            [tempSQLS appendString:[NSString stringWithFormat:@", %@ TEXT",propNameString]];
        }
        if ([propAttributesString hasPrefix:@"Tf"]){
            // 字符类型
            [tempSQLS appendString:[NSString stringWithFormat:@", %@ Float",propNameString]];
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
            [tempSQLS appendString:[NSString stringWithFormat:@", %@ integer",propNameString]];
        }
    } // end for.
    
    [tempSQLS appendString:@")"];// 结尾.
    NSString * sql=[NSString stringWithFormat:@"%@", tempSQLS];
    tempSQLS=nil;
    
    free(properties);
    
    //NSLog(@"Sql = %@ \n",sql);
    
    return sql;
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
            valueString=[NSString stringWithFormat:@"%@",value];
            valueString=[NSString replaceString:valueString withREG:@"'" withNewString:@"''"];
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
    NSString * sql=[NSString stringWithFormat:@"%@",tempSQLS];
    tempSQLS=nil;
    parameterIDs=nil;
    parameterValues=nil;
    free(properties);
    return sql;
}

+ (NSString *)getInsertEmojSQLS:(id)theClassEntity 	with:(NSString *)theTableName{
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
            valueString=[NSString stringWithFormat:@"%@",value];
            valueString=[NSString replaceString:valueString withREG:@"'" withNewString:@"''"];
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
    NSString * sql=[NSString stringWithFormat:@"%@",tempSQLS];
    tempSQLS=nil;
    parameterIDs=nil;
    parameterValues=nil;
    free(properties);
    return sql;
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
