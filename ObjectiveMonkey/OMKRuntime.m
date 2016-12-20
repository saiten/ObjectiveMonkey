//
//  OMKRuntime.m
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import "OMKRuntime.h"
#import "ObjectiveMonkey.h"
#import "OMKObjcBox.h"

@protocol OMKRuntimeJSExports <JSExport>

- (NSString *)getAppVersion;

- (void)consoleLog:(JSValue *)value;

JSExportAs(addPatch,
           - (void)addPatchWithClassName:(NSString *)className method:(NSString *)method patch:(JSValue *)patchFunction
           );

JSExportAs(NSClassFromString,
           - (OMKObjcBox<Class> *)classForjsString:(JSValue *)className
           );

JSExportAs(createNSString,
           - (OMKObjcBox<NSString *> *)nsStringFromjsString:(JSValue *)jsString
           );

JSExportAs(createNSNumber,
           - (OMKObjcBox<NSNumber *> *)nsNumberFromjsNumber:(JSValue *)jsNumber
           );

- (id)createNil;

@end

@interface OMKRuntime() <OMKRuntimeJSExports>
@end

@implementation OMKRuntime

- (NSString *)getAppVersion
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (void)consoleLog:(JSValue *)value
{
    NSLog(@"%@", value);
}

- (void)addPatchWithClassName:(NSString *)className method:(NSString *)method patch:(JSValue *)patchFunction
{
    Class klass = NSClassFromString(className);
    SEL selector = NSSelectorFromString(method);
    [[ObjectiveMonkey defaultMonkey] addPatchForClass:klass selector:selector patch:patchFunction];
}

- (OMKObjcBox<Class> *)classForjsString:(JSValue *)className
{
    NSString *str = [className toString];
    Class klass = NSClassFromString(str);
    return [OMKObjcBox boxWithObject:klass];
}

-(OMKObjcBox<NSString *> *)nsStringFromjsString:(JSValue *)jsString
{
    return [OMKObjcBox boxWithObject:[jsString toString]];
}

-(OMKObjcBox<NSNumber *> *)nsNumberFromjsNumber:(JSValue *)jsNumber
{
    return [OMKObjcBox boxWithObject:[jsNumber toNumber]];
}

- (id)createNil
{
    return [OMKObjcBox boxWithObject:nil];
}

@end
