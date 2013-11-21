#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <IFBKThirtySeven/IFBKThirtySeven.h>
#import <SBJson/SBJson.h>

SPEC_BEGIN(IFBKCampfireStreamingClientSpec)

describe(@"IFBKCampfireStreamingClient", ^{

    __block IFBKCampfireStreamingClient *sut;

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    beforeEach(^{
        sut = [[IFBKCampfireStreamingClient alloc] initWithRoomId:@1 authorizationToken:@"AUTHORIZATION_TOKNE"];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    it(@"Opens the connection", ^{
        stubRequest(@"GET", @"https://streaming.campfirenow.com/room/1/live.json").
        andReturn(200);
        __block NSHTTPURLResponse *capturedResponse;
        [sut openConnection:^(NSHTTPURLResponse *httpResponse) {
            capturedResponse = httpResponse;
        } messageReceived:nil failure:nil];
        [[expectFutureValue(theValue(capturedResponse.statusCode)) shouldEventually] equal:@200];
    });
});

SPEC_END
