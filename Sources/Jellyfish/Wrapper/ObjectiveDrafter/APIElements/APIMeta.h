//
//  APIMeta.h
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 10/3/2018.
//  Copyright © 2018年 Jellyfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APIElement;

@interface APIMeta : NSObject

+ (id _Nonnull )modelWithDictionary:(NSDictionary * _Nonnull)dictionary;

@property (nonatomic, strong, readonly, nullable) APIElement *identifier;
@property (nonatomic, strong, readonly, nullable) APIElement *ref;
@property (nonatomic, strong, readonly, nullable) NSArray<APIElement *> *classes;
@property (nonatomic, strong, readonly, nullable) APIElement *title;
@property (nonatomic, strong, readonly, nullable) APIElement *apiDescription;
@property (nonatomic, strong, readonly, nullable) NSArray<APIElement *> *links;

@end
