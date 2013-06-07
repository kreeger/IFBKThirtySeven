#import "IFBKLPAuthorizationData.h"
#import "IFBKLPIdentity.h"
#import "IFBKLPAccount.h"

@implementation IFBKLPAuthorizationData

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithDictionary:dictionary])) {
        _identity = [IFBKLPIdentity modelWithDictionary:dictionary[@"identity"]];
        NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:[dictionary[@"accounts"] count]];
        for (NSDictionary *account in dictionary[@"accounts"]) {
            [accounts addObject:[IFBKLPAccount modelWithDictionary:account]];
        }
        _accounts = [NSArray arrayWithArray:accounts];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss Z";
        _expiresAt = [formatter dateFromString:dictionary[@"expires_at"]];
        formatter = nil;
    }

    return self;
}

@end
