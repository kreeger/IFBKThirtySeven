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

    context(@"In case of a sucessful response", ^{
        it(@"", ^{

        });
    });
});

SPEC_END