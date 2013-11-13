#import "IFBKCFUser.h"
#import "IFBKThirtySevenCommon.h"
#import "NSString+IFBKThirtySeven.h"

@implementation IFBKCFUser

+ (NSDictionary *)apiMappingHash {
    return @{@"id": @"identifier",
             @"name": @"name",
             @"email_address": @"emailAddress",
             @"admin": @"admin",
             @"type": @"type",
             @"avatar_url": @"avatarUrl",
             @"api_auth_token": @"apiAuthToken"};
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) return nil;

    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:kIFBKDateFormatCampfire];
    _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
    formatter = nil;
    return self;
}

@end
