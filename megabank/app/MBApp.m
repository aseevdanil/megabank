//
//  MBApp.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBApp.h"

#import "MBPointsViewController.h"



@interface MBApp ()
{
	NSManagedObjectContext *_context;
	UIWindow *_window;
	UIAlertController *_errorAlert;
	unsigned int _regularPhase;
}

- (void)initializeServices;
- (void)launchServices;
- (void)stopServices;

@end


@implementation MBApp


#pragma mark Life-cycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	_regularPhase = NO;
	
	NSURL *storeURL = [NSURL fileURLWithPath:[NSString pathWithComponents:[NSArray arrayWithObjects:
																		   NSSupportDirectory(),
																		   [[NSBundle mainBundle] bundleIdentifier],
																		   [@"megabank" stringByAppendingPathExtension:@"sqlite"],
																		   nil]]];
	[[NSFileManager defaultManager] createDirectoryAtPath:[[storeURL URLByDeletingLastPathComponent] path] withIntermediateDirectories:YES attributes:nil error:NULL];
	NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								  [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
								  nil];
	NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
	[storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:NULL];
	NSManagedObjectContext *rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	rootContext.persistentStoreCoordinator = storeCoordinator;
	rootContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
	_context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	_context.parentContext = rootContext;
	
	[self initializeServices];
	
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_window.tintColor = [UIColor MBTintColor];
	_window.rootViewController = [[MBWireframeController alloc] init];
	[_window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Здесь можно проверить аутентификации итд, но у нас ее нет,
	// поэтому просто считаю что приложение в регулярном состоянии,
	// если на девайсе в принципе есть геолокация (просто для примера)
	NSError *error = nil;
	_regularPhase = [MBLocationService isGeolocationAvailable:&error];
	if (_regularPhase)
	{
		[self launchServices];
		[self setScene:MBScenePoints withContext:nil animated:NO];
	}
	else
	{
		[self processError:error];
	}
}


- (void)applicationWillTerminate:(UIApplication *)application
{
}


- (void)initializeServices
{
	[MBConnectService sharedService];	// for networkReachabilityStatus initialize
}


- (void)launchServices
{
	[[MBConnectService sharedService] launch];
	[[MBLocationService sharedService] launch];
	[[MBPartnersService sharedService] launch];
	[[MBImagesService sharedService] launch];
}


- (void)stopServices
{
	[[MBConnectService sharedService] stop];
	[[MBLocationService sharedService] stop];
	[[MBPartnersService sharedService] stop];
	[[MBImagesService sharedService] stop];
}


- (void)clearStore
{
	[self save:^(NSManagedObjectContext *localContext)
	 {
		 NSArray *entities = [localContext.parentContext.persistentStoreCoordinator.managedObjectModel entities];
		 for (NSEntityDescription *entityDescription in entities)
		 {
			 NSFetchRequest *request = [[NSFetchRequest alloc] init];
			 [request setEntity:entityDescription];
			 request.includesPropertyValues = NO;
			 request.returnsObjectsAsFaults = YES;
			 NSArray *objects = [localContext executeFetchRequest:request error:NULL];
			 for (NSManagedObject *object in objects)
				 [localContext deleteObject:object];
		 }
	 }];
}


#pragma mark Context


- (NSManagedObjectContext*)context
{
	return _context;
}


- (NSPersistentStoreCoordinator*)store
{
	return _context.parentContext.persistentStoreCoordinator;
}


- (void)save:(void (^)(NSManagedObjectContext *localContext))block
{
	CHECKMAINQUEUE
	[_context performBlockAndWait:^
	 {
		 if (block)
			 block(_context);
		 if ([_context hasChanges])
		 {
			 NSSet *insertedObjects = [_context insertedObjects];
			 if (insertedObjects && insertedObjects.count > 0)
				 [_context obtainPermanentIDsForObjects:[insertedObjects allObjects] error:NULL];
			 if ([_context save:NULL])
				 [_context.parentContext performBlock:^{ [_context.parentContext save:NULL]; }];
		 }
	 }];
}


- (void)saveConcurrency:(void (^)(NSManagedObjectContext *localContext))saveBlock completion:(void(^)(void))completionBlock
{
	NSManagedObjectContext *concurrencyContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	[concurrencyContext setParentContext:_context];
	[concurrencyContext performBlock:^
	 {
		 if (saveBlock)
			 saveBlock(concurrencyContext);
		 if ([concurrencyContext hasChanges])
			 [concurrencyContext save:NULL];
		 [[NSOperationQueue mainQueue] addOperationWithBlock:^
		  {
			  if (_regularPhase)
			  	  [self save:nil];
			  if (completionBlock)
				  completionBlock();
		  }];
	 }];
}


+ (NSString*)serviceDirectory:(NSString*)serviceIdentifier
{
	DASSERT(serviceIdentifier);
	return [NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [NSBundle mainBundle].bundleIdentifier, serviceIdentifier]];
}


#pragma mark UI & Errors


// Я понимаю, что некрасиво все это пихать сюда, но пока некогда делать все идеально:)


@synthesize window = _window;


- (MBSceneIdentifier)sceneIdentifier
{
	UIViewController<MBViewController,MBSceneViewController> *sceneViewController = (UIViewController<MBViewController,MBSceneViewController>*) ((MBWireframeController*) _window.rootViewController).sceneViewController;
	return sceneViewController ? sceneViewController.sceneIdentifier : MBSceneNone;
}


- (BOOL)setScene:(MBSceneIdentifier)scene withContext:(id)context animated:(BOOL)animated
{
	UIViewController<MBViewController,MBSceneViewController> *sceneViewController = (UIViewController<MBViewController,MBSceneViewController>*) ((MBWireframeController*) _window.rootViewController).sceneViewController;
	if (scene == (sceneViewController ? sceneViewController.sceneIdentifier : MBSceneNone))
	{
		if (sceneViewController)
		{
			if (context && [sceneViewController respondsToSelector:@selector(putContext:)])
				return [sceneViewController putContext:context];
		}
		return YES;
	}
	
	switch (scene)
	{
		case MBScenePoints:
			sceneViewController = [[MBPointsViewController alloc] init];
			break;
		case MBSceneNone:
		default:
			sceneViewController = nil;
			break;
	}
	if (sceneViewController)
		sceneViewController.sceneIdentifier = scene;
	[(MBWireframeController*) _window.rootViewController setSceneViewController:sceneViewController animated:animated completion:nil];
	if (sceneViewController)
	{
		if (context && [sceneViewController respondsToSelector:@selector(putContext:)])
			return [sceneViewController putContext:context];
	}
	return YES;
}


- (void)processError:(NSError*)error
{
	[self processError:error notificationLevel:MBErrorNotificationLevelDefault];
}


- (void)processError:(NSError*)error notificationLevel:(MBErrorNotificationLevel)notificationLevel
{
	if (!error)
		return;
	
	BOOL critical = NO;
	NSString *description = (NSString*)[error.userInfo objectForKey:NSLocalizedDescriptionKey];
	NSURL *URL = (NSURL*)[error.userInfo objectForKey:NSURLErrorKey];
	if ([error.domain isEqualToString:MBMegaErrorDomain])
	{
		notificationLevel = MBErrorNotificationLevelDefault;
		switch (error.code)
		{
			case MBMegaErrorCancelled:
				return;
			case MBMegaErrorAppInNonRegularState:
			{
				NSError *underlyingError = (NSError*)[error.userInfo objectForKey:NSUnderlyingErrorKey];
				if (underlyingError)
					description = (NSString*)[underlyingError.userInfo objectForKey:NSLocalizedDescriptionKey];
				critical = YES;
				_regularPhase = NO;
				[self setScene:MBSceneNone withContext:nil animated:NO];
				[self stopServices];
				[self clearStore];
			}
				break;
			case MBMegaErrorGeolocationNotAvailable:
			{
				error = [NSError MBAppInNonregularStateErrorWithUnderlyingError:error];
				[self processError:error notificationLevel:notificationLevel];
				return;
			}
		}
	}
	else if ([error.domain isEqualToString:NSURLErrorDomain])
	{
		switch (error.code)
		{
			case NSURLErrorCancelled:
				return;
			case NSURLErrorTimedOut:
				description = LOCAL(@"Не удалось получить ответ от сервера. Возможно сервер занят и не может обработать запрос. Попробуйте повторить позже.");
				break;
			default:
				if (!description || description.length == 0)
					description = LOCAL(@"Сбой соединения. Возможно сеть не доступна. Проверьте подключение.");
				break;
		}
	}
	if (!description || description.length == 0)
		description = LOCAL(@"Неизвестная ошибка.");
	
	if (notificationLevel != MBErrorNotificationLevelSilent)
	{
		if (_errorAlert)
		{
			_errorAlert = nil;
			[_window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		}
		
		_errorAlert = [UIAlertController alertControllerWithTitle:@"" message:description preferredStyle:UIAlertControllerStyleAlert];
		if (!critical)
		{
			typeof(self) __weak weakSelf = self;
			[_errorAlert addAction:[UIAlertAction actionWithTitle:LOCAL(@"Ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
									{
										typeof(self) strongSelf = weakSelf;
										if (strongSelf)
										{
											strongSelf->_errorAlert = nil;
										}
									}]];
		}
		if (URL)
		{
			typeof(self) __weak weakSelf = self;
			[_errorAlert addAction:[UIAlertAction actionWithTitle:LOCAL(@"Перейти") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
									{
										typeof(self) strongSelf = weakSelf;
										if (strongSelf)
										{
											strongSelf->_errorAlert = nil;
											[[UIApplication sharedApplication] openURL:URL options:[NSDictionary dictionary] completionHandler:nil];
										}
									}]];
		}
		[_window.rootViewController presentViewController:_errorAlert animated:YES completion:nil];
	}
}


@end
