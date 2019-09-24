long _dismissalSlidingMode = 0;
bool originalButton;
long _homeButtonType = 1;
int applicationDidFinishLaunching;

// Enable home gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
	_homeButtonType = %orig;
	if (originalButton) {
		originalButton = NO;
		return %orig;
	} else {
		return 2;
	}
}
%end

// Workaround for TouchID respring bug
%hook SBCoverSheetSlidingViewController
- (void)_finishTransitionToPresented:(_Bool)arg1 animated:(_Bool)arg2 withCompletion:(id)arg3 {
	if ((_dismissalSlidingMode != 1) && (arg1 == 0)) {
		return;
	} else {
		%orig;
	}
}
- (long long)dismissalSlidingMode {
	_dismissalSlidingMode = %orig;
	return %orig;
}
%end

// Restore button to invoke Siri
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
	return %orig(_homeButtonType, arg2);
}
%end
%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
	return %orig(_homeButtonType);
}
%end

// Restore screenshot shortcut
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	applicationDidFinishLaunching = 2;
	%orig;
}
%end
%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
	NSArray * lockHome = @[@104, @101];
	NSArray * lockVol = @[@104, @102, @103];
	if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
		%orig(lockHome);
		applicationDidFinishLaunching--;
		return;
	}
	%orig;
}
%end
%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
	if (applicationDidFinishLaunching == 1) {
		applicationDidFinishLaunching--;
		return;
	}
	%orig;
}
%end
%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
	return %orig(arg1, _homeButtonType, arg3, arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
	return %orig(arg1, _homeButtonType);
}
%end

// Force close app without long-pressing card
%hook SBAppSwitcherSettings
- (long long)effectiveKillAffordanceStyle {
	return 2;
}
%end
// Enable simutaneous scrolling and dismissing
%hook SBFluidSwitcherViewController
- (double)_killGestureHysteresis {
	double orig = %orig;
	return orig == 30 ? 10 : orig;
}
%end

@interface UIView (SpringBoardAdditions)
- (void)sb_removeAllSubviews;
@end

@interface SBDashBoardQuickActionsView : UIView
- (void)_layoutQuickActionButtons;
- (void)handleButtonPress:(id)arg1 ;
@end

%hook SBDashBoardQuickActionsView
- (void)_layoutQuickActionButtons {
    %orig;
    for (UIView *subview in self.subviews) {
    if (subview.frame.origin.x < 50) {
        CGRect flashlight = subview.frame;
        CGFloat flashlightOffset = subview.alpha > 0 ? (flashlight.origin.y - 90) : flashlight.origin.y;
        subview.frame = CGRectMake(46, flashlightOffset, 50, 50);
    } else {
        CGFloat _screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGRect camera = subview.frame;
        CGFloat cameraOffset = subview.alpha > 0 ? (camera.origin.y - 90) : camera.origin.y;
        subview.frame = CGRectMake(_screenWidth - 96, cameraOffset, 50, 50);
    }
    [subview sb_removeAllSubviews];
    #pragma clang diagnostic ignored "-Wunused-value"
    [subview init];
    }
}
%end

// Fix control center from crashing on iOS 12.
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end
