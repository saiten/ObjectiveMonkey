//
//  JSValue+ObjectiveMonkey.m
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import "JSValue+ObjectiveMonkey.h"
#import "OMKObjcBox.h"

@implementation JSValue (ObjectiveMonkey)

- (void *)omk_encodeValueWithEncodeType:(const char *)encodeType
{
    char type = encodeType[0];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wint-conversion"
    if(type == 'c') {
        return [[self toNumber] charValue];
    }
    else if(type == 'i') {
        return [[self toNumber] intValue];
    }
    else if(type == 's') {
        return [[self toNumber] shortValue];
    }
    else if(type == 'l') {
        return [[self toNumber] longValue];
    }
    else if(type == 'q') {
        return [[self toNumber] longLongValue];
    }
    else if(type == 'C') {
        return [[self toNumber] unsignedCharValue];
    }
    else if(type == 'I') {
        return [[self toNumber] unsignedIntValue];
    }
    else if(type == 'S') {
        return [[self toNumber] unsignedShortValue];
    }
    else if(type == 'L') {
        return [[self toNumber] unsignedLongValue];
    }
    else if(type == 'Q') {
        return [[self toNumber] unsignedLongLongValue];
    }
    else if(type == 'f') {
        union {
            float f;
            unsigned char buf[sizeof(float)];
        } u;
        u.f = [[self toNumber] floatValue];
        return u.buf;
    }
    else if(type == 'd') {
        union {
            double d;
            unsigned char buf[sizeof(double)];
        } u;
        u.d = [[self toNumber] doubleValue];
        return u.buf;
    }
    else if(type == 'B') {
        return [self toBool];
    }
    else if(type == '#' ) {
        id obj = [self toObject];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            OMKObjcBox *box = (OMKObjcBox *)obj;
            return (__bridge void *)box.object;
        } else {
            return (__bridge void *)obj;
        }
    }
    else if(type == ':') {
        id obj = [self toObject];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            OMKObjcBox *box = (OMKObjcBox *)obj;
            SEL selector = NSSelectorFromString(box.object);
            return selector;
        } else {
            NSString *selectorName = [self toString];
            SEL selector = NSSelectorFromString(selectorName);
            return selector;
        }
    }
    else if(type == '@') {
        id obj = [self toObject];
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            OMKObjcBox *box = (OMKObjcBox *)obj;
            return (__bridge void *)box.object;
        } else {
            return (__bridge void *)obj;
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
#pragma clang diagnostic pop
    return nil;
}

+ (JSValue *)omk_valueWithArguments:(va_list)arguments
                       argumentType:(const char *)argumentType
                          inContext:(JSContext *)context
{
    char type = argumentType[0];
    if(type == 'c') {
        char c = va_arg(arguments, int);
        return [JSValue valueWithInt32:c inContext:context];
    }
    else if(type == 'i') {
        int i = va_arg(arguments, int);
        return [JSValue valueWithInt32:i inContext:context];
    }
    else if(type == 's') {
        short s = va_arg(arguments, int);
        return [JSValue valueWithInt32:s inContext:context];
    }
    else if(type == 'l') {
        long l = va_arg(arguments, long);
        return [JSValue valueWithInt32:(int)l inContext:context];
    }
    else if(type == 'q') {
        long long q = va_arg(arguments, long long);
        return [JSValue valueWithInt32:(int)q inContext:context];
    }
    else if(type == 'C') {
        unsigned char uc = va_arg(arguments, unsigned int);
        return [JSValue valueWithUInt32:uc inContext:context];
    }
    else if(type == 'I') {
        unsigned int ui = va_arg(arguments, unsigned int);
        return [JSValue valueWithUInt32:ui inContext:context];
    }
    else if(type == 'S') {
        unsigned short us = va_arg(arguments, unsigned int);
        return [JSValue valueWithUInt32:us inContext:context];
    }
    else if(type == 'L') {
        unsigned long ul = va_arg(arguments, unsigned long);
        return [JSValue valueWithUInt32:(unsigned int)ul inContext:context];
    }
    else if(type == 'Q') {
        unsigned long long uq = va_arg(arguments, unsigned long long);
        return [JSValue valueWithUInt32:(unsigned int)uq inContext:context];
    }
    else if(type == 'f') {
        double f = va_arg(arguments, double);
        return [JSValue valueWithDouble:f inContext:context];
    }
    else if(type == 'd') {
        double d = va_arg(arguments, double);
        return [JSValue valueWithDouble:d inContext:context];
    }
    else if(type == '#') {
        __unsafe_unretained Class klass = va_arg(arguments, Class);
        OMKObjcBox *box = [OMKObjcBox boxWithObject:klass context:context];
        return [JSValue valueWithObject:box inContext:context];
    }
    else if(type == ':') {
        SEL selector = va_arg(arguments, SEL);
        NSString *selectorName = NSStringFromSelector(selector);
        OMKObjcBox *box = [OMKObjcBox boxWithObject:selectorName context:context];
        return [JSValue valueWithObject:box inContext:context];
    }
    else if(type == '@') {
        __unsafe_unretained id obj = va_arg(arguments, id);
        if([obj isKindOfClass:[OMKObjcBox class]]) {
            return [JSValue valueWithObject:obj inContext:context];
        } else {
            OMKObjcBox *box = [OMKObjcBox boxWithObject:obj context:context];
            return [JSValue valueWithObject:box inContext:context];
        }
    }
    
    return [JSValue valueWithUndefinedInContext:context];
}

@end
