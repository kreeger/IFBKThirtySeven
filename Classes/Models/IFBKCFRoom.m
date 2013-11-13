#import "IFBKCFRoom.h"
#import "IFBKCFUser.h"

@implementation IFBKCFRoom

+ (NSDictionary *)apiMappingHash {
    return @{@"id": @"identifier",
             @"name": @"name",
             @"topic": @"topic",
             @"membership_limit": @"membershipLimit",
             @"active_token_value": @"activeTokenValue"};
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) return nil;

    _full = [dictionary[@"full"] boolValue];
    _openToGuests = [dictionary[@"open_to_guests"] boolValue];
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:[dictionary[@"users"] count]];
    for (NSDictionary *user in dictionary[@"users"]) {
        [users addObject:[IFBKCFUser modelWithDictionary:user]];
    }
    _users = [NSArray arrayWithArray:users];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss Z";
    _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
    _updatedAt = [formatter dateFromString:dictionary[@"updated_at"]];
    formatter = nil;
    return self;
}

#pragma mark - Properties

- (NSDictionary *)asApiData {
    return @{@"room": @{@"name": self.name, @"topic": self.topic}};
}

@end
