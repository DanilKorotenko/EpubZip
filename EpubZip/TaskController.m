//
//  TaskController.m
//  LangSwap
//
//  Created by Danil Korotenko on 7/25/22.
//

#import "TaskController.h"

@implementation TaskController

+ (BOOL)unzipPath:(NSString *)aPath error:(NSError **)anError
{
    NSString *parentDirectory = [aPath stringByDeletingLastPathComponent];

    NSString *filename = [[aPath lastPathComponent] stringByDeletingPathExtension];

    NSString *outputDirectory = [parentDirectory stringByAppendingPathComponent:filename];

    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:outputDirectory withIntermediateDirectories:YES attributes:nil error:anError];

    if (!result)
    {
        return result;
    }

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/unzip";
    task.arguments = @[@"-o", aPath];

    task.currentDirectoryPath = outputDirectory;

    NSPipe *taskOutput = [NSPipe pipe];
    [task setStandardOutput:taskOutput];

    [task launch];
    [task waitUntilExit];

    NSFileHandle *read = [taskOutput fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead
        encoding:NSUTF8StringEncoding];

    if (task.terminationStatus != 0)
    {
        result = NO;
        if (anError != NULL)
        {
            *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:task.terminationStatus
                userInfo:
                @{
                    NSLocalizedDescriptionKey: stringRead
                }];
        }
    }

    NSLog(@"%@ (%@) task output:\n%@",
        @"/usr/bin/unzip", aPath, stringRead);

    return result;
}

#pragma mark

+ (BOOL)zipEPUBFolder:(NSString *)aFolderPath error:(NSError **)anError
{
    BOOL result = YES;

    NSString *parentDir = [aFolderPath stringByDeletingLastPathComponent];
    NSString *fileName = [aFolderPath lastPathComponent];
    NSString *outputFile = [[parentDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"epub"];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/zip";
    task.arguments = @[@"-X", outputFile, @"mimetype"];

    task.currentDirectoryPath = aFolderPath;

    NSPipe *taskOutput = [NSPipe pipe];
    [task setStandardOutput:taskOutput];

    [task launch];
    [task waitUntilExit];

    NSFileHandle *read = [taskOutput fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead
        encoding:NSUTF8StringEncoding];

    if (task.terminationStatus != 0)
    {
        result = NO;
        if (anError != NULL)
        {
            *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:task.terminationStatus
                userInfo:
                @{
                    NSLocalizedDescriptionKey: stringRead
                }];
        }
    }

    NSLog(@"task output:\n%@", stringRead);

    task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/zip";
    task.arguments = @[@"-rg", outputFile, @"META-INF", @"-x", @"\\*.DS_Store"];

    task.currentDirectoryPath = aFolderPath;

    taskOutput = [NSPipe pipe];
    [task setStandardOutput:taskOutput];

    [task launch];
    [task waitUntilExit];

    read = [taskOutput fileHandleForReading];
    dataRead = [read readDataToEndOfFile];
    stringRead = [[NSString alloc] initWithData:dataRead
        encoding:NSUTF8StringEncoding];

    if (task.terminationStatus != 0)
    {
        result = NO;
        if (anError != NULL)
        {
            *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:task.terminationStatus
                userInfo:
                @{
                    NSLocalizedDescriptionKey: stringRead
                }];
        }
    }

    NSLog(@"task output:\n%@", stringRead);

    task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/zip";
    task.arguments = @[@"-rg", outputFile, @"OEBPS", @"-x", @"\\*.DS_Store"];

    task.currentDirectoryPath = aFolderPath;

    taskOutput = [NSPipe pipe];
    [task setStandardOutput:taskOutput];

    [task launch];
    [task waitUntilExit];

    read = [taskOutput fileHandleForReading];
    dataRead = [read readDataToEndOfFile];
    stringRead = [[NSString alloc] initWithData:dataRead
        encoding:NSUTF8StringEncoding];

    if (task.terminationStatus != 0)
    {
        result = NO;
        if (anError != NULL)
        {
            *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:task.terminationStatus
                userInfo:
                @{
                    NSLocalizedDescriptionKey: stringRead
                }];
        }
    }

    NSLog(@"task output:\n%@", stringRead);


    return result;
}

#pragma mark -



@end
