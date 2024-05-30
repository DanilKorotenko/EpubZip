//
//  TaskController.h
//  LangSwap
//
//  Created by Danil Korotenko on 7/25/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskController : NSObject

+ (BOOL)unzipPath:(NSString *)anPath error:(NSError **)anError;
+ (BOOL)zipEPUBFolder:(NSString *)aFolderPath error:(NSError **)anError;

@end

NS_ASSUME_NONNULL_END
