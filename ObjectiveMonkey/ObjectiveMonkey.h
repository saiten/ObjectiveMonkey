//
//  ObjectiveMonkey.h
//  ObjectiveMonkey
//
//  Copyright © 2016 saiten. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JSValue;

@interface ObjectiveMonkey : NSObject

@property (nonatomic) NSURLSessionConfiguration *configuration;

+ (instancetype)defaultMonkey;

- (void)patchFromURL:(NSURL *)url;
- (void)patchFromString:(NSString *)script;

- (void)addPatchForClass:(Class)klass selector:(SEL)selector block:(id)block;
- (void)addPatchForClass:(Class)klass selector:(SEL)selector patch:(JSValue *)patchFunction;
- (void)removePatchMethodForClass:(Class)klass selector:(SEL)selector;
- (void)removeAllPatches;
@end

NS_ASSUME_NONNULL_END
