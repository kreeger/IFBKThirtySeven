#import "BDKCampfireStreamingClient.h"

#import "BDKCFMessage.h"

#import <SBJson/SBJson.h>
#import <AFNetworking/AFHTTPClient.h>

#define kBDKCampfireStreamingBaseURL @"https://streaming.campfirenow.com/"

@interface BDKCampfireStreamingClient () <SBJsonStreamParserAdapterDelegate>

@property (strong, nonatomic) SBJsonStreamParserAdapter *adapter;
@property (strong, nonatomic) SBJsonStreamParser *parser;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) void (^connectionSuccess)(void);
@property (copy, nonatomic) void (^connectionFailure)(NSError *error);

- (NSURLRequest *)request;

@end

@implementation BDKCampfireStreamingClient

@synthesize roomId = _roomId, authorizationToken = _authorizationToken;

- (id)initWithRoomId:(NSNumber *)roomId authorizationToken:(NSString *)authorizationToken {
    if (self = [super init]) {
        _roomId = roomId;
        _authorizationToken = authorizationToken;
    }
    return self;
}

#pragma mark - Public methods

- (void)openConnectionWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
    self.connectionSuccess = success;
    self.connectionFailure = failure;
	self.adapter = [[SBJsonStreamParserAdapter alloc] init];
	self.adapter.delegate = self;
	self.parser = [[SBJsonStreamParser alloc] init];
	self.parser.delegate = self.adapter;
	self.parser.supportMultipleDocuments = YES;
	self.connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self];
}

- (void)openConnection {
    [self openConnectionWithSuccess:nil failure:nil];
}

- (void)closeConnection {
    [self.connection cancel];
}

#pragma mark - Private helpers

- (NSURLRequest*)request {
    NSURL *url = [NSURL URLWithString:kBDKCampfireStreamingBaseURL];
    NSString *path = [NSString stringWithFormat:@"room/%@/live.json", self.roomId];

    AFHTTPClient *apiClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [apiClient clearAuthorizationHeader];
    [apiClient setAuthorizationHeaderWithUsername:self.authorizationToken password:@"X"];

    NSURLRequest *request = [apiClient requestWithMethod:@"GET" path:path parameters:nil];
    return request;
}

#pragma mark - SBJsonStreamParserAdapterDelegate

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:NSInternalInconsistencyException format:@"Unexpected Array"];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    BDKCFMessage *message = [BDKCFMessage modelWithDictionary:dict];
    if (self.messageReceivedBlock) self.messageReceivedBlock(message);
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (self.connectionSuccess) {
        self.connectionSuccess();
        self.connectionSuccess = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	SBJsonStreamParserStatus status = [self.parser parse:data];

	if (status == SBJsonStreamParserError) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: self.parser.error };
        NSError *error = [NSError errorWithDomain:@"ERRORDOMAIN" code:0001 userInfo:userInfo];
        if (self.connectionFailure) self.connectionFailure(error);
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self openConnection];
    if (self.connectionFailure) {
        self.connectionFailure(error);
    }
}

@end