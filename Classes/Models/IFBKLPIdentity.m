#import "IFBKLPIdentity.h"

@implementation IFBKLPIdentity

+ (NSDictionary *)apiMappingHash {
    return @{@"id": @"identifier",
             @"email_address": @"emailAddress",
             @"first_name": @"firstName",
             @"last_name": @"lastName"};
}

@end
