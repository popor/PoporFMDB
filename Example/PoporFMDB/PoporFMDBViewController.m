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
}


@end
