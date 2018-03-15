//
//  APIElement.m
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 10/3/2018.
//  Copyright © 2018年 Jellyfish. All rights reserved.
//

#import "APIElement.h"

#import "APIMeta.h"

NSString *const kElement = @"element";
NSString *const kContent = @"content";
NSString *const kMeta = @"meta";
NSString *const kAttributes = @"attributes";

@interface APIElement()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation APIElement

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _dictionary = dictionary;
    }
    return self;
}

+ (id)modelWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}


# pragma mark - Base API Elements

- (NSString *)element {
    return _dictionary[kElement];
}

- (APIMeta *)meta {
    if (_dictionary[kMeta] != nil && ![_dictionary[kMeta] isKindOfClass:[NSNull class]]) {
        return [APIMeta modelWithDictionary:_dictionary[kMeta]];
    }else{
        return nil;
    }
}

- (NSDictionary<NSString *, APIElement *> *)attributes {
    if (_dictionary[kAttributes] != nil && [_dictionary[kAttributes] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *metaDict = _dictionary[kAttributes];
        NSMutableDictionary<NSString *, APIElement *> *result = [NSMutableDictionary dictionary];
        
        for (NSString *key in metaDict.allKeys) {
            if ([result[key] isKindOfClass:[NSString class]]) {
                result[key] = [APIElement modelWithDictionary:@{@"element": @"string", @"content": metaDict[key]}];
            }else{
                result[key] = [APIElement modelWithDictionary:metaDict[key]];
            }
            
            
        }
        
        return [result copy];
    }else{
        return nil;
    }
}

- (NSArray<APIElement *> *)contentArray{
    if ([_dictionary isKindOfClass:[NSArray class]]) {
        NSMutableArray<APIElement *> *result = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDict in (NSArray *)_dictionary) {
            [result addObject:[APIElement modelWithDictionary:infoDict]];
        }
        return [result copy];
    }else if ([_dictionary[kContent] isKindOfClass:[NSArray class]]) {
        NSMutableArray<APIElement *> *result = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDict in (NSArray *)_dictionary[kContent]) {
            [result addObject:[APIElement modelWithDictionary:infoDict]];
        }
        return [result copy];
    }else{
        return nil;
    }
}

- (NSString *)contentString {
    if ([_dictionary isKindOfClass:[NSString class]]){
        return (NSString *)_dictionary;
    }else if ([_dictionary[kContent] isKindOfClass:[NSString class]]) {
        return _dictionary[kContent];
    }else{
        return nil;
    }
}

- (NSDictionary<NSString *, APIElement *> *)contentDictionary {
    if (_dictionary[kContent] != nil && [_dictionary[kContent] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *metaDict = _dictionary[kContent];
        NSMutableDictionary<NSString *, APIElement *> *result = [NSMutableDictionary dictionary];
        
        for (NSString *key in metaDict.allKeys) {
            result[key] = [APIElement modelWithDictionary:metaDict[key]];
        }
        
        return [result copy];
    }else{
        return nil;
    }
}

@end
