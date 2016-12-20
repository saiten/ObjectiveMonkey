//
//  NSMethodSignature+ObjectiveMonkey.m
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import "NSMethodSignature+ObjectiveMonkey.h"

@implementation NSMethodSignature (ObjectiveMonkey)

// from : https://github.com/jspahrsummers/libextobjc/blob/master/extobjc/NSMethodSignature%2BEXT.m#L62

- (const char *)omk_typeEncoding
{
    NSUInteger argumentCount = [self numberOfArguments];
    
    size_t stringLength = strlen([self methodReturnType]);
    for (NSUInteger i = 0;i < argumentCount;++i) {
        const char *argType = [self getArgumentTypeAtIndex:i];
        stringLength += strlen(argType);
    }
    
    stringLength++;
    
    char *encoding = calloc(stringLength, 1);
    strlcpy(encoding, [self methodReturnType], stringLength);
    
    for (NSUInteger i = 0;i < argumentCount;++i) {
        const char *argType = [self getArgumentTypeAtIndex:i];
        
        size_t currentLength = strlen(encoding);
        strlcpy(encoding + currentLength, argType, stringLength - currentLength);
    }
    
    // create an unused NSData object to autorelease the allocated string
    [NSData dataWithBytesNoCopy:encoding length:stringLength + 1 freeWhenDone:YES];
    
    return encoding;
}

@end
