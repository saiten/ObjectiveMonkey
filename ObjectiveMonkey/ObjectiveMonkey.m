//
//  ObjectiveMonkey.m
//  ObjectiveMonkey
//
//  Copyright © 2016 saiten. All rights reserved.
//

#import "ObjectiveMonkey.h"
#import <JavascriptCore/JavascriptCore.h>
#import <objc/runtime.h>
#import "OMKObjcBox.h"
#import "OMKRuntime.h"
#import "NSInvocation+ObjectiveMonkey.h"
#import "NSMethodSignature+ObjectiveMonkey.h"
#import "JSValue+ObjectiveMonkey.h"

void *ObjectiveMonkey_PatchMethod(id self, SEL _cmd, ...);

@interface ObjectiveMonkey ()
@property (nonatomic) JSContext *context;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSMutableDictionary<NSString *, JSValue *> *patches;
@end

@implementation ObjectiveMonkey

#pragma mark - lifecycle

+ (instancetype)defaultMonkey
{
    static ObjectiveMonkey *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if(self) {
        _context = [JSContext new];
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"ObjectiveMonkey Error : %@", exception);
        };
        _patches = [NSMutableDictionary dictionary];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.URLCache = [NSURLCache sharedURLCache];
        configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        self.configuration = configuration;
    }
    return self;
}

- (void)setConfiguration:(NSURLSessionConfiguration *)configuration
{
    _configuration = configuration;
    _session = [NSURLSession sessionWithConfiguration:_configuration];
}

#pragma mark - setup patch script

- (void)patchFromURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         if(error) {
                             NSLog(@"failed setup patch : %@", error);
                         }
                         NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         [self patchFromString:script];
                     }] resume];
}

- (void)patchFromString:(NSString *)script
{
    self.context[@"$p"] = [OMKRuntime new];
    [self.context evaluateScript:script];
}

#pragma mark - patch operations

- (void)addPatchForClass:(Class)klass selector:(SEL)selector block:(id)block
{
    JSValue *patch = [JSValue valueWithObject:block inContext:self.context];
    [self addPatchForClass:klass selector:selector patch:patch];
}

- (void)addPatchForClass:(Class)klass selector:(SEL)selector patch:(JSValue *)patchFunction
{
    if(patchFunction.context != self.context) {
        return;
    }
    
    NSString *patchKey = [self patchKeyForClass:klass selector:selector];
    self.patches[patchKey] = patchFunction;
    
    Method classMethod = class_getClassMethod(klass, selector);
    Method instanceMethod = class_getInstanceMethod(klass, selector);
    if(classMethod || instanceMethod) {
        SEL patchSelector = [self patchSelectorWithSelector:selector];
        
        const char *typeEncoding = classMethod ? method_getTypeEncoding(classMethod) : method_getTypeEncoding(instanceMethod);
        if(!class_addMethod(klass, patchSelector, (IMP)ObjectiveMonkey_PatchMethod, typeEncoding)) {
            NSLog(@"failed add method");
        }
        Method patchMethod = class_getInstanceMethod(klass, patchSelector);
        
        if(classMethod) {
            method_exchangeImplementations(classMethod, patchMethod);
        } else {
            method_exchangeImplementations(instanceMethod, patchMethod);
        }
        
        NSLog(@"add patch %@.%@", NSStringFromClass(klass), NSStringFromSelector(selector));
    }
}

- (void)removePatchMethodForClass:(Class)klass selector:(SEL)selector
{
    NSString *patchKey = [self patchKeyForClass:klass selector:selector];
    JSValue *func = self.patches[patchKey];
    if(func) {
        [self.patches removeObjectForKey:patchKey];
        
        Method classMethod = class_getClassMethod(klass, selector);
        Method instanceMethod = class_getInstanceMethod(klass, selector);
        if(classMethod || instanceMethod) {
            SEL patchSelector = [self patchSelectorWithSelector:selector];
            if(classMethod) {
                Method patchMethod = class_getClassMethod(klass, patchSelector);
                method_exchangeImplementations(classMethod, patchMethod);
            } else {
                Method patchMethod = class_getInstanceMethod(klass, patchSelector);
                method_exchangeImplementations(instanceMethod, patchMethod);
            }
            
            // TODO: remove added method
            NSLog(@"removed patch %@.%@", NSStringFromClass(klass), NSStringFromSelector(selector));
        }
    }
}

- (void)removeAllPatches
{
    for(NSString *patchKey in self.patches.allKeys) {
        NSArray<NSString *> *classAndMethod = [patchKey componentsSeparatedByString:@"."];
        Class klass = NSClassFromString(classAndMethod[0]);
        SEL selector = NSSelectorFromString(classAndMethod[1]);
        [self removePatchMethodForClass:klass selector:selector];
    }
}

- (JSValue *)findPatchWithTarget:(id)target selector:(SEL)selector
{
    Class klass = [target class];
    do {
        NSString *patchKey = [self patchKeyForClass:klass selector:selector];
        JSValue *func = self.patches[patchKey];
        if(func) {
            return func;
        }
        klass = [klass superclass];
    } while(klass != nil);
    
    return nil;
}

- (void *)invokePatchWithTarget:(id)target selector:(SEL)selector arguments:(va_list)arguments
{
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    
    SEL originalSelector = [self patchSelectorWithSelector:selector];
    
    JSValue *func = [self findPatchWithTarget:target selector:selector];
    if(func) {
        OMKObjcBox *boxSelf = [OMKObjcBox boxWithObject:target context:self.context];
        
        boxSelf.originalImplementationSelector = originalSelector;
        
        NSMutableArray *args = [NSMutableArray arrayWithObject:boxSelf];
        for(int index = 2; index < signature.numberOfArguments; index++) {
            JSValue *value = [JSValue omk_valueWithArguments:arguments
                                                argumentType:[signature getArgumentTypeAtIndex:index]
                                                   inContext:self.context];
            [args addObject:value];
        }
        JSValue *retVal = [func callWithArguments:args];
        
        boxSelf.originalImplementationSelector = nil;
        
        return [retVal omk_encodeValueWithEncodeType:[signature methodReturnType]];
    } else {
        NSInvocation *invocation = [NSInvocation omk_invocationWithTarget:target
                                                                 selector:originalSelector
                                                                arguments:arguments];
        [invocation invoke];
        NSUInteger size = [signature methodReturnLength];
        char buf[size];
        [invocation getReturnValue:buf];
        return buf;
    }
}

#pragma mark - utils

- (BOOL)isPatcherConetxt
{
    return self.context == [JSContext currentContext];
}

- (SEL)patchSelectorWithSelector:(SEL)selector
{
    NSString *selectorName = NSStringFromSelector(selector);
    NSString *patchSelectorName = [NSString stringWithFormat:@"omkPatch_%@", selectorName];
    return NSSelectorFromString(patchSelectorName);
}

- (NSString *)patchKeyForClass:(Class)klass selector:(SEL)selector
{
    return [NSString stringWithFormat:@"%@#%@", NSStringFromClass(klass), NSStringFromSelector(selector)];
}

@end

void *ObjectiveMonkey_PatchMethod(id self, SEL _cmd, ...)
{
    va_list list;
    va_start(list, _cmd);
    
    return [[ObjectiveMonkey defaultMonkey] invokePatchWithTarget:self
                                                         selector:_cmd
                                                        arguments:list];
}
