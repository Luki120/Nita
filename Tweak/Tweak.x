#import "Nita.h"

%group Nita

%hook _UIStatusBarStringView

- (void)setText:(id)arg1 { // set emoji

	%orig;

	if (!replaceTimeSwitch && !([[self originalText] containsString:@":"] || [[self originalText] containsString:@"%"] || [[self originalText] containsString:@"2G"] || [[self originalText] containsString:@"3G"] || [[self originalText] containsString:@"4G"] || [[self originalText] containsString:@"5G"] || [[self originalText] containsString:@"LTE"] || [[self originalText] isEqualToString:@"E"] || [[self originalText] isEqualToString:@"e"])) {
		
		[self getEmojis];

		if (showEmojiSwitch && !showTemperatureSwitch)
			%orig(weatherString);
		else if (showEmojiSwitch && showTemperatureSwitch)
			%orig([NSString stringWithFormat:@"%@ %@", weatherString, [[PDDokdo sharedInstance] currentTemperature]]);
		else if (!showEmojiSwitch && showTemperatureSwitch)
			%orig([NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentTemperature]]);
		else
			%orig(conditions);
	}

	if (replaceTimeSwitch && !([[self originalText] containsString:@"%"] || [[self originalText] containsString:@"2G"] || [[self originalText] containsString:@"3G"] || [[self originalText] containsString:@"4G"] || [[self originalText] containsString:@"5G"] || [[self originalText] containsString:@"LTE"] || [[self originalText] isEqualToString:@"E"] || [[self originalText] isEqualToString:@"e"])) {
		
		[self getEmojis];

		if (showEmojiSwitch && !showTemperatureSwitch)
			%orig(weatherString);
		else if (showEmojiSwitch && showTemperatureSwitch)
			%orig([NSString stringWithFormat:@"%@ %@", weatherString, [[PDDokdo sharedInstance] currentTemperature]]);
		else if (!showEmojiSwitch && showTemperatureSwitch)
			%orig([NSString stringWithFormat:@"%@", [[PDDokdo sharedInstance] currentTemperature]]);
		else
			%orig(conditions);
	}

}

%new
- (void)getEmojis { // get emoji based on condition

	WALockscreenWidgetViewController* weatherWidget = [[PDDokdo sharedInstance] weatherWidget];
	WAForecastModel* currentModel = [weatherWidget currentForecastModel];
	WACurrentForecast* currentCond = [currentModel currentConditions];
	NSInteger currentCode = [currentCond conditionCode];

	NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH.mm"];
    NSString* currentTime = [formatter stringFromDate:[NSDate date]];

    if ([currentTime floatValue] >= 18.00 || [currentTime floatValue] <= 6.00) {
		if (currentCode <= 32) weatherString = @"🌙";
    } else {
        if (currentCode <= 32) weatherString = @"☀️";
    }

	if (currentCode <= 2)
		weatherString = @"🌪";
	else if (currentCode <= 4)
		weatherString = @"⛈";
	else if (currentCode <= 8)
		weatherString = @"🌨";
	else if (currentCode == 9)
		weatherString = @"🌧";
	else if (currentCode == 10)
		weatherString = @"🌨";
	else if (currentCode <= 12)
		weatherString = @"🌧";
	else if (currentCode <= 18)
		weatherString = @"🌨";
	else if (currentCode <= 22)
		weatherString = @"🌫";
	else if (currentCode <= 24)
		weatherString = @"💨";
	else if (currentCode == 25)
		weatherString = @"❄️";
	else if (currentCode == 26)
		weatherString = @"☁️";
	else if (currentCode <= 28)
		weatherString = @"🌥";
	else if (currentCode <= 30)
		weatherString = @"⛅️";
	else if (currentCode <= 34)
		weatherString = @"🌤";
	else if (currentCode == 35)
		weatherString = @"🌧";
	else if (currentCode == 36)
		weatherString = @"🔥";
	else if (currentCode <= 38)
		weatherString = @"🌩";
	else if (currentCode == 39)
		weatherString = @"🌦";
	else if (currentCode == 40)
		weatherString = @"🌧";
	else if (currentCode <= 43)
		weatherString = @"🌨";
	else
		weatherString = @"N/A";

}

%end

%hook SBDeviceApplicationSceneStatusBarBreadcrumbProvider

+ (BOOL)_shouldAddBreadcrumbToActivatingSceneEntity:(id)arg1 sceneHandle:(id)arg2 withTransitionContext:(id)arg3 { // hide breadcrumbs

	return !hideBreadcrumbsSwitch;

}

%end

%hook SBControlCenterController

- (void)_willPresent { // update data when control center was opened

	%orig;

	[[PDDokdo sharedInstance] refreshWeatherData];

}

%end

%hook CSCoverSheetViewController

- (void)viewWillAppear:(BOOL)animated { // update data when lockscreen appears

	%orig;

	[[PDDokdo sharedInstance] refreshWeatherData];

}

%end

%hook SBBacklightController

- (void)turnOnScreenFullyWithBacklightSource:(long long)source { // update data when screen was turned on

	%orig;

	if (![[%c(SBLockScreenManager) sharedInstance] isLockScreenVisible]) return;
	[[PDDokdo sharedInstance] refreshWeatherData];

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.nitapreferences"];

  	[preferences registerBool:&enabled default:nil forKey:@"Enabled"];
	  if (!enabled) return;

	// visibility
	[preferences registerBool:&showEmojiSwitch default:NO forKey:@"showEmoji"];
	[preferences registerBool:&showTemperatureSwitch default:NO forKey:@"showTemperature"];

	// miscellaneous
	[preferences registerBool:&replaceTimeSwitch default:NO forKey:@"replaceTime"];
	[preferences registerBool:&hideBreadcrumbsSwitch default:YES forKey:@"hideBreadcrumbs"];

	%init(Nita);

}