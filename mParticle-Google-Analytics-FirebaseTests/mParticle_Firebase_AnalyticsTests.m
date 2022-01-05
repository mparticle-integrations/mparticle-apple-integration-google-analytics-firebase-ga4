#import <XCTest/XCTest.h>
#import "MPKitFirebaseAnalytics.h"
#import "Firebase.h"
#import "OCMock.h"

@interface NSBundle (BundleIdentifier)
-(NSString *)bundleIdentifier;
@end

@implementation NSBundle (BundleIdentifier)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)bundleIdentifier {
    return @"com.mparticle.iOS-Example";
}
#pragma clang diagnostic pop
@end

@interface MPKitFirebaseAnalytics()

@property (nonatomic, strong, readwrite) FIROptions *firebaseOptions;
- (NSString *)standardizeNameOrKey:(NSString *)nameOrKey forEvent:(BOOL)forEvent;
- (NSString *)getEventNameForCommerceEvent:(MPCommerceEvent *)commerceEvent parameters:(NSDictionary<NSString *, id> *)parameters;
- (NSDictionary<NSString *, id> *)getParameterForCommerceEvent:(MPCommerceEvent *)commerceEvent;
@end

@interface mParticle_Firebase_AnalyticsTests : XCTestCase
@end

@implementation mParticle_Firebase_AnalyticsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testStarted {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096", kMPFIRAPIKey: @"AIzaSyDVH6Lxu4QvIWheB14FChPIdI6FiCi8PXY", kMPFIRProjectIDKey: @"mparticle-integration-test"}];
    XCTAssertTrue(exampleKit.started);
}

- (void)testFIRApp {
    id mockFIRApp = OCMClassMock([FIRApp class]);
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:@"1:338209672096:ios:57235e7ff821ba85" GCMSenderID:@"338209672096"];
    
    
    [[mockFIRApp expect] configureWithOptions:options];
    
    [FIRApp configureWithOptions:options];
    
    [mockFIRApp verify];
    [mockFIRApp stopMocking];
}

- (void)testLogCommerceEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096", kMPFIRAPIKey: @"AIzaSyDVH6Lxu4QvIWheB14FChPIdI6FiCi8PXY", kMPFIRProjectIDKey: @"mparticle-integration-test"}];
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
    XCTAssertTrue(exampleKit.firebaseOptions);
}

- (void)testLogCommerceEventPurchase {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096", kMPFIRAPIKey: @"AIzaSyDVH6Lxu4QvIWheB14FChPIdI6FiCi8PXY", kMPFIRProjectIDKey: @"mparticle-integration-test"}];
    
    MPProduct *product = [[MPProduct alloc] initWithName:@"Tardis" sku:@"9who" quantity:@1 price:@42.0];
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase product:product];
    
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096", kMPFIRAPIKey: @"AIzaSyDVH6Lxu4QvIWheB14FChPIdI6FiCi8PXY", kMPFIRProjectIDKey: @"mparticle-integration-test"}];
    
    MPEvent *event = [[MPEvent alloc] initWithName:@"example" type:MPEventTypeOther];
    
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogEventWithNilEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096", kMPFIRAPIKey: @"AIzaSyDVH6Lxu4QvIWheB14FChPIdI6FiCi8PXY", kMPFIRProjectIDKey: @"mparticle-integration-test"}];
    
    MPEvent *event;
    
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertFalse(execStatus.success);
}

- (void)testSanitization {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event name" forEvent:YES], @"event_name");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event_name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event  name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event - name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event name" forEvent:NO], @"event_name");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event_name " forEvent:NO], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event  name " forEvent:NO], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event - name " forEvent:NO], @"event_name_");
}

- (void)testCommerceEventCheckoutOptions {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096", kMPFIRAPIKey: @"AIzaSyDVH6Lxu4QvIWheB14FChPIdI6FiCi8PXY", kMPFIRProjectIDKey: @"mparticle-integration-test"}];
    
    // Test fallback when not using GA4
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    NSDictionary<NSString *, id> *parameters = [exampleKit getParameterForCommerceEvent:event];
    NSString *eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventSetCheckoutOption, eventName);
    
    // Test kFIREventAddShippingInfo
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlag:kFIREventAddShippingInfo withKey:kMPFIRGA4CommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddShippingInfo, eventName);
    
    // Test kFIREventAddPaymentInfo
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlag:kFIREventAddPaymentInfo withKey:kMPFIRGA4CommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddPaymentInfo, eventName);
    
    // Test both (defaults to kFIREventAddShippingInfo)
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlags:@[kFIREventAddShippingInfo, kFIREventAddPaymentInfo] withKey:kMPFIRGA4CommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddShippingInfo, eventName);
}

@end
