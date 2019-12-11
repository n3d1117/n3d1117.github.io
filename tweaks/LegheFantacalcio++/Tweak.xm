
/* HIDE ADS */

%hook GADAd 
- (id)init { return nil; }
%end

%hook GADSlot 
- (id)init { return nil; }
%end

%hook GADRequest
- (id)init { return nil; }
%end

%hook GADNativeAd 
- (id)init { return nil; }
%end

%hook GADInterstitial 
- (id)init { return nil; }
%end

%hook AdsBannerView
- (void)checkForPremium {}
- (void)layoutSubviews {
	%orig;
	[self setAlpha: 0];
}
%end

/* _______________ */

/* PREMIUM */

@interface ALRootViewController
-(void)upOnTheLadder;
-(void)rewardBasedVideoAd:(id)p0 didRewardUserWithReward:(id)p1;
@end

%hook RewardedVideoManager
%new
- (void)ayee {}

%new
- (void)upOnTheLadder {
	MSHookIvar<bool>(self, "hasWatchedVideo") = YES;
	[self rewardBasedVideoAd:nil didRewardUserWithReward:nil];
	[MSHookIvar<NSTimer*>(self, "premiumTimer") invalidate];
	MSHookIvar<NSTimer*>(self, "premiumTimer") = [[NSTimer scheduledTimerWithTimeInterval:9999 target:self selector:@selector(ayee) userInfo:nil repeats:NO] retain];
}

-(id)init {
	id original = %orig;
	[self upOnTheLadder];
	return original;
}
%end

/* _______________ */

%ctor {
	@autoreleasepool {
		%init(AdsBannerView = NSClassFromString(@"Leghe.AdsBannerView"), RewardedVideoManager = NSClassFromString(@"Leghe.RewardedVideoManager"));
	}
}