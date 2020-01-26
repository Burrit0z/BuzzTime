/* I'm just going to say...
This project was challenge, but I have been learning obj-c for over a month now,
and I needed a challenge, cause I knew next to nothing other than how to hook
and modify values. I have rewrote and rewrote this multiple times for stability,
speed, optimization, and efficiency. I hope it paid off. However, no software is
bug free. */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <Cephei/HBPreferences.h>
BOOL dpkgInvalid = NO;
//so that the button presses can be counted individually
double buttonPressCountActivator = 0;
double buttonPressCountVolumeUp = 0;
double buttonPressCountVolumeDown = 0;
//activator
BOOL stoppedActivator = NO;
//vol up
BOOL stoppedUp = NO;
//vol up
BOOL stoppedDown = NO;

NSTimer *longPressTimer; //not really the right name for it, but it fires to activate the buzzing/vibrations

//prefs part
double setNumberDelay; // = 0.65 (default)

double activationMethod; //idk if it should be a double, look at the valid values in Root.plist
BOOL tweakEnabled;
BOOL volumeButtonsEnabled;
HBPreferences *preferences;

@interface UIKBTree : NSObject
@property (nonatomic, strong, readwrite) NSString * name;
+ (id)sharedInstance;
+ (id)key;
@end

@interface SBCoverSheetPresentationManager
-(bool)hasBeenDismissedSinceKeybagLock; // Using this to check when the device is on the lock screen. Thanks exoticswingset
+(id)sharedInstance;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
- (void)viewDidDisappear:(BOOL)arg1;
- (void)viewDidAppear:(BOOL)arg1;
@end

#pragma mark TWEAK_GROUP_STARTS
///////////////////
///////////////////

%group tweak //I have an explanation of why I do this later on
void shortVibrate() { //Why I need a seperate function? I don't.
		AudioServicesPlaySystemSound(1521);
}

void longVibrate() {
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	[NSThread sleepForTimeInterval:0.05];
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

///////////////////////////////////
///////////////////////////////////
///////////////////////////////////
#pragma mark hourMethod

void hourVibrate() {
	NSDate * time = [NSDate date];
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"h"];
	long currentTime = ([[outputFormatter stringFromDate:time] integerValue]);

	NSString *currentTimeString = [NSString stringWithFormat:@"%ld", currentTime];
	NSMutableArray * timeArray = [[NSMutableArray alloc] initWithCapacity: 2];
	for (int i = 0; i < [currentTimeString length]; i++) {
	[timeArray addObject: [NSString stringWithFormat:@"%C",
																	 [currentTimeString characterAtIndex:i]]];
			}

	for (int x = 0; x < [timeArray count]; x++) {
		long currentDigit = ([[timeArray objectAtIndex:x] integerValue]);
		long fiveSegmentsForDigit;
		long segmentsForDigit;
		if (currentDigit == 0) {
			fiveSegmentsForDigit = 2;
			segmentsForDigit = 0; //cause otherwise it would add an extra 1 vibration at 10 oclock due to the 1 before it.
		} else {
		fiveSegmentsForDigit = (currentDigit / 5); //This should produce an integer, even though would rarely split evenly
		segmentsForDigit = (currentDigit % 5); //This is the remainder
	  }
		for (long i = 0; i < fiveSegmentsForDigit; i++) {
			//  ^ used a long here because I'm comparing to fiveSegmentsForDigit, a long
			[NSThread sleepForTimeInterval:(setNumberDelay + 0.15)];
			longVibrate();
		}
		if (setNumberDelay < 0.5) { //this fixes one of the short vibrations being cut off
			[NSThread sleepForTimeInterval:(setNumberDelay)];
		}
		for (long i = 0; i < segmentsForDigit; i++) {
			[NSThread sleepForTimeInterval:(setNumberDelay)];
			shortVibrate();
		}
		[NSThread sleepForTimeInterval:(setNumberDelay)];
	}
		[timeArray removeAllObjects];
}

/////////////////////////////////// These really don't need to be seperate
/////////////////////////////////// Especially because they are so simillar
/////////////////////////////////// But it makes things easier later on :D
#pragma mark minuteMethod
void minuteVibrate() {
	NSDate * time = [NSDate date];
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"mm"];
	NSString *currentTime = [outputFormatter stringFromDate:time];
	NSMutableArray * timeArray = [[NSMutableArray alloc] initWithCapacity:[currentTime length]];
	for (int i = 0; i < [currentTime length]; i++) {
	[timeArray addObject: [NSString stringWithFormat:@"%C",
																	 [currentTime characterAtIndex:i]]];
			}
	for (int x = 0; x < [timeArray count]; x++) {
		long currentDigit = ([[timeArray objectAtIndex:x] integerValue]);
		long fiveSegmentsForDigit;
		long segmentsForDigit;
		if (currentDigit == 0) {
			fiveSegmentsForDigit = 2;
			segmentsForDigit = 0;
		} else {
		fiveSegmentsForDigit = (currentDigit / 5); //This should produce an integer, even though would rarely split evenly
		segmentsForDigit = (currentDigit % 5); //This is the remainder, using modulous func
	  }
		for (long i = 0; i < fiveSegmentsForDigit; i++) {
			//  ^ used a long here because I'm comparing to fiveSegmentsForDigit, a long
			[NSThread sleepForTimeInterval:(setNumberDelay + 0.15)];
			longVibrate();
		}
		if (setNumberDelay < 0.5) { //this also fixes one of the short vibrations being cut off
			[NSThread sleepForTimeInterval:(setNumberDelay)];
		}
		for (long i = 0; i < segmentsForDigit; i++) {
			[NSThread sleepForTimeInterval:(setNumberDelay)];
			shortVibrate();
		}
		[NSThread sleepForTimeInterval:(setNumberDelay)];
	}
		[timeArray removeAllObjects];
}

#pragma mark reset_Variables

void resetVariables() {
	//RESETS all important global variales to default to ensure no errors occur
	buttonPressCountActivator = 0;
	buttonPressCountVolumeUp = 0;
	buttonPressCountVolumeDown = 0;
	//activator
	stoppedActivator = NO;
	//vol up
	stoppedUp = NO;
	//vol up
	stoppedDown = NO;
}
#pragma mark DRM

%hook SpringBoard
-(BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)event {
	  SBCoverSheetPresentationManager *lockManager = (SBCoverSheetPresentationManager *)[%c(SBCoverSheetPresentationManager) sharedInstance]; //exoticswingset's method, thx!

		if ((![lockManager hasBeenDismissedSinceKeybagLock]) && tweakEnabled) {
	    for(UIPress *press in event.allPresses.allObjects) {

//General activation method
	      if (press.type == activationMethod && press.force == 1) { //pressed
					buttonPressCountActivator ++;
					stoppedActivator = NO; //this is for each individual press
					if (buttonPressCountActivator == 1) {
						//This is a 0.4 second delay because it takes a bit to activate Accessibility shortcut
						longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(activateAll) userInfo:nil repeats:NO];
					}
				} else if (press.type == activationMethod && press.force == 0) { //released
					stoppedActivator = YES; //THIS MEANS NO LONG PRESS


//Volume Up method
			 } else if (press.type == 102 && press.force == 1) { //pressed
			   buttonPressCountVolumeUp ++;
				 stoppedUp = NO; //this is for each individual press
				 if (buttonPressCountVolumeUp == 1) {
					 longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(activateUp) userInfo:nil repeats:NO];
				 }
			 } else if (press.type == 102 && press.force == 0) { //released
				 stoppedUp = YES; //THIS MEANS NO LONG PRESS


//Volume Down Method
			 } else if (press.type == 103 && press.force == 1) { //pressed
				   buttonPressCountVolumeDown ++;
					 stoppedDown = NO; //this is for each individual press
					 if (buttonPressCountVolumeDown == 1) {
						 longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(activateDown) userInfo:nil repeats:NO];
					 }
				 } else if (press.type == 103 && press.force == 0) { //released
					 stoppedDown = YES; //THIS MEANS NO LONG PRESS
			}
		}
	}
	return %orig;
}

///////////Creating new methods so other things could possibly use these

//main activators
%new
-(void)activateAll {
	if ((buttonPressCountActivator == 1) && stoppedActivator) {
		//This if statement makes sure that there is no current ongoing press,
		//and there was only one within the alloted time.
		hourVibrate();
		[NSThread sleepForTimeInterval:setNumberDelay];
		minuteVibrate();
		buttonPressCountActivator = 0; //set back to default
	}
	resetVariables();     //resets variables, whenever the timer is up, even
												//if all conditions are not met
}

////////////////////
//Volume Up
%new
-(void)activateUp {
	if ((buttonPressCountVolumeUp == 1) && stoppedUp && volumeButtonsEnabled) {
		hourVibrate();
		buttonPressCountVolumeUp = 0;
	}
	resetVariables();
}

////////////////////
//Volume Down
%new
-(void)activateDown {
	if ((buttonPressCountVolumeDown == 1) && stoppedDown && volumeButtonsEnabled) {
		minuteVibrate();
		buttonPressCountVolumeDown = 0;
	}
	resetVariables();
}

%end
//Here I end the group of the tweak code so I can use %init
%end
%ctor {
	dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.burritoz.buzztime.list"];
  if (!dpkgInvalid) dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.burritoz.buzztime.md5sums"];

	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.burritoz.buzztimeprefs"];
  [preferences registerDefaults:@ { //defaults for prefernces
		@"tweakEnabled" : @YES,
		@"activationMethod" : @104,
		@"volumeButtonsEnabled" : @YES,
		@"setNumberDelay" : @"0.65",
	}];
	[preferences registerDouble:&activationMethod default:104 forKey:@"activationMethod"];
	[preferences registerDouble:&setNumberDelay default:0.65 forKey:@"delaySettings"];
	[preferences registerBool:&tweakEnabled default:YES forKey:@"tweakEnabled"];
	[preferences registerBool:&volumeButtonsEnabled default:YES forKey:@"volumeButtonsEnabled"];
	if (tweakEnabled && !dpkgInvalid) {
		%init(tweak); //I would rather have the tweak completely not load if the tweak isn't enabled
		//No sense in clogging up SpringBoard more than needed :D (also pirates don't get tweak injection, for their own good)
		//Pirating tweaks is dangerous, you rarely know for sure if the pirates are doing something sketchy...
	}
}
