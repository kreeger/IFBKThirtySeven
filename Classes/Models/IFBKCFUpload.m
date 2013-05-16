#import "IFBKCFUpload.h"
#import "NSString+IFBKThirtySeven.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation IFBKCFUpload

+ (NSDictionary *)apiMappingHash
{
    return @{@"id": @"identifier",
             @"name": @"name",
             @"room_id": @"roomIdentifer",
             @"user_id": @"userIdentifier",
             @"byte_size": @"byteSize",
             @"content_type": @"contentType",
             @"full_url": @"fullUrl"};
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithDictionary:dictionary])) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
        formatter = nil;
    }
    return self;
}

#pragma mark - Properties

- (NSURL *)fullUrlValue
{
    return [NSURL URLWithString:self.fullUrl];
}

@end
