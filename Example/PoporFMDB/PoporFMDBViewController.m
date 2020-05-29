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
    
    [self addBTs];
}

- (void)addBTs {
    NSArray * titleArray = @[@"Add", @"Read", @"Delete", @"Update"];
    for (int i=0; i<titleArray.count; i++) {
        UIButton * oneBT = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame =  CGRectMake(100, 60 + 50*i, 80, 44);
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            
            [button setBackgroundColor:[UIColor brownColor]];
            
             button.titleLabel.font = [UIFont systemFontOfSize:22];
            button.layer.cornerRadius = 5;
            button.layer.borderColor = [UIColor lightGrayColor].CGColor;
            button.layer.borderWidth = 1;
            button.clipsToBounds = YES;
            
            [self.view addSubview:button];
            
            [button addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
            
            button;
        });
        oneBT.tag = i;
    }
}

- (void)btAction:(UIButton *)bt {
    switch (bt.tag) {
        case 0: {
            [self add];
            break;
        }
        case 1: {
            [self read];
            break;
        }
        case 2: {
            [self delete];
            break;
        }
        case 3: {
            [self update];
            break;
        }
        default:
            break;
    }
}

- (void)add {// 1. add
    TestEntity * entity = [TestEntity new];
    entity.t2       = 2;
    
    entity.title    = [NSString stringWithFormat:@"title %i", entity.t2];
    entity.subtitle = [NSString stringWithFormat:@"subtitle %i", entity.t2];
    entity.content  = [NSString stringWithFormat:@"title %i", entity.t2];
    entity.t1       = [NSString stringWithFormat:@"t1 %i", entity.t2];
    
    [PDB addEntity:entity];
}

- (void)read {
    NSMutableArray * array = [PDB arrayClass:[TestEntity class]];
    
    NSLog(@"array: %@", array.description);
    
}

- (void)delete {
    [PDB deleteClass:[TestEntity class] where:@"t2" equal:@(2)];
}

- (void)update {
    //NSArray * array = [PDB arrayClass:[TestEntity class] where:@"t2" like:@(2)];
    NSArray * array = [PDB arrayClass:[TestEntity class] where:@"t2" equal:@(2)];
    TestEntity * entity = array.firstObject;
    
    // 直接修改多个参数
    [PDB updateEntity:entity keyS:@[@"title", @"subtitle"] equalS:@[@"wkqT", @"wkqST"] whereS:@[@"t2"]];
    
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
