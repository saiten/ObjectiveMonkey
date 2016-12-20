//
//  OMKObjcBox.h
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <JavascriptCore/JavascriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OMKObjcBoxJSExports <JSExport>
- (JSValue *)call:(NSString *)method;
- (JSValue *)callSuper:(NSString *)method;
- (JSValue *)originalImplementation;

- (JSValue *)jsString;
- (JSValue *)jsNumber;
- (JSValue *)jsBoolean;

- (JSValue *)isNil;
- (JSValue *)isNSNull;
- (JSValue *)isNSString;
- (JSValue *)isNSNumber;
@end


@interface OMKObjcBox<__covariant ObjectType>: NSObject <OMKObjcBoxJSExports>
@property (nonatomic, weak) JSContext *context;
@property (nonatomic, readonly) ObjectType object;
@property (nonatomic, nullable) SEL originalImplementationSelector;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(nullable ObjectType)object;
- (instancetype)initWithObject:(nullable ObjectType)object context:(JSContext *)context;
+ (instancetype)boxWithObject:(nullable ObjectType)object;
+ (instancetype)boxWithObject:(nullable ObjectType)object context:(JSContext *)context;
@end

NS_ASSUME_NONNULL_END
