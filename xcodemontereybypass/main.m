//
//  main.m
//  xcodemontereybypass
//
//  workaround for the "The version of Xcode installed on this Mac is not compatible with macOS Monterey" pop-up that appears when trying to run old Xcode versions
//
//  Created by Trevor Schmitt on 11/9/21.
//

#import <Foundation/Foundation.h>
#import <spawn.h>
#import <sys/wait.h>
#import <sys/stat.h>

struct stat st = {0};
extern char **environ;

int launchXcode(const char* path) {
    pid_t pid;
    int status;
    char *argv[] = {"Xcode", NULL, NULL, NULL};
    status = posix_spawn(&pid, (char*)path, NULL, NULL, argv, environ);
    if (status == 0) {
        if (waitpid(pid, &status, 0) != -1) {
            
        }
        else {
            return -1;
        }
    }
    return 0;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if (argc >= 3) {
            if (!strcmp(argv[1], "--set") || !strcmp(argv[1], "-s")) {
                NSString *pathToSet = [NSString stringWithUTF8String:argv[2]];
                [prefs setObject:pathToSet forKey:@"XcodePath"];
                [prefs synchronize];
                printf("Xcode path set, exiting.\n");
                return 0;
            }
        }
        [prefs synchronize];
        NSString *path = [prefs stringForKey:@"XcodePath"];
        if (!path) {
            printf("No path to Xcode found. Did you set it?\n");
            return -1;
        }
        if (stat([path UTF8String], &st)) {
            printf("A path for Xcode has been set, but it does not exist on the filesystem. Did you set it correctly?\n");
            return -1;
        }
        NSString *fullPath = [path stringByAppendingString:@"/Contents/MacOS/Xcode"];
        const char *fullXcodePath = [fullPath UTF8String];
        if (launchXcode(fullXcodePath) == 0) {
            printf("Xcode successfully launched.\n");
        }
    }
    return 0;
}
