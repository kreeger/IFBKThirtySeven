#import "BDKThirtySevenClient.h"

@class BDKCFMessage;

/** This manages all streaming communication with 37signals' Campfire API. Currently it only handles messages.
 */
@interface BDKCampfireStreamingClient : BDKThirtySevenClient

/** Overrides the parent method of initializing with just a base URL and takes an OAuth access token along with it.
 *  @param url The base URL of the Campfire account to use inside of this API wrapper class.
 *  @param accessToken A user's OAuth2-spec access token, to be sent with each call.
 *  @returns An instance of self.
 */
- (id)initWithBaseURL:(NSURL *)url accessToken:(NSString *)accessToken;

/** Stores the OAuth token inside the adapter for all future calls.
 *
 *  @param bearerToken The string of the OAuth token; will be set with "Bearer %@".
 */
- (void)setBearerToken:(NSString *)bearerToken;

/** Hopefully streams messages from a room.
 *  https://github.com/37signals/campfire-api/blob/master/sections/streaming.md
 *
 *  @param roomId The Campfire API of the room from which to stream messages.
 *  @param success A block to be called upon completion.
 *  @param failure A block to be called upon failure; contains an NSError reference and the HTTP status code received.
 */
- (void)streamMessagesForRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure;

@end
