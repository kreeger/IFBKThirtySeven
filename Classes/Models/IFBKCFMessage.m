#import "IFBKCFMessage.h"

@implementation IFBKCFMessage

@synthesize identifier = _identifier, roomIdentifier = _roomIdentifier, userIdentifier = _userIdentifier;
@synthesize createdAt = _createdAt, createdAtDisplay = _createdAtDisplay;

+ (NSDictionary *)apiMappingHash {
    return @{@"id": @"identifier",
             @"room_id": @"roomIdentifier",
             @"user_id": @"userIdentifier",
             @"body": @"body",
             @"type": @"type"};
}

+ (id)messageWithBody:(NSString *)body type:(NSString *)type {
    return [[self alloc] initWithBody:body type:type];
}

- (id)initWithBody:(NSString *)body type:(NSString *)type {
    if (self = [super init]) {
        _body = body;
        _type = type;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super initWithDictionary:dictionary])) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss Z";
        _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
        formatter.dateFormat = @"K:mm a";
        _createdAtDisplay = [formatter stringFromDate:_createdAt];
        formatter = nil;
        
        _starred = [dictionary[@"starred"] boolValue];
    }

    return self;
}

#pragma mark - Properties

+ (NSDictionary *)messageTypeMappings {
    return @{@"TextMessage": @(IFBKMessageTypeText),
             @"PasteMessage": @(IFBKMessageTypePaste),
             @"SoundMessage": @(IFBKMessageTypeSound),
             @"AdvertisementMessage": @(IFBKMessageTypeAdvertisement),
             @"AllowGuestsMessage": @(IFBKMessageTypeAllowGuests),
             @"DisallowGuestsMessage": @(IFBKMessageTypeDisallowGuests),
             @"IdleMessage": @(IFBKMessageTypeIdle),
             @"KickMessage": @(IFBKMessageTypeKick),
             @"LeaveMessage": @(IFBKMessageTypeLeave),
             @"EnterMessage": @(IFBKMessageTypeEnter),
             @"SystemMessage": @(IFBKMessageTypeSystem),
             @"TimestampMessage": @(IFBKMessageTypeTimestamp),
             @"TopicChangeMessage": @(IFBKMessageTypeTopicChange),
             @"UnidleMessage": @(IFBKMessageTypeUnidle),
             @"LockMessage": @(IFBKMessageTypeLock),
             @"UnlockMessage": @(IFBKMessageTypeUnlock),
             @"UploadMessage": @(IFBKMessageTypeUpload),
             @"ConferenceCreatedMessage": @(IFBKMessageTypeConferenceCreated),
             @"ConferenceFinishedMessage": @(IFBKMessageTypeConferenceFinished)};
}

- (NSDictionary *)asApiData {
    // TODO: Convert line breaks to &#xA;
    return @{@"message": @{@"body": self.body, @"type": self.type}};
}

- (IFBKMessageType)messageType {
    NSNumber *type = [[self class] messageTypeMappings][self.type];
    return type ? type.integerValue : IFBKMessageTypeUnknown;
}


@end
