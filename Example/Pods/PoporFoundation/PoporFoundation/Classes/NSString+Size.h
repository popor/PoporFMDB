//
//  NSString+Size.h
//  Wanzi
//
//  Created by popor on 2016/10/20.
//  Copyright © 2016年 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
#import <UIKit/UIKit.h>

@interface NSString (Size)

- (CGSize)sizeInFont:(UIFont *)font;

- (CGSize)sizeInFont:(UIFont *)font width:(float)width;

- (CGSize)sizeAttrSpace:(CGFloat)lineSpeace withFont:(UIFont*)font withWidth:(CGFloat)width;
@end


#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>

@interface NSString (Size)

- (CGSize)sizeInFont:(NSFont *)font;

- (CGSize)sizeInFont:(NSFont *)font width:(float)width;

- (CGSize)sizeAttrSpace:(CGFloat)lineSpeace withFont:(NSFont*)font withWidth:(CGFloat)width;


@end


#endif




