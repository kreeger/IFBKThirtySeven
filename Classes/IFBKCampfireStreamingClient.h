#import <Foundation/Foundation.h>

@class IFBKCFMessage;

/**
 Handles streaming JSON connections to the Campfire API.
 */
@interface IFBKCampfireStreamingClient : NSObject

@property (readonly) NSString *authorizationToken;
@property (readonly) NSNumber *roomId;
@property (copy, nonatomic) void (^messageReceivedBlock)(IFBKCFMessage *message);

/**
 Authentication is done through a token available on the "My Info" screen in Campfire. The streaming API doesn't
 support OAuth.
 */
- (instancetype)initWithRoomId:(NSNumber *)roomId authorizationToken:(NSString *)authorizationToken;

- (void)openConnection;

- (void)openConnectionWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

- (void)closeConnection;

@end
