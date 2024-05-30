//
//  AppDelegate.m
//  EpubZip
//
//  Created by Danil Korotenko on 5/30/24.
//

#import "AppDelegate.h"
#import "TaskController.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    [self processUrl:[NSURL fileURLWithPath:filename]];
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames
{
    [filenames enumerateObjectsUsingBlock:
        ^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            [self processUrl:[NSURL fileURLWithPath:obj]];
        }];
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
    [urls enumerateObjectsUsingBlock:
        ^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            [self processUrl:obj];
        }];
}

#pragma mark -

- (void)processUrl:(NSURL *)anURL
{
    NSLog(@"Processing url: %@", anURL);

    NSString *path = [anURL path];
    if (path == nil)
    {
        NSLog(@"url is not a path url: %@", anURL);
        return;
    }

    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory])
    {
        NSLog(@"file path does not exist url: %@", anURL);
        return;
    }

    if (isDirectory)
    {
        NSLog(@"zip directory");
        NSError *error = nil;
        [TaskController zipEPUBFolder:path error:&error];
    }
    else
    {
        if ([[path pathExtension] caseInsensitiveCompare:@"epub"] == NSOrderedSame)
        {
            NSError *error = nil;
            BOOL result = [TaskController unzipPath:path error:&error];
            if (!result)
            {
                [NSApp presentError:error];
            }
        }
    }
}

@end
