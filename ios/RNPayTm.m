#import "RNPayTm.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@implementation RNPayTm

UIViewController* rootVC;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(startPayment: (NSDictionary *)details)
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableDictionary *orderDict = [NSMutableDictionary new];
    NSString* mode = details[@"mode"];

    orderDict[@"MID"] = details[@"MID"];
    orderDict[@"CHANNEL_ID"] = details[@"CHANNEL_ID"];
    orderDict[@"INDUSTRY_TYPE_ID"] = details[@"INDUSTRY_TYPE_ID"];
    orderDict[@"WEBSITE"] = details[@"WEBSITE"];
    orderDict[@"TXN_AMOUNT"] = details[@"TXN_AMOUNT"];
    orderDict[@"ORDER_ID"] = details[@"ORDER_ID"];
    orderDict[@"CUST_ID"] = details[@"CUST_ID"];
    orderDict[@"CHECKSUMHASH"] = details[@"CHECKSUMHASH"];
    orderDict[@"CALLBACK_URL"] = details[@"CALLBACK_URL"];

    if (details[@"MERC_UNQ_REF"]) {
        orderDict[@"MERC_UNQ_REF"] = details[@"MERC_UNQ_REF"];
    }
    if (details[@"EMAIL"]) {
        orderDict[@"EMAIL"] = details[@"EMAIL"];
    }
    if (details[@"MOBILE_NO"]) {
        orderDict[@"MOBILE_NO"] = details[@"MOBILE_NO"];
    }

//    PGOrder *order = [PGOrder orderWithParams:orderDict];
//    NSDictionary *order = [[PGOrder new] orderWithParamsWithDic:orderDict];
//    PGOrder *order = [[PGOrder new] initWithOrderID:details[@"ORDER_ID"] customerID:details[@"CUST_ID"] amount:details[@"TXN_AMOUNT"] eMail:details[@"EMAIL"] mobile:details[@"MOBILE_NO"]];

//    PGTransactionViewController* txnController = [[PGTransactionViewController alloc] initWithTransactionParameters:order];
//    PGTransactionViewController* txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
//    PGTransactionViewController* txnController = [[PGTransactionViewController alloc] initTransactionFor:order];

    PGOrder *order = [PGOrder new];
    order.params = orderDict;
    PGTransactionViewController *txnController = [[PGTransactionViewController alloc] initTransactionFor:order];
    
    if ([mode isEqualToString:@"Staging"]) {
//        txnController.serverType = eServerTypeStaging;
        txnController.serverType = ServerTypeEServerTypeStaging;
        txnController.loggingEnabled = YES;
        txnController.useStaging = YES;
    } else if ([mode isEqualToString:@"Production"]) {
//        txnController.serverType = eServerTypeProduction;
        txnController.serverType = ServerTypeEServerTypeProduction;
    } else
        return;

    txnController.merchant = [PGMerchantConfiguration defaultConfiguration];
    txnController.title = @"Paytm payment";
    txnController.delegate = self;

    rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
//    [rootVC.navigationController pushViewController:txnController animated:YES];
//    NSLog(@"rootVC.navigationController - %@", rootVC.navigationController);
    [((UINavigationController*)rootVC) pushViewController:txnController animated:YES];
//    ((UINavigationController*)rootVC).navigationBarHidden = false;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [rootVC presentViewController:txnController animated:YES completion:nil];
//    });
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"PayTMResponse"];
}

- (void)setNavigationBarHidden:(BOOL)flag {
    ((UINavigationController*)rootVC).navigationBarHidden = flag;
}

//this function triggers when transaction gets finished
-(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString {
    [self sendEventWithName:@"PayTMResponse" body:@{@"status":@"Success", @"response":responseString}];
//    [controller dismissViewControllerAnimated:YES completion:nil];
//    [self setNavigationBarHidden:true];
    [controller.navigationController popViewControllerAnimated:YES];
}

//this function triggers when transaction gets cancelled
-(void)didCancelTrasaction:(PGTransactionViewController *)controller {
    //    [_statusTimer invalidate];
//    NSString *msg = [NSString stringWithFormat:@"UnSuccessful"];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cancel transaction" message:msg preferredStyle:UIAlertControllerStyleAlert];

//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self sendEventWithName:@"PayTMResponse" body:@{@"status":@"Cancel", @"response":msg}];
//        [rootVC dismissViewControllerAnimated:YES completion:nil];
//    }]];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [controller dismissViewControllerAnimated:YES completion:nil];
//    }]];

//    [controller presentViewController:alertController animated:YES completion:nil];
    
//    [_statusTimer invalidate];
    NSString *msg = [NSString stringWithFormat:@"UnSuccessful"];
    
    [[[UIAlertView alloc] initWithTitle:@"Transaction Cancel" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    [self setNavigationBarHidden:true];
    [controller.navigationController popViewControllerAnimated:YES];

    //    [[[UIAlertView alloc] initWithTitle:@"Transaction Cancel" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    //    [self sendEventWithName:@"PayTMResponse" body:@{@"status":@"Cancel", @"response":msg}];
    //    [controller dismissViewControllerAnimated:YES completion:nil];
}

//Called when a required parameter is missing.
-(void)errorMisssingParameter:(PGTransactionViewController *)controller error:(NSError *) error {
//    [controller dismissViewControllerAnimated:YES completion:nil];
//    [self setNavigationBarHidden:true];
    [controller.navigationController popViewControllerAnimated:YES];
    
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
