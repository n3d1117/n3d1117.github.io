#import <ifaddrs.h>
#import <net/if.h>

// ___________________________________________________________________________________

/* NETWORK SPEED (by julioverne) */

static const long kilobytes = 1 << 10;
static const long megabytes = 1 << 20;
static const long gigabytes = 1 << 30;

NSString* bytesFormat(long bytes) {
	@autoreleasepool {
		if (bytes < 0 || bytes < kilobytes) {
			return @"0.00K/s";
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

long getBytesTotal() {
	@autoreleasepool {
		struct ifaddrs *ifa_list = 0, *ifa;
		if (getifaddrs(&ifa_list) == -1) {
			return 0;
		}
		
		uint32_t iBytes = 0;
		uint32_t oBytes = 0;
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
			iBytes += if_data->ifi_ibytes;
			oBytes += if_data->ifi_obytes;
		}
		
		freeifaddrs(ifa_list);
		return iBytes + oBytes;
	}
}

// ___________________________________________________________________________________

/* Detect when device is unlocked */

static BOOL isDeviceUnlocked = YES;
%hook SBCoverSheetPresentationManager
-(void)setHasBeenDismissedSinceKeybagLock:(BOOL)hasBeenDismissed {
	%orig;
	isDeviceUnlocked = hasBeenDismissed;
}
%end

// ___________________________________________________________________________________

static NSAttributedString* cachedAttributedString;
static NSDictionary* attributes1;
static NSDictionary* attributes2;
static NSDateFormatter* dateFormatter;
static NSDateFormatter* df;
static long oldSpeed;

static NSMutableAttributedString* formattedAttributedString() {
	NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] init];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	if([[dateFormatter dateFormat] rangeOfString:@"a"].location != NSNotFound) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"h:mm"];
		NSString* date = [df stringFromDate: [NSDate date]];
		date = [date stringByAppendingString: @"\n"];
		NSAttributedString* first = [[NSAttributedString alloc] initWithString:date attributes:attributes1];
		[attributedString appendAttributedString: first];
	} else {
    	NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"HH:mm"];
		NSString* date = [df stringFromDate: [NSDate date]];
		date = [date stringByAppendingString: @"\n"];
		NSAttributedString* first = [[NSAttributedString alloc] initWithString:date attributes:attributes1];
		[attributedString appendAttributedString: first];
	}
	
	// Speed
	long nowData = getBytesTotal();
	long dataDiff = nowData-oldSpeed;
	oldSpeed = nowData;
	NSString* formattedBytes = bytesFormat(dataDiff);
	NSAttributedString* second = [[NSAttributedString alloc] initWithString:formattedBytes attributes:attributes2];
	[attributedString appendAttributedString: second];

	return attributedString;
}

// ___________________________________________________________________________________

/* Status bar hooks */

@interface _UIStatusBarStringView: UILabel
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) NSTextAlignment textAlignment;
@property(nonatomic) BOOL adjustsFontSizeToFitWidth;
@property (nullable, nonatomic, copy) NSAttributedString* attributedText;
-(void)setText:(NSString*)arg1;
@end

%hook _UIStatusBarStringView

// prevent weird resizes
- (void)setFont:(UIFont*)arg1 {
	if (![self.text containsString:@":"]) {
		%orig(arg1);
	}
}

-(id)initWithFrame:(CGRect)arg1 {
	%orig;
	self.numberOfLines	= 2;
	self.textAlignment = NSTextAlignmentCenter;
	[NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer*timer) {
		if (isDeviceUnlocked && self && self.window != nil && [self.text containsString: @":"]) {
			self.adjustsFontSizeToFitWidth = NO;
			self.attributedText = cachedAttributedString;
		}
	}];
	return self;
}

- (void)setText:(NSString*)text {
	if ([text containsString:@":"]) {
		self.adjustsFontSizeToFitWidth = NO;
		self.attributedText = cachedAttributedString;
	} else {
		%orig(text);
	}
}

%end


// ___________________________________________________________________________________

/* Resize pill view when in hotspot/call to fit text */

@interface _UIStatusBarPillView: UIView
@property (copy) CALayer* pulseLayer;
@end

%hook _UIStatusBarPillView

- (void)setCenter:(CGPoint)point {
	point.y = 19.3;
	self.frame = CGRectMake(0, 0, self.frame.size.width, 31);
	self.pulseLayer.frame = CGRectMake(0, 0, self.frame.size.width, 31);
	%orig(point);
}

%end

@interface _UIStatusBarRoundedCornerView: UIView
@end

%hook _UIStatusBarRoundedCornerView

- (void)setCenter:(CGPoint)point {
	point.y = 19.3;
	self.frame = CGRectMake(0, 0, self.frame.size.width+2, 31);
	%orig(point);
}

%end

// ___________________________________________________________________________________

%ctor {
	@autoreleasepool {

		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"HH:mm"];
		
		attributes1 = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: 13] };
		attributes2 = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: 9] };
		
		cachedAttributedString = formattedAttributedString();
		
		[NSTimer scheduledTimerWithTimeInterval:0.9 repeats:YES block:^(NSTimer* timer) {
			if (isDeviceUnlocked) {
				cachedAttributedString = formattedAttributedString();
			}
		}];
	}
}