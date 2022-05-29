/* Source: https://gist.github.com/level3tjg/813f7269a405b00203484382da18d3bf */
/* Credits: level3tjg */

#import <MobileGestalt/MobileGestalt.h>

NSString *deviceClass;

%hook XDCDevice
- (NSString *)productType {
    return deviceClass;
}
%end

%hook Device
- (NSArray<NSString *> *)productVariants {
    return @[ deviceClass ];
}
%end

%hook SSDevice
- (NSString *)productType {
    return deviceClass;
}
- (NSString *)compatibleProductType {
    return deviceClass;
}
%end

%hook AMSDevice
+ (NSString *)productType {
    return deviceClass;
}
+ (NSString *)compatibleProductType {
    return deviceClass;
}
+ (NSString *)_lib_compatibleProductType {
    return deviceClass;
}
%end

%ctor {
    deviceClass = (__bridge NSString *)MGCopyAnswer(kMGDeviceClass, NULL);
}