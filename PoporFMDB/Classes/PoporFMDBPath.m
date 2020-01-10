//
//  PoporFMDBPath.m
//  FMDB-iOS
//
//  Created by apple on 2020/1/10.
//

#import "PoporFMDBPath.h"

@implementation PoporFMDBPath

+ (instancetype)share {
    static dispatch_once_t once;
    static PoporFMDBPath * instance;
    dispatch_once(&once, ^{
        instance = [self new];
        [instance initPath];
    });
    return instance;
}

- (void)initPath {
    self.DBFileName = DBFileNameDefault;
    
    NSArray * pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    self.projectPath = [pathsToDocuments objectAtIndex:0];
    // UI系列
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    self.cachesPath  = [self.projectPath stringByReplacingOccurrencesOfString:@"/Documents" withString:@"/Library/Caches"];
    
    // NS系列
#elif TARGET_OS_MAC
    NSRange range = [self.projectPath rangeOfString:@"/Library/Containers"];
    if (range.location == NSIntegerMax) {
        NSLog(@"PoporFMDB ⚠️ you did not open App sandbox, will use a default db path.");
        self.projectPath = [NSString stringWithFormat:@"%@/%@/Data/Library/Caches", self.projectPath, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    }
    
    self.cachesPath  = self.projectPath;
    
#endif
    
    self.DBPath = [NSString stringWithFormat:@"%@/%@", self.cachesPath, self.DBFileName];
    
    NSLog(@"PoporFMDB cachesPath: %@", self.cachesPath);
    NSLog(@"PoporFMDB mainDBPath: %@", self.DBPath);
}

@end
