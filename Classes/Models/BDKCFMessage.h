#import "BDKCFModel.h"

typedef enum {
    BDKMessageTypeText = 0,
    BDKMessageTypePaste,
    BDKMessageTypeSound,
    BDKMessageTypeAdvertisement,
    BDKMessageTypeAllowGuests,
    BDKMessageTypeDisallowGuests,
    BDKMessageTypeIdle,
    BDKMessageTypeKick,
    BDKMessageTypeLeave,
    BDKMessageTypeEnter,
    BDKMessageTypeSystem,
    BDKMessageTypeTimestamp,
    BDKMessageTypeTopicChange,
    BDKMessageTypeUnidle,
    BDKMessageTypeLock,
    BDKMessageTypeUnlock,
    BDKMessageTypeUpload,
    BDKMessageTypeConferenceCreated,
    BDKMessageTypeConferenceFinished,
    BDKMessageTypeUnknown,

} BDKMessageType;

/** An internal representation of a posted message in a BDKCFRoom.
 */
@interface BDKCFMessage : BDKCFModel

/** The 37signals Campfire API message identifier.
 */
@property (strong, nonatomic) NSNumber *identifier;

/** The 37signals Campfire API room identifier where the message was posted.
 */
@property (strong, nonatomic) NSNumber *roomIdentifier;

/** The 37signals Campfire API user identifier of the message poster.
 */
@property (strong, nonatomic) NSNumber *userIdentifier;

/** The text of the message.
 */
@property (strong, nonatomic) NSString *body;

/** The date and time when the message was created.
 */
@property (strong, nonatomic) NSDate *createdAt;

/** The type of message that was posted.
 */
@property (strong, nonatomic) NSString *type;

/** The type of message that was posted; could be a standard BDKMessageTypeText, a BDKMessageTypePaste, or so on.
 */
@property (readonly) BDKMessageType messageType;

/** If `YES`, this message has been starred in the BDKCFRoom's transcript.
 */
@property (nonatomic) BOOL starred;

/** A dictionary representation of internal BDKCFMessageType names to the text names that come from the Campfire API.
 */
+ (NSDictionary *)messageTypeMappings;

/** An initializer that creates a BDKCFMessage with a body and message type; an object created here is intended to be
 *  submitted to the Campfire API.
 *  @param body The body text of the message.
 *  @param type The type of the message.
 *  @returns An instance of self.
 */
+ (id)messageWithBody:(NSString *)body type:(NSString *)type;

/** An initializer that creates a BDKCFMessage with a body and message type; an object created here is intended to be
 *  submitted to the Campfire API.
 *  @param body The body text of the message.
 *  @param type The type of the message.
 *  @returns An instance of self.
 */
- (id)initWithBody:(NSString *)body type:(NSString *)type;

@end
