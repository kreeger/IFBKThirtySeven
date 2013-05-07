#import "BDKCFModel.h"

@implementation BDKCFModel

+ (NSDictionary *)apiMappingHash
{
    return @{};
}

+ (id)modelWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        for (NSString *key in [dictionary allKeys]) {
            if ([[self class] apiMappingHash][key]) {
                id value = dictionary[key];// == (id)[NSNull null] ? nil : dictionary[key];
                [self setValue:value forKeyPath:[[self class] apiMappingHash][key]];
            }
        }
    }

    return self;
}

@end
