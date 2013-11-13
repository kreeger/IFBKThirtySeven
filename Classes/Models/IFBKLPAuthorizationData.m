#import "IFBKLPAuthorizationData.h"
#import "IFBKLPIdentity.h"
#import "IFBKLPAccount.h"

@implementation IFBKLPAuthorizationData

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) return nil;

    _identity = [IFBKLPIdentity modelWithDictionary:dictionary[@"identity"]];
    NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:[dictionary[@"accounts"] count]];
    for (NSDictionary *account in dictionary[@"accounts"]) {
        [accounts addObject:[IFBKLPAccount modelWithDictionary:account]];
    }
    _accounts = [NSArray arrayWithArray:accounts];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss Z"];
    _expiresAt = [formatter dateFromString:dictionary[@"expires_at"]];
    formatter = nil;
    return self;
}

@end
