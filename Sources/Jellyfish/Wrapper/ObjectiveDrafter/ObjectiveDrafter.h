//
//  ObjectiveDrafter.h
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APIElement;

@interface ObjectiveDrafter : NSObject

- (void)parseDocumentInJS:(NSString * _Nonnull)str
               completion:(void(^ _Nonnull)(APIElement  * _Nonnull blueprint))completionHandler
                  failure:(void(^ _Nonnull)(NSError * _Nonnull err))failureHandler;
    
@end
