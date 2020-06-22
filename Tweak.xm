bool disableGestures = NO;

@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton;
@property (nonatomic, retain) UIControl *cameraButton;
@end

%group SpringBoard
    // Enable home gestures
    %hook BSPlatform
    - (NSInteger)homeButtonType {
        return 2;
    }
    %end

    // Fix quick actions view in lockscreen
    %hook CSQuickActionsView
    - (void)_layoutQuickActionButtons {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        int inset = [self _buttonOutsets].top;

        [self flashlightButton].frame = CGRectMake(46, screenBounds.size.height - 90 - inset, 50, 50);
        [self cameraButton].frame = CGRectMake(screenBounds.size.width - 96, screenBounds.size.height - 90 - inset, 50, 50);
    }
    %end

    // Hidden StatusBar in ControlCenter
    %hook CCUIStatusBarStyleSnapshot
    -(BOOL)isHidden {
        return YES;
    }
    %end

    %hook CCUIOverlayStatusBarPresentationProvider
    - (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
        return;
    }
    %end
%end

// Disable gestures when keyboard is actived
%group disableGesturesWhenKeyboard
    %hook SBFluidSwitcherGestureManager
    -(void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3  {
        if (!disableGestures)
            %orig;
    }
    %end
%end
%group newDisableGesturesWhenKeyboard
    //iOS 13.4
    %hook SBFluidSwitcherGestureManager
    -(void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3 andGesture:(id)arg4 {
        if (!disableGestures)
            %orig;
    }
    %end
%end

// Restore Keyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    orig.bottom = 0;
    orig.left = 0;
    orig.right = 0;
    return orig;
}
%end

%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end

%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
    return %orig(1);
}
%end

int applicationDidFinishLaunching = 2;

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray *lockHome = @[@104, @101];
    NSArray *lockVol = @[@104, @102, @103];
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
    return %orig(arg1,1,arg3,arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1,1);
}
%end

%hook SBLockHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(long long)arg7 createGestures:(_Bool)arg8 {
    return %orig(arg1,arg2,arg3,arg4,arg5,arg6,1,arg8);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(long long)arg6 {
    return %orig(arg1,arg2,arg3,arg4,arg5,1);
}
%end

%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
    return %orig(arg1,arg2,1);
}
%end

%ctor {
    @autoreleasepool {
        if ([[[NSProcessInfo processInfo] processName] isEqualToString:@"SpringBoard"]) {
            %init(SpringBoard);
            [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                       disableGestures = true;
                    }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                        disableGestures = false;
                    }];
            if (@available(iOS 13.4, *)) {
                %init(newDisableGesturesWhenKeyboard);
            } else {
                %init(disableGesturesWhenKeyboard);
            }
        }
        %init(_ungrouped);
    }
}
