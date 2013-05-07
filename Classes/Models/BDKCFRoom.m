#import "BDKCFRoom.h"
#import "BDKCFUser.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation BDKCFRoom

+ (NSDictionary *)apiMappingHash
{
    return @{@"id": @"identifier",
             @"name": @"name",
             @"topic": @"topic",
             @"membership_limit": @"membershipLimit",
             @"active_token_value": @"activeTokenValue"};
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithDictionary:dictionary])) {
        _full = [dictionary[@"full"] isEqualToString:@"true"];
        _openToGuests = [dictionary[@"open_to_guests"] isEqualToString:@"true"];
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[dictionary[@"users"] count]];
        for (NSDictionary *user in dictionary[@"users"]) {
            [users addObject:[BDKCFUser modelWithDictionary:user]];
        }
        _users = [NSArray arrayWithArray:users];
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
        _updatedAt = [formatter dateFromString:dictionary[@"updated_at"]];
        formatter = nil;
    }
    return self;
}

#pragma mark - Properties

- (NSDictionary *)asApiData
{
    return @{@"room": @{@"name": self.name, @"topic": self.topic}};
}

@end
