//
//  MBApp.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBApp : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *store;
- (void)save:(void (^)(NSManagedObjectContext *localContext))block;
- (void)saveConcurrency:(void (^)(NSManagedObjectContext *localContext))saveBlock completion:(void(^)(void))completionBlock;	// completionBlock on Main queue

+ (NSString*)serviceDirectory:(NSString*)serviceIdentifier;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign, readonly) MBSceneIdentifier sceneIdentifier;
- (BOOL)setScene:(MBSceneIdentifier)scene withContext:(id)context animated:(BOOL)animated;

- (void)processError:(NSError*)error;
- (void)processError:(NSError*)error notificationLevel:(MBErrorNotificationLevel)notificationLevel;

@end

