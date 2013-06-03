#import "IFBKCFRoom.h"
#import "IFBKCFUser.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation IFBKCFRoom

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
        _full = dictionary[@"full"];
        _openToGuests = dictionary[@"open_to_guests"];
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[dictionary[@"users"] count]];
        for (NSDictionary *user in dictionary[@"users"]) {
            [users addObject:[IFBKCFUser modelWithDictionary:user]];
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
