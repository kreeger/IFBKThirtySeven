#import <Foundation/Foundation.h>

@class IFBKCFMessage;

typedef void (^StreamOpenBlock)(NSHTTPURLResponse* httpResponse);
typedef void (^StreamDidReceiveMessageBlock)(IFBKCFMessage *message);
typedef void (^StreamDidEncounterErrorBlock)(NSError *error);

/**
 Provides support for the streaming API of Campfire.
 */
@interface IFBKCampfireStreamingClient : NSObject


/**
 The designated initializer.
 @param roomId The Campfire API room identifier for which this client will handle the streaming connection.
 @param authorizationToken The `API authentication token` available on the `My Info` screen of the Campfire web interface. The streaming API doesn't support OAuth.
 */
- (instancetype)initWithRoomId:(NSNumber *)roomId authorizationToken:(NSString *)authorizationToken;

@property (nonatomic, copy, readonly) NSNumber *roomId;

@property (nonatomic, copy,readonly) NSString *authorizationToken;

/**
 Opens the streaming connection.
 *  @param success A block to be called upon the establishment of the connection; contains the response of the server.
 *  @param messageReceived A block to be called upon the reception of a new message; contains the received message.
 *  @param failure A block to be called upon failure; contains an NSError reference. This handle is not called if the connection was cancelled by the client.
 */
- (void)openConnection:(StreamOpenBlock)success messageReceived:(StreamDidReceiveMessageBlock)messageReceived failure:(StreamDidEncounterErrorBlock)failure;

/**
 Reopens the streaming connection.
 */
- (void)reopenConnection;

/**
 Terminates the streaming connection.
 */
- (void)closeConnection;

@end
