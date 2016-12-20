//
//  NSInvocation+ObjectiveMonkey.m
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import "NSInvocation+ObjectiveMonkey.h"
#import "OMKObjcBox.h"

@implementation NSInvocation (ObjectiveMonkey)

+ (NSInvocation *)omk_invocationWithTarget:(id)target selector:(SEL)selector arguments:(va_list)arguments
{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    
    char *args = (char *)arguments;
    for(int index = 2; index < signature.numberOfArguments; index++) {
        const char *argumentType = [signature getArgumentTypeAtIndex:index];
        
        NSUInteger size, align = 4;
        NSGetSizeAndAlignment(argumentType, &size, &align);
        NSUInteger mod = (NSUInteger)args % align;
        
        if (mod != 0) {
            args += (align - mod);
        }
        if(argumentType[0] == 'f') {
            float f = *(float *)args;
            [invocation setArgument:&f atIndex:index];
            args += sizeof(double);
        } else {
            [invocation setArgument:args atIndex:index];
            args += size;
        }
    }
    [invocation retainArguments];
    
    return invocation;
}

- (void)omk_setArgumentJSValue:(JSValue *)value atIndex:(NSUInteger)index
{
    char type = [self.methodSignature getArgumentTypeAtIndex:index][0];
    
    if(type == 'c') {
        char c = [[value toNumber] charValue];
        [self setArgument:&c atIndex:index];
    }
    else if(type == 'i') {
        int i = [[value toNumber] intValue];
        [self setArgument:&i atIndex:index];
    }
    else if(type == 's') {
        short s = [[value toNumber] shortValue];
        [self setArgument:&s atIndex:index];
    }
    else if(type == 'l') {
        long l = [[value toNumber] longValue];
        [self setArgument:&l atIndex:index];
    }
    else if(type == 'q') {
        long long ll = [[value toNumber] longLongValue];
        [self setArgument:&ll atIndex:index];
    }
    else if(type == 'C') {
        unsigned char uc = [[value toNumber] unsignedCharValue];
        [self setArgument:&uc atIndex:index];
    }
    else if(type == 'I') {
        unsigned int ui = [[value toNumber] unsignedIntValue];
        [self setArgument:&ui atIndex:index];
    }
    else if(type == 'S') {
        unsigned short us = [[value toNumber] unsignedShortValue];
        [self setArgument:&us atIndex:index];
    }
    else if(type == 'L') {
        unsigned long ul = [[value toNumber] unsignedLongValue];
        [self setArgument:&ul atIndex:index];
    }
    else if(type == 'Q') {
        long long ull = [[value toNumber] unsignedLongLongValue];
        [self setArgument:&ull atIndex:index];
    }
    else if(type == 'f') {
        float f = [[value toNumber] floatValue];
        [self setArgument:&f atIndex:index];
    }
    else if(type == 'd') {
        double d = [[value toNumber] doubleValue];
        [self setArgument:&d atIndex:index];
    }
    else if(type == 'B') {
        bool b = [value toBool];
        [self setArgument:&b atIndex:index];
    }
    else if(type == '#' ) {
        id obj = [value toObject];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            OMKObjcBox *box = (OMKObjcBox *)obj;
            id object = box.object;
            [self setArgument:&object atIndex:index];
        } else {
            [self setArgument:&obj atIndex:index];
        }
    }
    else if(type == ':') {
        id obj = [value toObject];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            OMKObjcBox *box = (OMKObjcBox *)obj;
            SEL selector = NSSelectorFromString(box.object);
            [self setArgument:&selector atIndex:index];
        } else {
            NSString *selectorName = [value toString];
            SEL selector = NSSelectorFromString(selectorName);
            [self setArgument:&selector atIndex:index];
        }
    }
    else if(type == '@') {
        id obj = [value toObject];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            OMKObjcBox *box = (OMKObjcBox *)obj;
            id object = box.object;
            [self setArgument:&object atIndex:index];
        } else {
            [self setArgument:&obj atIndex:index];
        }
    }
    else if(type == '^') {
        NSLog(@"pointer not supported yet");
    }
    else if(type == '[') {
        NSLog(@"array not supported yet");
    }
    else if(type == '{') {
        NSLog(@"struct not supported yet");
    }
    else if(type == '(') {
        NSLog(@"union not supported yet");
    }
}

- (JSValue *)omk_returnJSValueInContext:(JSContext *)context
{
    char type = [self.methodSignature methodReturnType][0];
    if(type == 'c') {
        char c;
        [self getReturnValue:&c];
        return [JSValue valueWithInt32:c inContext:context];
    }
    else if(type == 'i') {
        int i;
        [self getReturnValue:&i];
        return [JSValue valueWithInt32:i inContext:context];
    }
    else if(type == 's') {
        short s;
        [self getReturnValue:&s];
        return [JSValue valueWithInt32:s inContext:context];
    }
    else if(type == 'l') {
        long l;
        [self getReturnValue:&l];
        return [JSValue valueWithInt32:(int)l inContext:context];
    }
    else if(type == 'q') {
        long long ll;
        [self getReturnValue:&ll];
        return [JSValue valueWithInt32:(int)ll inContext:context];
    }
    else if(type == 'C') {
        unsigned char uc;
        [self getReturnValue:&uc];
        return [JSValue valueWithUInt32:uc inContext:context];
    }
    else if(type == 'I') {
        unsigned int ui;
        [self getReturnValue:&ui];
        return [JSValue valueWithUInt32:ui inContext:context];
    }
    else if(type == 'S') {
        unsigned short us;
        [self getReturnValue:&us];
        return [JSValue valueWithUInt32:us inContext:context];
    }
    else if(type == 'L') {
        unsigned long ul;
        [self getReturnValue:&ul];
        return [JSValue valueWithUInt32:(unsigned int)ul inContext:context];
    }
    else if(type == 'Q') {
        unsigned long long ull;
        [self getReturnValue:&ull];
        return [JSValue valueWithUInt32:(unsigned int)ull inContext:context];
    }
    else if(type == 'f') {
        float f;
        [self getReturnValue:&f];
        return [JSValue valueWithDouble:f inContext:context];
    }
    else if(type == 'd') {
        double d;
        [self getReturnValue:&d];
        return [JSValue valueWithDouble:d inContext:context];
    }
    else if(type == 'd') {
        bool b;
        [self getReturnValue:&b];
        return [JSValue valueWithBool:b inContext:context];
    }
    else if(type == '#') {
        __unsafe_unretained Class klass;
        [self getReturnValue:&klass];
        OMKObjcBox *box = [OMKObjcBox boxWithObject:klass context:context];
        return [JSValue valueWithObject:box inContext:context];
    }
    else if(type == ':') {
        SEL selector;
        [self getReturnValue:&selector];
        NSString *selectorName = NSStringFromSelector(selector);
        OMKObjcBox *box = [OMKObjcBox boxWithObject:selectorName context:context];
        return [JSValue valueWithObject:box inContext:context];
    }
    else if(type == '@') {
        __unsafe_unretained id obj;
        [self getReturnValue:&obj];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            return [JSValue valueWithObject:obj inContext:context];
        } else {
            OMKObjcBox *box = [OMKObjcBox boxWithObject:obj context:context];
            return [JSValue valueWithObject:box inContext:context];
        }
    }
    else if(type == 'v') {
        return nil;
    }
    NSLog(@"unsupported return value type");
    return nil;
}

@end
