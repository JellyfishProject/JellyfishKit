//
//  APIMeta.m
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 10/3/2018.
//  Copyright © 2018年 Jellyfish. All rights reserved.
//

#import "APIMeta.h"
#import "APIElement.h"

NSString *const kID = @"id";
NSString *const kRef = @"ref";
NSString *const kClasses = @"classes";
NSString *const kDescription = @"description";
NSString *const kTitle = @"title";
NSString *const kLinks = @"links";

@interface APIMeta()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation APIMeta

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _dictionary = dictionary;
    }
    return self;
}

+ (id)modelWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (APIElement *)identifier {
    return [APIElement modelWithDictionary:_dictionary[kID]];
}

- (APIElement *)ref {
    return [APIElement modelWithDictionary:_dictionary[kRef]];
}

- (NSArray<APIElement *> *)classes {
    if ([_dictionary[kClasses] isKindOfClass:[NSArray class]]) {
        NSMutableArray<APIElement *> *result = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDict in (NSArray *)_dictionary[kClasses]) {
            [result addObject:[APIElement modelWithDictionary:infoDict]];
        }
        return [result copy];
    }else{
        return nil;
    }
}

- (APIElement *)title {
    if ([_dictionary[kTitle] isKindOfClass:[NSString class]]) {
        return [APIElement modelWithDictionary:@{@"element": @"string", @"content": _dictionary[kTitle]}];
    }else{
        return [APIElement modelWithDictionary:_dictionary[kTitle]];
    }
}

- (APIElement *)apiDescription {
    return [APIElement modelWithDictionary:_dictionary[kDescription]];
}

- (NSArray<APIElement *> *)links {
    if ([_dictionary[kLinks] isKindOfClass:[NSArray class]]) {
        NSMutableArray<APIElement *> *result = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDict in (NSArray *)_dictionary[kLinks]) {
            [result addObject:[APIElement modelWithDictionary:infoDict]];
        }
        return [result copy];
    }else{
        return nil;
    }
}

@end
