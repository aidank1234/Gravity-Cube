#import "AppDelegate.h"
#import "SampleAppViewController.h"
#import <RevMobAds/RevMobAds.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    self.viewController = [[[SampleAppViewController alloc] init] autorelease];
    [self.window setRootViewController:self.viewController];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

@end
