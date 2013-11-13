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

+ (instancetype)messageWithBody:(NSString *)body type:(NSString *)type {
    return [[self alloc] initWithBody:body type:type];
}

- (instancetype)initWithBody:(NSString *)body type:(NSString *)type {
    self = [super init];
    if (!self) return nil;

    _body = body;
    _type = type;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (!self) return nil;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss Z";
    _createdAt = [formatter dateFromString:dictionary[@"created_at"]];
    formatter.dateFormat = @"h:mm a";
    _createdAtDisplay = [formatter stringFromDate:_createdAt];
    formatter = nil;
    _starred = [dictionary[@"starred"] boolValue];
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<IFBKCFMessage %@, %@>", self.type, self.createdAt];
}

#pragma mark - Properties

+ (NSDictionary *)messageTypeMappings {
    return @{@"TextMessage": @(IFBKMessageTypeText),
             @"PasteMessage": @(IFBKMessageTypePaste),
             @"TweetMessage": @(IFBKMessageTypeTweet),
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
    return @{@"message": @{@"body": self.body, @"type": self.type}};
}

- (IFBKMessageType)messageType {
    NSNumber *type = [[self class] messageTypeMappings][self.type];
    return type ? type.integerValue : IFBKMessageTypeUnknown;
}


@end
