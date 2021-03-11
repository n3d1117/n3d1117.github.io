#import <LocalAuthentication/LocalAuthentication.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ifaddrs.h>
#import <net/if.h>
#import "Tweak.h"

// ___________________________________________________________________________________

/* Preferences */

BOOL enabled;
BOOL wantsAddSecondsToClock;
BOOL showBytes;
BOOL hideWhenEmpty;
BOOL hideBreadcrumbs;
BOOL usesMonospacedFont;
BOOL separatedUpDown;
BOOL showArrows;
BOOL downloadFirst;
int fontSize1;
int fontSize2;
CGFloat refreshInterval;

// ___________________________________________________________________________________

/* Utils */

static BOOL hasDeviceNotch() {
	if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		return NO;
	} else {
		LAContext* context = [[LAContext alloc] init];
		[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
		return [context biometryType] == LABiometryTypeFaceID;
	}
}

static BOOL has24HourClock() {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setLocale:[NSLocale currentLocale]];
	[df setDateStyle:NSDateFormatterNoStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [df stringFromDate:[NSDate date]];
	NSRange amRange = [dateString rangeOfString:[df AMSymbol]];
	NSRange pmRange = [dateString rangeOfString:[df PMSymbol]];
	return (amRange.location == NSNotFound && pmRange.location == NSNotFound);
}

// ___________________________________________________________________________________

/* NETWORK SPEED (by julioverne) */

static const long kilobytes = 1 << 10;
static const long megabytes = 1 << 20;
static const long gigabytes = 1 << 30;

NSString* bytesFormat(long bytes) {
	@autoreleasepool {
		if (bytes <= 0) {
			if (hideWhenEmpty)
				return @" ";
			if (showBytes)
				return @"0.00B/s";
			return @"0.00K/s";
		}
		if (bytes < kilobytes) {
			if (showBytes) {
				return [NSString stringWithFormat:@"%.2fB/s", (double)bytes];
			} else {
				if (hideWhenEmpty)
					return @" ";
				return @"0.00K/s";
			}
		}
		if (bytes < megabytes) {
			return [NSString stringWithFormat:@"%.2fK/s", (double)bytes / kilobytes];
		}
		if (bytes < gigabytes) {
			return [NSString stringWithFormat:@"%.2fM/s", (double)bytes / megabytes];
		}
		return [NSString stringWithFormat:@"%.2fG/s", (double)bytes / gigabytes];
	}
}

static long downloadBytes;
static long uploadBytes;

void getBytesTotal() {
	@autoreleasepool {
		struct ifaddrs *ifa_list = 0, *ifa;
		if (getifaddrs(&ifa_list) == -1) {
			return;
		}
		downloadBytes = 0;
		uploadBytes = 0;
		for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
			if (AF_LINK != ifa->ifa_addr->sa_family) {
				continue;
			}
			if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) {
				continue;
			}
			if (ifa->ifa_data == 0) {
				continue;
			}
			struct if_data *if_data = (struct if_data *)ifa->ifa_data;
			uploadBytes += if_data->ifi_obytes;
			downloadBytes += if_data->ifi_ibytes;
		}
		
		freeifaddrs(ifa_list);
	}
}

// ___________________________________________________________________________________

/* Detect when device is unlocked */

static BOOL isDeviceUnlocked = YES;
%hook SBCoverSheetPresentationManager
-(void)setHasBeenDismissedSinceKeybagLock:(BOOL)hasBeenDismissed {
	%orig;
	if (enabled)
		isDeviceUnlocked = hasBeenDismissed;
}
%end

// ___________________________________________________________________________________

/* Byte string formatter */

static NSAttributedString* cachedAttributedString;
static NSDictionary* attributes1;
static NSDictionary* attributes2;
static NSDateFormatter* dateFormatter;
static long oldSpeedU;
static long oldSpeedD;

static NSMutableAttributedString* formattedAttributedString() {
	NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] init];
	
	// Time
	NSString* date = [dateFormatter stringFromDate: [NSDate date]];
	if (hasDeviceNotch()) {
		date = [date stringByAppendingString:@"\n"];
	} else {
		date = [date stringByAppendingString:@" "];
	}
	NSAttributedString* first = [[NSAttributedString alloc] initWithString:date attributes:attributes1];
	[attributedString appendAttributedString: first];
	
	// Speed
	getBytesTotal();
	NSString* formattedBytes;
	
	long dataDiffD = downloadBytes-oldSpeedD;
	long dataDiffU = uploadBytes-oldSpeedU;
		
	oldSpeedD = downloadBytes;
	oldSpeedU = uploadBytes;
	
	if (separatedUpDown) {
			
		NSString* formattedBytesD = bytesFormat(dataDiffD);
		NSString* formattedBytesU = bytesFormat(dataDiffU);
		
		if (hideWhenEmpty && [formattedBytesD isEqual:@" "] && [formattedBytesU isEqual:@" "])
			formattedBytes = @" ";
		else if (hideWhenEmpty && [formattedBytesD isEqual:@" "])
			formattedBytes = [NSString stringWithFormat:@"↑ %@", formattedBytesU];
		else if (hideWhenEmpty && [formattedBytesU isEqual:@" "])
			formattedBytes = [NSString stringWithFormat:@"↓ %@", formattedBytesU];
		else if (downloadFirst) {
			if (showArrows) {
				formattedBytes = [NSString stringWithFormat:@"↓ %@\n↑ %@", formattedBytesD, formattedBytesU];
			} else {
				formattedBytes = [NSString stringWithFormat:@"%@\n%@", formattedBytesD, formattedBytesU];
			}
		} else {
			if (showArrows)
				formattedBytes = [NSString stringWithFormat:@"↑ %@\n↓ %@", formattedBytesU, formattedBytesD];
			else
				formattedBytes = [NSString stringWithFormat:@"%@\n%@", formattedBytesU, formattedBytesD];
		}
	} else {
		
		long diff = dataDiffD + dataDiffU;
		NSString* formatted = bytesFormat(diff);
		long delta = 1024;
		
		if (showArrows) {
			if (hideWhenEmpty && [formatted isEqual:@" "])
				formattedBytes = formatted;
			else if (dataDiffU >= dataDiffD && (dataDiffU-dataDiffD)>delta) 
				formattedBytes = [NSString stringWithFormat:@"↑ %@", bytesFormat(dataDiffU)];
			else
				formattedBytes = [NSString stringWithFormat:@"↓ %@", bytesFormat(dataDiffD)];
		} else {
			formattedBytes = formatted;	
		}
	}
	

	NSAttributedString* second = [[NSAttributedString alloc] initWithString:formattedBytes attributes:attributes2];
	[attributedString appendAttributedString: second];

	return attributedString;
}

// ___________________________________________________________________________________

/* Status bar hooks */

%hook _UIStatusBarStringView

// prevent weird resizes
- (void)setFont:(UIFont*)arg1 {
	if (!enabled || ![self.text containsString:@":"]) {
		%orig(arg1);
	}
}

-(id)initWithFrame:(CGRect)arg1 {
	%orig;
	if (enabled) {
		if (hasDeviceNotch()) {
			if (separatedUpDown) {
				self.numberOfLines = 3;
			} else {
				self.numberOfLines = 2;
			}
		} else {
			self.numberOfLines = 1;
		}
		self.adjustsFontSizeToFitWidth = NO;
		self.textAlignment = NSTextAlignmentCenter;
		[NSTimer scheduledTimerWithTimeInterval:refreshInterval repeats:YES block:^(NSTimer*timer) {
			if (isDeviceUnlocked && self && self.window != nil && [self.text containsString: @":"]) {
				self.adjustsFontSizeToFitWidth = NO;
				self.attributedText = cachedAttributedString;
			}
		}];
	}
	return self;
}

- (void)setText:(NSString*)text {
	if (enabled && [text containsString:@":"]) {
		self.adjustsFontSizeToFitWidth = NO;
		self.attributedText = cachedAttributedString;
	} else {
		%orig(text);
	}
}

%end


// ___________________________________________________________________________________

/* Resize pill view when in hotspot/call to fit text */

%group gNotchFixes

%hook _UIStatusBarPillView
- (void)setCenter:(CGPoint)point {
	if (enabled) {
		point.y = 19.3;
		self.frame = CGRectMake(0, 0, self.frame.size.width, 31);
		self.pulseLayer.frame = CGRectMake(0, 0, self.frame.size.width, 31);
	}
	%orig(point);
}
%end

%hook _UIStatusBarRoundedCornerView
- (void)setCenter:(CGPoint)point {
	if (enabled) {
		point.y = 19.3;
		self.frame = CGRectMake(0, 0, self.frame.size.width+2, 31);
	}
	%orig(point);
}
%end

%end

// ___________________________________________________________________________________

/* Hide status bar breadcrumbs */
%hook SBDeviceApplicationSceneStatusBarBreadcrumbProvider
+(bool)_shouldAddBreadcrumbToActivatingSceneEntity:(id)arg1 sceneHandle:(id)arg2 withTransitionContext:(id)arg3 { 
	if (enabled && hideBreadcrumbs)
		return FALSE; 
	return %orig;
}
%end

// ___________________________________________________________________________________

/* Preferences */

void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/net.sarahh12099.runawayprefs.plist"];
	if (prefs) {
		enabled = [[prefs objectForKey:@"TweakEnabled"] boolValue];
		wantsAddSecondsToClock = [[prefs objectForKey:@"AddSecondsToClock"] boolValue];
		showBytes = [[prefs objectForKey:@"ShowBytes"] boolValue];
		hideWhenEmpty = [[prefs objectForKey:@"HideWhenEmpty"] boolValue];
		hideBreadcrumbs = [[prefs objectForKey:@"HideBreadcrumbs"] boolValue];
		separatedUpDown = [[prefs objectForKey:@"SeparatedUpDown"] boolValue];
		showArrows = [[prefs objectForKey:@"ShowArrows"] boolValue];
		downloadFirst = [[prefs objectForKey:@"DownloadFirst"] boolValue];
		usesMonospacedFont = [[prefs objectForKey:@"UsesMonospacedFont"] boolValue];
		fontSize1 = [[prefs objectForKey:@"FontSize1"] intValue];
		fontSize2 = [[prefs objectForKey:@"FontSize2"] intValue];
		refreshInterval = [[prefs objectForKey:@"RefreshInterval"] floatValue];
	}
}

void initPrefs() {
	NSString *path = @"/User/Library/Preferences/net.sarahh12099.runawayprefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/runawayprefs.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

// ___________________________________________________________________________________

%ctor {
	@autoreleasepool {

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("net.sarahh12099.runawayprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		initPrefs();
		loadPrefs();
		
		if (enabled) {

			dateFormatter = [[NSDateFormatter alloc] init];
			if (has24HourClock()) {
				if (wantsAddSecondsToClock) {
					[dateFormatter setDateFormat:@"HH:mm:ss"];
				} else {
					[dateFormatter setDateFormat:@"HH:mm"];
				}
			} else {
				if (wantsAddSecondsToClock) {
					[dateFormatter setDateFormat:@"h:mm:ss"];
				} else {
					[dateFormatter setDateFormat:@"h:mm"];
				}
			}

			if (hasDeviceNotch()) {
				%init(gNotchFixes);
				attributes1 = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: fontSize1] };
				if (usesMonospacedFont) {
					attributes2 = @{ NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize: fontSize2 weight: UIFontWeightRegular] };	
				} else {
					attributes2 = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: fontSize2] };
				}
			} else {
				attributes1 = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: 13] };
				if (usesMonospacedFont) {
					attributes2 = @{ NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize: 12 weight: UIFontWeightRegular] };	
				} else {
					attributes2 = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: 12] };
				}
			}
			
			cachedAttributedString = formattedAttributedString();
			
			[NSTimer scheduledTimerWithTimeInterval:refreshInterval repeats:YES block:^(NSTimer* timer) {
				if (isDeviceUnlocked) {
					cachedAttributedString = formattedAttributedString();
				}
			}];
			%init(_ungrouped);
			
		}
	}
}