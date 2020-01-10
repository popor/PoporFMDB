//
//  VCDao.m
//  Course
//
//  Created by popor on 12-6-7.
//  Copyright (c) 2012年 popor. All rights reserved.
//

#import "PoporFMDBBase.h"
#import "NSFMDB.h"
#import "FMDatabase.h"

#import "AppInfoEntity.h"

@interface PoporFMDBBase ()

@end

@implementation PoporFMDBBase

- (id)init {
    if (self = [super init]) {
        
        [self checkDBFile];
    }
    return self;
}

- (void)checkDBFile {
    PoporFMDBPath * path = [PoporFMDBPath share];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path.cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.db = [FMDatabase databaseWithPath:path.DBPath];
    if (![self.db open]) {
        NSLog(@"PoporFMDB Could not open db.");
    }else {
        NSLog(@"PoporFMDB Could open db.");
    }
}

/*
 #pragma mark - 示例 开始
 - (void)insertVCData
 {
 [self.db beginTransaction];
 NSMutableArray * dba=[[NSMutableArray alloc]init];
 
 // 首页,第一章
 [dba addObject:[[ViewUnit alloc] initDepart:1 chapter:1 section:1 page:1 viewName:@"" bgName:@"s0.png"
 xmlName:@"" Title:@"封面"  SubTitle:@"" position:departmentNormal isInTV:inTableView]];
 // over
 // ----------------------------
 for (int i=0; i<[dba count]; i++) {
 ViewUnit * viewUnit=[dba objectAtIndex:i];
 viewUnit.currentIndex=-1;
 [self.db executeUpdate:[NSFMDB getInsertSQLS:viewUnit with:tableName]];
 }
 [self.db commit];
 // end.
 }
 
 #pragma mark [noteBook department]
 - (void)addNoteBookUnit:(NoteBookUnit *)theNoteBookUnit
 {
 BOOL hasRecord=NO;
 FMResultSet *rs;
 NSString * futureSQL=@"SELECT * FROM "noteBookTableName" WHERE recordUUID=?;";
 rs=[self.db executeQuery:futureSQL, theNoteBookUnit.recordUUID];
 while ([rs next]) {
 hasRecord=YES;
 [self.db executeUpdate:@"UPDATE "noteBookTableName" set recordText=? , recordTitle=? where recordUUID=?;"
 , theNoteBookUnit.recordText
 , theNoteBookUnit.recordTitle
 , theNoteBookUnit.recordUUID
 ];
 }
 if (!hasRecord) {
 [self.db executeUpdate:[NSFMDB getInsertSQLS:theNoteBookUnit with:noteBookTableName]];
 }
 // end.
 }
 
 - (void)removeNoteBookUnit:(NoteBookUnit *)theNoteBookUnit
 {
 NSString * futureSQL=@"delete FROM "noteBookTableName" WHERE recordUUID=?;";
 [self.db beginTransaction];
 [self.db executeUpdate:futureSQL, theNoteBookUnit.recordUUID];
 [self.db commit];
 // end.
 }
 
 
 - (void)setAllNotePadArray:(NSMutableArray *)theTargetArray
 {
 FMResultSet *rs;
 NSString * futureSQL=@"SELECT * FROM "noteBookTableName" WHERE id>0;";
 rs=[self.db executeQuery:futureSQL];
 while ([rs next]) {
 NoteBookUnit * noteBookUnit=[[NoteBookUnit alloc] init];
 [NSFMDB setFullEntity:noteBookUnit withRS:rs];
 [theTargetArray addObject:noteBookUnit];
 }
 }
 
 
 - (void)setNoteBookArray:(NSMutableArray *)theTargetArray
 with:(int)thePageIndex
 {
 FMResultSet *rs;
 NSString * futureSQL=@"SELECT * FROM "noteBookTableName" WHERE pageIndex=?;";
 rs=[self.db executeQuery:futureSQL, [NSNumber numberWithInt:thePageIndex]];
 //,[NSString stringWithFormat:@"%i",thePageIndex]];
 while ([rs next]) {
 NoteBookUnit * noteBookUnit=[[NoteBookUnit alloc] init];
 [NSFMDB setFullEntity:noteBookUnit withRS:rs];
 [theTargetArray addObject:noteBookUnit];
 }
 
 // end.
 }
 
 #pragma mark 示例 结束
 //*/
- (void)start {
    [self.db beginTransaction];
}

- (void)executeUpdate:(NSString*)sql, ... {
    va_list args;
    va_start(args, sql);
    NSLog(@"PoporFMDB sql : %i- %@", [self.db executeUpdate:sql, args], sql);
    va_end(args);
}

- (FMResultSet *)executeQuery:(NSString*)sql, ... {
    va_list args;
    va_start(args, sql);
    id result = [self.db executeQuery:sql, args];
    va_end(args);
    return result;
}

- (void)end; {
    [self.db commit];
}

#pragma mark - 更新DB结构--------------------------------------------------------
- (void)updateDBStruct {
    {
        // app 插入新的tableview
        NSMutableDictionary * dbClassDic  = [self.classDic mutableCopy];
        NSMutableArray * dbTableNameArray = [self getDBTableNameArray];
        
        for (NSString * oneTableName in dbTableNameArray) {
            //NSLog(@"TableName: %@", oneTableName);
            [dbClassDic removeObjectForKey:oneTableName];
            //NSLog(@"TableName: %@", oneTableName);
        }
        
        [self.db beginTransaction];
        for(NSString * key in dbClassDic.allKeys) {
            Class class = dbClassDic[key];
            [self.db executeUpdate:[NSFMDB getCreateSQLS:[class new] with:key]];
        }
        
        [self.db commit];
    }
    {
        // app 更新tableview的colume
        for(NSString * key in self.classDic.allKeys) {
            [self updateTabel:key class:self.classDic[key]];
        }
    }
}

// 获取之前的TableArray
- (NSMutableArray *)getDBTableNameArray {
    NSMutableArray * array = [[NSMutableArray alloc]  init];
    [self.db beginTransaction];
    FMResultSet *rs;
    NSString * futureSQL=@"SELECT * FROM sqlite_master;";
    rs=[self.db executeQuery:futureSQL];
    while ([rs next]) {
        DBTableName * oneEntity = [[DBTableName alloc] init];
        [NSFMDB setFullEntity:oneEntity withRS:rs];
        [array addObject:oneEntity.name];
    }
    [self.db commit];
    return array;
}

- (void)updateTabel:(NSString *)table class:(Class)DBClass {
    //Class DBClass= NSClassFromString(ClassName);
    id oneDBEntity=[[DBClass alloc] init];
    NSMutableDictionary * dbEntityPropertyDic=[NSFMDB getPropertyArray:oneDBEntity];
    
    //NSLog(@"检查table: %@", table);
    [self.db beginTransaction];
    FMResultSet *rs;
    NSString * futureSQL=[NSString stringWithFormat:@"SELECT * FROM %@", table];
    rs=[self.db executeQuery:futureSQL];
    NSString * propNameString;
    NSString * attributesString;
    for (int i=0;i<rs.columnCount;i++){
        propNameString=[rs columnNameForIndex:i];
        NSString * beforeVaule=[dbEntityPropertyDic objectForKey:propNameString];
        
        if (beforeVaule) {
            //NSLog(@"之前拥有: %@", propNameString);
            [dbEntityPropertyDic removeObjectForKey:propNameString];
        }else{
            //NSLog(@"需要新增: %@", propNameString);
            [dbEntityPropertyDic setObject:NeedDrop forKey:propNameString];
        }
    }
    for(NSString * propNameString in dbEntityPropertyDic.allKeys)
    {
        if ([propNameString isEqualToString:@"id"]) {
            continue;
        }
        attributesString=[NSFMDB getPropertyAttributesString:oneDBEntity with:propNameString];
        NSString * beforeVaule=[dbEntityPropertyDic objectForKey:propNameString];
        if ([beforeVaule isEqualToString:NeedDrop]) {
            //NSLog(@"需要删除:%@,但是sqlite不支持.", propNameString);
            /// // //[self dropTable:table column:propNameString];
        }else if([beforeVaule isEqualToString:NeedAdd]) {
            //NSLog(@"需要新增:%@", propNameString);
            [self addTable:table column:propNameString attributes:attributesString];
        }
    }
    [self.db commit];
}

- (void)addTable:(NSString *)table column:(NSString *)colume attributes:(NSString *)attributes {
    if (attributes==nil) {
        //NSLog(@"无法新增++++++++++: table:%@, colume:%@", table, colume);
        return;
    }
    NSString * futureSQL=[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", table, colume, attributes];
    [self.db executeUpdate:futureSQL];
}

- (void)dropTable:(NSString *)table column:(NSString *)colume {
    return;
    //NSString * futureSQL=[NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@", table, colume];
    //[self.db executeUpdate:futureSQL];
}


@end
