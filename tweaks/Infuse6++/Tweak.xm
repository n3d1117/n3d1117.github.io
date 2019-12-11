%hook FCInAppPlaybackStrategy
-(BOOL)hasPro { return TRUE; }
%end

%hook FCFileSyncViewController
-(BOOL)hasPro { return TRUE; }
%end

%hook FCItemsViewController
-(BOOL)hasPro { return TRUE; }
%end

%hook FCInAppPurchaseServiceFullPro
-(BOOL)hasValidReceipt { return TRUE; }
-(BOOL)isFeaturePurchased:(long long)fp4 tillDate:(id*)fp8 { return TRUE; }
%end

%hook FCInAppPurchaseServiceMobile
-(BOOL)hasValidReceipt { return TRUE; }
-(BOOL)isFeaturePurchased:(long long)fp4 tillDate:(id*)fp8 { return TRUE; }
%end

%hook FCInAppPurchaseServiceBase
-(id)subscriptionExpirationDate { return NULL; }
-(BOOL)hasValidReceipt { return TRUE; }
-(BOOL)isFeaturePurchased:(long long)fp4 { return TRUE; }
-(BOOL)isFeaturePurchased:(long long)fp4 tillDate:(id*)fp8 { return TRUE; }
%end

%hook FCInAppPurchaseServiceDummy
-(BOOL)hasValidReceipt { return TRUE; }
-(BOOL)isFeaturePurchased:(long long)fp4 tillDate:(id*)fp8 { return TRUE; }
%end

%hook FCInAppPurchaseReceipt
-(id)subscriptionExpirationDate { return NULL; }
%end



