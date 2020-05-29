//
//  PoporFMDBViewController.m
//  PoporFMDB
//
//  Created by wangkq on 07/03/2018.
//  Copyright (c) 2018 wangkq. All rights reserved.
//

#import "PoporFMDBViewController.h"

#import <PoporFMDB/PoporFMDB.h>
#import "TestEntity.h"

@interface PoporFMDBViewController ()

@end

@implementation PoporFMDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [PoporFMDBPath share];// 可以修改路径
    
    [PoporFMDB share];
    [PoporFMDB injectTableArray:@[[TestEntity class]]];
    // 1. add
    //    {
    //        TestEntity * entity = [TestEntity new];
    //        entity.t2       = 3;
    //
    //        entity.title    = [NSString stringWithFormat:@"title %i", entity.t2];
    //        entity.subtitle = [NSString stringWithFormat:@"subtitle %i", entity.t2];
    //        entity.content  = [NSString stringWithFormat:@"title %i", entity.t2];
    //        entity.t1       = [NSString stringWithFormat:@"t1 %i", entity.t2];
    //
    //        [PDB addEntity:entity];
    //    }
    
    // 2. read
    //    {
    //        NSMutableArray * array = [PDB arrayClass:[TestEntity class]];
    //
    //        NSLog(@"array: %@", array.description);
    //    }
    
    // 3.delete
    {
        [PDB deleteClass:[TestEntity class] where:@"t2" equal:@(2)];
    }
    
    [self testMPn:@"1", @"2", @"3" ];
}

/**
 https://www.cnblogs.com/AirStark/p/8024986.html
 只能创建一组可变参数,不能是多组.
 
 */
- (void)testMPn:(NSString *)name,... {
    
    // 定义va_list变量(指针)
    va_list arg_list;
    
    if (name) {
        NSLog(@"%@", name);
        // 把arg_list指向name这个可变形参的第一个位置
        va_start(arg_list, name);
        
        // 提取一个参数, 返回一个NSString*, 并将指针后移
        NSString *temp_arg = va_arg(arg_list, id);
        while (temp_arg) {
            NSLog(@"%@", temp_arg);
            // 继续后移, 遇到nil跳出循环
            temp_arg = va_arg(arg_list, id);
        }
        
        va_end(arg_list);
    }

}

@end
