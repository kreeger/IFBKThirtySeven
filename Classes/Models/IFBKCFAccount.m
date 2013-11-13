#import "IFBKCFAccount.h"
#import "IFBKThirtySevenCommon.h"

@implementation IFBKCFAccount

+ (NSDictionary *)apiMappingHash {
    return @{@"id": @"identifier",
             @"name": @"name",
             @"subdomain": @"subdomain",
             @"plan": @"plan",
             @"owner_id": @"ownerIdentifier",
             @"time_zone": @"timeZone",
             @"storage": @"storage"};
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) return nil;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kIFBKDateFormatCampfire;
    _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
    _updatedAt = [formatter dateFromString:dictionary[@"updated_at"]];
    formatter = nil;
    return self;
}

@end
