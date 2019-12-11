/* System wide black keyboard */

%hook UIKBRenderConfig
-(void)setLightKeyboard:(BOOL)arg1 { %orig(FALSE); }
%end

%hook UIDevice
-(long long)_keyboardGraphicsQuality { return 10; }
%end

/* Hide 'No Older Notifications' from lockscreen */

%hook NCNotificationListSectionrevealHintView
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
