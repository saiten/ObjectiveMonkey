//
//  JSValue+ObjectiveMonkey.h
//  ObjectiveMonkey
//
//  Copyright (c) 2016 saiten. All rights reserved.
//

#import <JavascriptCore/JavascriptCore.h>

@interface JSValue (ObjectiveMonkey)

- (void *)omk_encodeValueWithEncodeType:(const char *)encodeType;
+ (JSValue *)omk_valueWithArguments:(va_list)arguments
                       argumentType:(const char *)argumentType
                          inContext:(JSContext *)context;

@end
