#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "PaymentSDK.h"
#import "PaymentSDK-Swift.h"

@interface RNPayTm : RCTEventEmitter <RCTBridgeModule, PGTransactionDelegate>

@end
  
