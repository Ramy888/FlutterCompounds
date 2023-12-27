#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>

@interface AppDelegate ()

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  // Add the following lines to prevent screenshots
  // Initialize MethodChannel
  self.methodChannel = [FlutterMethodChannel methodChannelWithName:@"no_snaps_allowed" binaryMessenger:self.window.rootViewController];

  // Override point for customization after application launch.
  if (@available(iOS 11.0, *)) {
    [self preventScreenshots];
  } else {
    // Fallback on earlier versions
    [self preventScreenshotsFallback];
  }

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)preventScreenshots {
  [application.windows.firstObject setRootViewController:self.window.rootViewController];
  self.window.windowLevel = UIWindowLevelNormal;
}

- (void)preventScreenshotsFallback {
  self.window.windowLevel = UIWindowLevelNormal;
}

@end
