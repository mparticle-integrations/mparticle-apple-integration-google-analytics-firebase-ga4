#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

@interface MPKitFirebaseAnalytics : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;

@end

static NSString * _Nonnull const kMPFIRGoogleAppIDKey = @"firebaseAppId";
static NSString * _Nonnull const kMPFIRSenderIDKey = @"googleProjectNumber";
static NSString * _Nonnull const kMPFIRAPIKey = @"firebaseAPIKey";
static NSString * _Nonnull const kMPFIRProjectIDKey = @"firebaseProjectId";
static NSString * _Nonnull const kMPFIRUserIdFieldKey = @"userIdField";

static NSString * _Nonnull const kMPFIRGA4CommerceEventType = @"GA4.CommerceEventType";
static NSString * _Nonnull const kMPFIRGA4PaymentType = @"GA4.PaymentType";
static NSString * _Nonnull const kMPFIRGA4ShippingTier = @"GA4.ShippingTier";
