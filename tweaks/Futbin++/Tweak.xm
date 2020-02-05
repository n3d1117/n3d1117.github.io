@interface ALRootViewController
-(void)hideAdMobForPremium;
@end

%hook ALRootViewController

-(void)viewWillAppear:(BOOL)arg1 {
	%orig;
	[self hideAdMobForPremium];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ )(void))completion {
	NSString *name = NSStringFromClass([viewControllerToPresent class]);
	if (([name isEqualToString:@"UIAlertController"]) && ([[(UIAlertController*)viewControllerToPresent title] isEqualToString:@"Old version"])) {
		return;
	}
	%orig;
}
%end

@interface ALAdView
-(void)setAlpha:(id)arg;
@end

%hook ALAdView
- (void)layoutSubviews {
	[self setAlpha: 0];
}
%end

/*%hook GADAd 
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

%hook ALAutoLayoutVideoViewController
-(id)initWithSdk:(id)arg2 currentAd:(id)arg3 currentPlacement:(id)arg4 wrapper:(id)arg5 { return nil; }
%end

%hook ALVASTVideoViewController
-(id)initWithSdk:(id)arg2 currentAd:(id)arg3 currentPlacement:(id)arg4 wrapper:(id)arg5 { return nil; }
%end*/

%hook GADAdSource
- (BOOL)invalidated {
	return 1;
}
%end

%hook ALLeftMenuViewController
-(void)switchMode:(id)sender {
	if (@available(iOS 13.0, *)) {
		UIWindow * window = [[[UIApplication sharedApplication] windows] firstObject];
		if ([(UISwitch*)sender isOn]) {
			window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDarkMode"];
		} else {
			window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
			[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"isDarkMode"];
		}
	} else {
		%orig;
	}
}
%end

%ctor {
	@autoreleasepool {
		%init(ALRootViewController = NSClassFromString(@"Futbin.ALRootViewController"), ALLeftMenuViewController = NSClassFromString(@"Futbin.ALLeftMenuViewController"));
	}
}