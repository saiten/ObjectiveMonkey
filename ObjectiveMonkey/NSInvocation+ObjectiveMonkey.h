//
//  NSInvocation+ObjectiveMonkey.h
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavascriptCore/JavascriptCore.h>

@interface NSInvocation (ObjectiveMonkey)

+ (NSInvocation *)omk_invocationWithTarget:(id)target selector:(SEL)selector arguments:(va_list)arguments;
- (void)omk_setArgumentJSValue:(JSValue *)value atIndex:(NSUInteger)index;
- (JSValue *)omk_returnJSValueInContext:(JSContext *)context;

@end
