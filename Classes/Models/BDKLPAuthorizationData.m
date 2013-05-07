#import "BDKLPAuthorizationData.h"
#import "BDKLPIdentity.h"
#import "BDKLPAccount.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation BDKLPAuthorizationData

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithDictionary:dictionary])) {
        _identity = [BDKLPIdentity modelWithDictionary:dictionary[@"identity"]];
        NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:[dictionary[@"accounts"] count]];
        for (NSDictionary *account in dictionary[@"accounts"]) {
            [accounts addObject:[BDKLPAccount modelWithDictionary:account]];
        }
        _accounts = [NSArray arrayWithArray:accounts];
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        _expiresAt = [formatter dateFromString:dictionary[@"expires_at"]];
        formatter = nil;
    }

    return self;
}

@end
