#import <Foundation/Foundation.h>

@class IFBKCFMessage;

@interface IFBKCampfireStreamingClient : NSObject

@property (readonly) NSString *authorizationToken;
@property (readonly) NSNumber *roomId;
@property (copy, nonatomic) void (^messageReceivedBlock)(IFBKCFMessage *message);

- (id)initWithRoomId:(NSNumber *)roomId authorizationToken:(NSString *)authorizationToken;

- (void)openConnection;

- (void)openConnectionWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

- (void)closeConnection;

@end