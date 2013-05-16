#import "IFBKCFModel.h"

/** A local repesentation of a Campfire user.
 */
@interface IFBKCFUser : IFBKCFModel

/** The 37signals Campfire API user identifier.
 */
@property (strong, nonatomic) NSNumber *identifier;

/** The user's Campfire name.
 */
@property (strong, nonatomic) NSString *name;

/** The user's email address.
 */
@property (strong, nonatomic) NSString *emailAddress;

/** The user's privilege status; if `YES`, the user is an admin.
 */
@property (nonatomic) BOOL admin;

/** The date at which the user's account was created.
 */
@property (strong, nonatomic) NSDate *createdAt;

/** The user's presence status.
 */
@property (strong, nonatomic) NSString *type;

/** The URL pointing to the user's avatar image.
 */
@property (strong, nonatomic) NSString *avatarUrl;

/** The user's API authentication token.
 */
@property (strong, nonatomic) NSString *apiAuthToken;

@end
