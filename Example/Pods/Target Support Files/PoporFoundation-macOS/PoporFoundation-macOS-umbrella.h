#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSString+pAtt.h"
#import "NSString+pEmail.h"
#import "NSString+pIDCard.h"
#import "NSString+pMD5.h"
#import "NSString+pSize.h"
#import "NSString+pTool.h"
#import "Os+pPrefix.h"

FOUNDATION_EXPORT double PoporFoundationVersionNumber;
FOUNDATION_EXPORT const unsigned char PoporFoundationVersionString[];

