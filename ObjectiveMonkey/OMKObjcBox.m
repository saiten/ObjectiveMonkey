//
//  OMKObjcBox.m
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import "ObjectiveMonkey.h"
#import "OMKObjcBox.h"
#import "NSInvocation+ObjectiveMonkey.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation OMKObjcBox

#pragma mark - initializers

- (instancetype)initWithObject:(id)object
{
    return [self initWithObject:object context:[JSContext currentContext] ? : [JSContext new]];
}

- (instancetype)initWithObject:(id)object context:(JSContext *)context;
{
    if (self = [super init]) {
        _object = object;
        _context = context;
    }
    return self;
}

+ (instancetype)boxWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

+ (instancetype)boxWithObject:(id)object context:(JSContext *)context
{
    return [[self alloc] initWithObject:object context:context];
}

#pragma mark - exports methods

- (JSValue *)call:(NSString *)method
{
    return [self _callWithMethod:method isSuper:NO];
}

- (JSValue *)callSuper:(NSString *)method
{
    return [self _callWithMethod:method isSuper:YES];
}

- (JSValue *)originalImplementation
{
    if(self.originalImplementationSelector) {
        return [self _call:self.originalImplementationSelector isSuper:NO isOriginal:YES];
    } else {
        return nil;
    }
}

- (JSValue *)jsString
{
    if(self.isNSString) {
        return [JSValue valueWithObject:self.object inContext:self.context];
    } else {
        return [JSValue valueWithObject:[self.object description] inContext:self.context];
    }
}

- (JSValue *)jsNumber
{
    if(self.isNSNumber) {
        NSNumber *num = self.object;
        char type = [num objCType][0];
        
        if(type == 'c') {
            return [JSValue valueWithInt32:[num charValue] inContext:self.context];
        }
        else if(type == 'i') {
            return [JSValue valueWithInt32:[num intValue] inContext:self.context];
        }
        else if(type == 's') {
            return [JSValue valueWithInt32:[num shortValue] inContext:self.context];
        }
        else if(type == 'l') {
            return [JSValue valueWithInt32:(int)[num longValue] inContext:self.context];
        }
        else if(type == 'q') {
            return [JSValue valueWithInt32:(int)[num longLongValue] inContext:self.context];
        }
        else if(type == 'C') {
            return [JSValue valueWithUInt32:[num unsignedCharValue] inContext:self.context];
        }
        else if(type == 'I') {
            return [JSValue valueWithUInt32:[num unsignedIntValue] inContext:self.context];
        }
        else if(type == 'S') {
            return [JSValue valueWithUInt32:[num unsignedShortValue] inContext:self.context];
        }
        else if(type == 'L') {
            return [JSValue valueWithUInt32:(unsigned int)[num unsignedLongValue] inContext:self.context];
        }
        else if(type == 'Q') {
            return [JSValue valueWithUInt32:(unsigned int)[num unsignedLongLongValue] inContext:self.context];
        }
        else if(type == 'f') {
            return [JSValue valueWithDouble:[num floatValue] inContext:self.context];
        }
        else if(type == 'd') {
            return [JSValue valueWithDouble:[num doubleValue] inContext:self.context];
        }
        else if(type == 'B') {
            return [JSValue valueWithBool:[num boolValue] inContext:self.context];
        }
    }
    return nil;
}

- (JSValue *)jsBoolean
{
    if(self.isNSNumber) {
        return [JSValue valueWithBool:[self.object boolValue] inContext:self.context];
    } else {
        return [JSValue valueWithBool:false inContext:self.context];
    }
}

- (JSValue *)isNSString
{
    return [JSValue valueWithBool:[self.object isKindOfClass:[NSString class]] inContext:self.context];
}

- (JSValue *)isNSNumber
{
    return [JSValue valueWithBool:[self.object isKindOfClass:[NSNumber class]] inContext:self.context];
}

- (JSValue *)isNil
{
    return [JSValue valueWithBool:self.object == nil inContext:self.context];
}

- (JSValue *)isNSNull
{
    return [JSValue valueWithBool:[self.object isKindOfClass:[NSNull class]] inContext:self.context];
}

#pragma mark - private methods

- (JSValue *)_callWithMethod:(NSString *)method isSuper:(BOOL)isSuper
{
    SEL selector = NSSelectorFromString(method);
    return [self _call:selector isSuper:isSuper isOriginal:false];
}

- (JSValue *)_call:(SEL)selector isSuper:(BOOL)isSuper isOriginal:(BOOL)isOriginal
{
    NSArray<JSValue *> *args = [JSContext currentArguments];
    
    Class klass = object_getClass(self.object);
    if(isSuper) {
        klass = class_getSuperclass(klass);
    }
    
    BOOL isClassObject = class_isMetaClass(klass);
    if([self.object respondsToSelector:selector]) {
        Method method = isClassObject ? class_getClassMethod(klass, selector)
                                      : class_getInstanceMethod(klass, selector);
        
        const char *typeEncoding = method_getTypeEncoding(method);
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        invocation.target = self.object;
        invocation.selector = selector;
        
        int offset = 2;
        for(int index = offset; index < signature.numberOfArguments; index++) {
            int argIndex = index - offset + (isOriginal ? 0 : 1);
            if(argIndex >= args.count) {
                break;
            }
            [invocation omk_setArgumentJSValue:args[argIndex] atIndex:index];
        }
        
        [invocation retainArguments];
        
        if(isSuper) {
            Class originalClass = [self.object class];
            object_setClass(self.object, klass);
            [invocation invoke];
            object_setClass(self.object, originalClass);
        } else {
            [invocation invoke];
        }
        return [invocation omk_returnJSValueInContext:self.context];
    } else {
        NSLog(@"missing selector");
    }
    
    return nil;
}

@end
