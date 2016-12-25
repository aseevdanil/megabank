//
//  MBError.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBError.h"



NSString *const MBMegaErrorDomain = @"MBMegaErrorDomain";


@implementation NSError (MBError)


+ (NSError*)MBMegaUnknownError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorUnknown userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Неизвестная ошибка.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaCancelledError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorCancelled userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Действие отменено.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaInvalidateDataError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorInvalidateData userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Неверный формат данных.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaInvalidateParametersError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorInvalidateData userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Неверные параметры.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaInvalidateURLError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorInvalidateURL userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Неверный URL.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaFileNotFoundError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorFileNotFound userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Файл не найден.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaFileReadingError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorFileReading userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Ошибка чтения файла.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaFileWritingError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorFileWriting userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Ошибка записи файла.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBMegaInvalidHTTPResponseErrorWithStatusCode:(NSInteger)statusCode
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorInvalidHTTPResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																										  [NSNumber numberWithInteger:statusCode], MBHTTPResponseStatusCodeErrorKey,
																										  [NSHTTPURLResponse localizedStringForStatusCode:statusCode], NSLocalizedDescriptionKey,
																										  nil]];
}


+ (NSError*)MBMegaDownloadFileFailureError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorDownloadFileFailure userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Не удалось загрузить файл с сервера.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBAppInNonregularStateErrorWithUnderlyingError:(NSError*)underlyingError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorAppInNonRegularState userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																									 LOCAL(@"Сервис недоступен."), NSLocalizedDescriptionKey,
																									 underlyingError, NSUnderlyingErrorKey,
																									 nil]];
}


+ (NSError*)MBGeolocationNotAvailableLocationServiceError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorGeolocationNotAvailable userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Службы геолокации необходимые для работы сервиса не поддерживаются этим устройством.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBGeolocationRestrictedLocationServiceError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorGeolocationRestricted userInfo:[NSDictionary dictionaryWithObject:LOCAL(@"Службы геолокации необходимые для работы сервиса недоступны.") forKey:NSLocalizedDescriptionKey]];
}


+ (NSError*)MBGeolocationDeniedLocationServiceError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorGeolocationDenied userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																										LOCAL(@"Службы геолокации необходимые для работы сервиса отключены. Чтобы включить их, зайдите в настройки телефона, раздел \"Приватность\"."), NSLocalizedDescriptionKey,
																										[NSURL URLWithString:UIApplicationOpenSettingsURLString], NSURLErrorKey,
																										nil]];
}


+ (NSError*)MBCannotQueryImageServiceErrorWithUnderlyingError:(NSError*)underlyingError
{
	return [NSError errorWithDomain:MBMegaErrorDomain code:MBMegaErrorCannotQueryImage userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																									   LOCAL(@"Не удалось получить изображение."), NSLocalizedDescriptionKey,
																									   underlyingError, NSUnderlyingErrorKey,
																									   nil]];
}


@end


NSString *const MBHTTPResponseStatusCodeErrorKey = @"MBHTTPResponseStatusCodeErrorKey";
