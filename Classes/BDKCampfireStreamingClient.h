#import <Foundation/Foundation.h>

@class BDKCFMessage;

@interface BDKCampfireStreamingClient : NSObject

@property (readonly) NSString *authorizationToken;
@property (readonly) NSNumber *roomId;
@property (copy, nonatomic) void (^messageReceivedBlock)(BDKCFMessage *message);

- (id)initWithRoomId:(NSNumber *)roomId authorizationToken:(NSString *)authorizationToken;

- (void)openConnection;

- (void)openConnectionWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

- (void)closeConnection;

@end