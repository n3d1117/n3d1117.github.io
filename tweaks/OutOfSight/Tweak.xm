/* System wide black keyboard */
%hook UIKBRenderConfig
-(void)setLightKeyboard:(BOOL)arg1 { %orig(FALSE); }
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

/* Hide lockscreen page dots */
%hook CSPageControl
-(void)_setIndicatorImage:(id)arg1 toEnabled:(BOOL)arg2 index:(NSInteger)arg3 {}
%end

/* iPhone: show battery percentage (by sarah) */
%hook _UIBatteryView 
-(void)setShowsPercentage:(BOOL)arg1 { %orig(TRUE); }
%end 

%hook _UIStatusBarStringView  
-(void)setText:(NSString *)text {
	if (![text containsString:@"%"]) %orig(text);
}     
%end

/* iPhone: no "swipe up to open" */
%hook CSTeachableMomentsContainerViewController
-(void)_updateText:(NSString *)text { %orig(@""); }
%end

/* iPhone: hide control center grabber in LS */
%hook CSTeachableMomentsContainerView
-(void)setControlCenterGrabberView:(id)arg {}
%end

/* iPhone: disable Today view in NC/LS */
%hook SBMainDisplayPolicyAggregator
-(bool)_allowsCapabilityLockScreenTodayViewWithExplanation:(id*)arg1 { return FALSE; }
%end

/* iPhone: hide camer/flashlight in LS */
%hook CSQuickActionsViewController
-(bool)hasFlashlight { return FALSE; }
-(bool)hasCamera { return FALSE; }
%end

/* iPhone: hide home grabber in LS */
%hook MTStaticColorPillView
-(void)setPillColor:(UIColor *)arg { %orig([UIColor clearColor]); }
%end

/* Hide status bar breadcrumbs */
%hook SBDeviceApplicationSceneStatusBarBreadcrumbProvider
+(bool)_shouldAddBreadcrumbToActivatingSceneEntity:(id)arg1 sceneHandle:(id)arg2 withTransitionContext:(id)arg3 { return FALSE; }
%end

/* Hide carrier */
//%hook _UIStatusBarDataCellularEntry
//-(void)setString:(NSString*)text { %orig(@""); }
//%end