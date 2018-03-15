//
//  ObjectiveDrafter.m
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

#import "ObjectiveDrafter.h"

#import "APIElements/APIElement.h"

#import <JavaScriptCore/JavaScriptCore.h>

@implementation ObjectiveDrafter

- (void)parseDocumentInJS:(NSString * _Nonnull)str
               completion:(void(^ _Nonnull)(APIElement  * _Nonnull blueprint))completionHandler
                  failure:(void(^ _Nonnull)(NSError * _Nonnull err))failureHandler{
    JSContext *context = [[JSContext alloc] init];
    
    NSError *drafterLoadingError;
    
    NSString *drafterJS = [NSString stringWithFormat:@"var window = this; %@", [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[ObjectiveDrafter class]] pathForResource:@"drafter" ofType:@"js"]
                                                                                                         encoding:NSUTF8StringEncoding
                                                                                                            error:&drafterLoadingError]];
    
    if (drafterLoadingError) {
        failureHandler(drafterLoadingError);
        return;
    }
    
    [context evaluateScript:drafterJS];
    
    JSValue *drafter = context[@"drafter"];
    
    JSValue *parseFunction = drafter[@"parseSync"];
    
    JSValue *result = [parseFunction callWithArguments:@[str , @{@"json": @YES, @"generateSourceMap": @NO, @"requireBlueprintName": @NO}] ];
    
    NSDictionary *resultDict = [result toDictionary];
    
    completionHandler([APIElement modelWithDictionary:resultDict]);
}

@end
