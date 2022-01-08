#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* System wide black keyboard */
%hook UIKBRenderConfig
-(void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end

/* Hide 'No Older Notifications' from lockscreen */
%hook NCNotificationListSectionRevealHintView
-(void)_layoutRevealHintTitle {}
%end

/* Hide Do not disturb notification from lockscreen */
%hook DNDNotificationsService
-(void)_queue_postOrRemoveNotificationWithUpdatedBehavior:(BOOL)arg1 significantTimeChange:(BOOL)arg2 {}
%end

/* Hide 'Press home to open' label in lockscreen */
%hook CSFixedFooterView
-(void)setCallToActionLabel:(id)arg1 {}
%end

/* Hide 'swipe up to open' label in lockscreen */
%hook CSTeachableMomentsContainerViewController
-(void)_updateText:(NSString *)text { %orig(@""); }
%end

/* Hide lockscreen page dots */
%hook CSPageControl
-(void)setAlpha:(double)alpha { %orig(0); }
%end

/* Show battery percentage (by sarah) */
%hook _UIBatteryView 
-(void)setShowsPercentage:(BOOL)arg1 { %orig(YES); }
%end 

%hook _UIStatusBarStringView  
-(void)setText:(NSString *)text {
	if (![text containsString:@"%"]) %orig(text);
}
%end

/* Hide control center grabber in LS */
%hook CSTeachableMomentsContainerView
-(void)setControlCenterGrabberView:(id)arg {}
%end

/* Hide camera/flashlight in LS */
%hook CSQuickActionsViewController
-(bool)hasFlashlight { return NO; }
-(bool)hasCamera { return NO; }
%end

/* Hide home grabber in LS */
%hook MTStaticColorPillView
-(void)setPillColor:(UIColor *)arg { %orig([UIColor clearColor]); }
%end

/* Hide status bar breadcrumbs */
%hook SBDeviceApplicationSceneStatusBarBreadcrumbProvider
+(bool)_shouldAddBreadcrumbToActivatingSceneEntity:(id)arg1 sceneHandle:(id)arg2 withTransitionContext:(id)arg3 { return NO; }
%end

/* Disable App Library */
%hook SBIconController
-(BOOL)isAppLibrarySupported { return NO; }
%end

/* Remove Search Bar from widgets page - thanks to @insan1d */
%hook SBTodayViewSpotlightPresenter
-(void)_setUpSearchBar {}
-(void)_beginRequiringSearchBarPortalViewForReason:(id)arg1 {}
%end

/* Thiccer LS font size - goes well with Compactor tweak - thanks to @insan1d */
%hook SBFLockScreenDateView
+(UIFont *)timeFont { return [UIFont systemFontOfSize:80 weight:UIFontWeightLight]; }
%end