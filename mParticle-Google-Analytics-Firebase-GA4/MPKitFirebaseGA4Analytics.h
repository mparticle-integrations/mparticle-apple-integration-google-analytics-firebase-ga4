#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

@interface MPKitFirebaseGA4Analytics : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;

@end

static NSString * _Nonnull const kMPFIRGA4ExternalUserIdentityType = @"externalUserIdentityType";
static NSString * _Nonnull const kMPFIRGA4ShouldHashUserId = @"hashUserId";
static NSString * _Nonnull const kMPFIRGA4CommerceEventType = @"GA4.CommerceEventType";
static NSString * _Nonnull const kMPFIRGA4PaymentType = @"GA4.PaymentType";
static NSString * _Nonnull const kMPFIRGA4ShippingTier = @"GA4.ShippingTier";
