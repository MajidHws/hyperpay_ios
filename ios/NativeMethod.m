//
//  NativeMethod.m
//  payment_demo
//
//  Created by MiGoo on 8/22/20.
//
#import "NativeMethod.h"
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>
#import <OPPWAMobile/OPPWAMobile.h>


@implementation NativeMethod

RCTResponseSenderBlock onDoneClick;
RCTResponseSenderBlock onCancelClick;
UIViewController *rootViewController;
NSString *isRedirect;
OPPPaymentProvider *provider;
NSDictionary *checkoutID;
OPPCheckoutProvider *checkoutProvider;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}

RCT_EXPORT_METHOD(openHyperPay:(NSDictionary *)indic createDialog:(RCTResponseSenderBlock)doneCallback createDialog:(RCTResponseSenderBlock)cancelCallback) {
  onDoneClick = doneCallback;
  onCancelClick = cancelCallback;
  NSArray *events = @[];

//  if ([indic[@"is_sandbox"] isEqualToString:@"1"]) {
    provider = [OPPPaymentProvider paymentProviderWithMode:OPPProviderModeTest];
//  } else {
//    provider = [OPPPaymentProvider paymentProviderWithMode:OPPProviderModeLive];
//  }

  OPPCheckoutSettings *checkoutSettings = [[OPPCheckoutSettings alloc] init];

  // Set available payment brands for your shop
  checkoutSettings.paymentBrands = @[@"VISA", @"MASTER"];
  // Set shopper result URL
  checkoutSettings.shopperResultURL = @"com.simicart.enterprise.payments://result";

  checkoutProvider = [OPPCheckoutProvider checkoutProviderWithPaymentProvider:provider checkoutID:indic[@"checkoutId"]
                                                                                          settings:checkoutSettings];
  dispatch_async(dispatch_get_main_queue(), ^{
    [checkoutProvider presentCheckoutForSubmittingTransactionCompletionHandler:^(OPPTransaction * _Nullable transaction, NSError * _Nullable error) {
      if (error) {
        // Executed in case of failure of the transaction for any reason
        if (isRedirect && ![isRedirect isEqualToString:@"1"]) {
          onCancelClick(@[@"cancel", events]);
        }
      } else if (transaction.type == OPPTransactionTypeSynchronous)  {
        // Send request to your server to obtain the status of the synchronous transaction
        // You can use transaction.resourcePath or just checkout id to do it
        NSDictionary *responeDic = @{@"resourcePath" : transaction.resourcePath};
        onDoneClick(@[responeDic, events]);
        NSLog(@"%@", transaction.resourcePath);
      } else {
        // The SDK opens transaction.redirectUrl in a browser
        // See 'Asynchronous Payments' guide for more details

      }
    } cancelHandler:^{
        onCancelClick(@[@"cancel", events]);

      // Executed if the shopper closes the payment page prematurely
    }];
     });
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStatusOder:) name:@"getStatusOrder" object:nil];
    }
    return self;
}

- (void)getStatusOder:(NSNotification*)noti{
  [checkoutProvider dismissCheckoutAnimated:YES completion:^{
    isRedirect = @"1";
    NSURL *url = noti.object;
    NSString *urlString = [url absoluteString];
    NSLog(@"%@", urlString);
    if (![urlString isEqualToString:@"com.simicart.enterprise.payments://result"]) {
      NSArray *events = @[];
      NSDictionary *responeDic = @{@"url" : urlString};
      onDoneClick(@[responeDic, events]);
    }
  }];
}


@end
