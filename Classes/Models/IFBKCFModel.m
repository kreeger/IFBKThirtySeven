#import "IFBKCFModel.h"

@implementation IFBKCFModel

+ (NSDictionary *)apiMappingHash {
    return @{};
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    for (NSString *key in [dictionary allKeys]) {
        if ([[self class] apiMappingHash][key]) {
            id value = dictionary[key];// == (id)[NSNull null] ? nil : dictionary[key];
            [self setValue:value forKeyPath:[[self class] apiMappingHash][key]];
        }
    }
    return self;
}

@end
