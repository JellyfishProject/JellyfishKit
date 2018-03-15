//
//  APIElement.h
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 10/3/2018.
//  Copyright © 2018年 Jellyfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APIMeta;

@interface APIElement : NSObject

+ (id _Nonnull )modelWithDictionary:(NSDictionary * _Nonnull)dictionary;

# pragma mark - Base API Elements

@property (nonatomic, strong, readonly, nonnull) NSString *element;
@property (nonatomic, strong, readonly, nullable) APIMeta *meta;
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, APIElement *> *attributes;
@property (nonatomic, strong, readonly, nullable) NSArray<APIElement *> *contentArray;
@property (nonatomic, strong, readonly, nullable) NSString *contentString;
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, APIElement *> *contentDictionary;

@property (nonatomic, strong) NSDictionary *dictionary;

@end
