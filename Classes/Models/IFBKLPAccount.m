#import "IFBKLPAccount.h"
#import "NSString+IFBKThirtySeven.h"

@implementation IFBKLPAccount

+ (NSDictionary *)apiMappingHash {
    return @{@"id": @"identifier",
             @"name": @"name",
             @"href": @"href",
             @"product": @"product"};
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) return nil;
    
    return self;
}

@end
