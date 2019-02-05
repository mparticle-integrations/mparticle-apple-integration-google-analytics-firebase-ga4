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
-(NSString *)bundleIdentifier
{
    return @"com.mparticle.iOS-Example";
}
#pragma clang diagnostic pop

@end

@interface MPKitFirebaseAnalytics()

@property (nonatomic, strong, readwrite) FIROptions *firebaseOptions;

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
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096"}];
    XCTAssertTrue(exampleKit.started);
}

- (void)testFIRApp {
    id mockFIRApp = OCMClassMock([FIRApp class]);
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:@"1:338209672096:ios:57235e7ff821ba85" GCMSenderID:@"338209672096"];
    
    
    [[mockFIRApp expect] configureWithOptions:options];
    
    [FIRApp configureWithOptions:options];
    
    [mockFIRApp verify];
}

- (void)testLogCommerceEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096"}];
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    
    MPKitExecStatus *execStatus = [exampleKit logCommerceEvent:event];
    
    XCTAssertTrue(execStatus.success);
    XCTAssertTrue(exampleKit.firebaseOptions);
}

- (void)testLogCommerceEventPurchase {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096"}];
    
    MPProduct *product = [[MPProduct alloc] initWithName:@"Tardis" sku:@"9who" quantity:@1 price:@42.0];
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase product:product];
    
    MPKitExecStatus *execStatus = [exampleKit logCommerceEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096"}];
    
    MPEvent *event = [[MPEvent alloc] initWithName:@"example" type:MPEventTypeOther];
    
    MPKitExecStatus *execStatus = [exampleKit logEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogEventWithNilEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{kMPFIRGoogleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", kMPFIRSenderIDKey:@"338209672096"}];
    
    MPEvent *event;
    
    MPKitExecStatus *execStatus = [exampleKit logEvent:event];
    
    XCTAssertFalse(execStatus.success);
}

@end
