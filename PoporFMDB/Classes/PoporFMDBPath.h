//
//  PoporFMDBPath.h
//  FMDB-iOS
//
//  Created by apple on 2020/1/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define DBFileNameDefault @"AppDB.db"

@interface PoporFMDBPath : NSObject

+ (instancetype)share;

@property (nonatomic, strong) NSString   * DBFileName;

@property (nonatomic, strong) NSString   * DBPath;
@property (nonatomic, strong) NSString   * cachesPath;
@property (nonatomic, strong) NSString   * projectPath;

@end

NS_ASSUME_NONNULL_END
