#import "IFBKCFModel.h"

typedef NS_ENUM(NSUInteger, IFBKMessageType) {
    IFBKMessageTypeText = 0,
    IFBKMessageTypePaste,
    IFBKMessageTypeTweet,
    IFBKMessageTypeSound,
    IFBKMessageTypeAdvertisement,
    IFBKMessageTypeAllowGuests,
    IFBKMessageTypeDisallowGuests,
    IFBKMessageTypeIdle,
    IFBKMessageTypeKick,
    IFBKMessageTypeLeave,
    IFBKMessageTypeEnter,
    IFBKMessageTypeSystem,
    IFBKMessageTypeTimestamp,
    IFBKMessageTypeTopicChange,
    IFBKMessageTypeUnidle,
    IFBKMessageTypeLock,
    IFBKMessageTypeUnlock,
    IFBKMessageTypeUpload,
    IFBKMessageTypeConferenceCreated,
    IFBKMessageTypeConferenceFinished,
    IFBKMessageTypeUnknown,
} ;

/** An internal representation of a posted message in a IFBKCFRoom.
 */
@interface IFBKCFMessage : IFBKCFModel

/** The 37signals Campfire API message identifier.
 */
@property (readonly) NSNumber *identifier;

/** The 37signals Campfire API room identifier where the message was posted.
 */
@property (readonly) NSNumber *roomIdentifier;

/** The 37signals Campfire API user identifier of the message poster.
 */
@property (readonly) NSNumber *userIdentifier;

/** The text of the message.
 */
@property (strong, nonatomic) NSString *body;

/** The date and time when the message was created.
 */
@property (readonly) NSDate *createdAt;

/** A prettier-formatted version of the createdAt timestamp.
 */
@property (readonly) NSString *createdAtDisplay;

/** The type of message that was posted.
 */
@property (strong, nonatomic) NSString *type;

/** The type of message that was posted; could be a standard IFBKMessageTypeText, a IFBKMessageTypePaste, or so on.
 */
@property (readonly) IFBKMessageType messageType;

/** If `YES`, this message has been starred in the IFBKCFRoom's transcript.
 */
@property (nonatomic) BOOL starred;

/** A dictionary representation of internal IFBKCFMessageType names to the text names that come from the Campfire API.
 */
+ (NSDictionary *)messageTypeMappings;

/** An initializer that creates a IFBKCFMessage with a body and message type; an object created here is intended to be
 *  submitted to the Campfire API.
 *  @param body The body text of the message.
 *  @param type The type of the message.
 *  @return An instance of self.
 */
+ (instancetype)messageWithBody:(NSString *)body type:(NSString *)type;

/** An initializer that creates a IFBKCFMessage with a body and message type; an object created here is intended to be
 *  submitted to the Campfire API.
 *  @param body The body text of the message.
 *  @param type The type of the message.
 *  @return An instance of self.
 */
- (instancetype)initWithBody:(NSString *)body type:(NSString *)type;

@end
