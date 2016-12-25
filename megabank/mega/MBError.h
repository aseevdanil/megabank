//
//  MBError.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



FOUNDATION_EXTERN NSString *const MBMegaErrorDomain;

enum
{
	MBMegaErrorUnknown = -1,
	MBMegaErrorNone = 0,
	
	MBMegaErrorCancelled,
	MBMegaErrorInvalidateData,
	MBMegaErrorInvalidateParameters,
	MBMegaErrorInvalidateURL,
	MBMegaErrorFileNotFound,
	MBMegaErrorFileReading,
	MBMegaErrorFileWriting,
	MBMegaErrorInvalidHTTPResponse,
	MBMegaErrorDownloadFileFailure,
	
	// app
	MBMegaErrorAppInNonRegularState = 1001,
	
	// location
	MBMegaErrorGeolocationNotAvailable = 2001,
	MBMegaErrorGeolocationRestricted,
	MBMegaErrorGeolocationDenied,
	
	// images
	MBMegaErrorCannotQueryImage = 3001,
};


@interface NSError (MBError)

+ (NSError*)MBMegaUnknownError;
+ (NSError*)MBMegaCancelledError;
+ (NSError*)MBMegaInvalidateDataError;
+ (NSError*)MBMegaInvalidateParametersError;
+ (NSError*)MBMegaInvalidateURLError;
+ (NSError*)MBMegaFileNotFoundError;
+ (NSError*)MBMegaFileReadingError;
+ (NSError*)MBMegaFileWritingError;
+ (NSError*)MBMegaInvalidHTTPResponseErrorWithStatusCode:(NSInteger)statusCode;
+ (NSError*)MBMegaDownloadFileFailureError;

+ (NSError*)MBAppInNonregularStateErrorWithUnderlyingError:(NSError*)underlyingError;

+ (NSError*)MBGeolocationNotAvailableLocationServiceError;
+ (NSError*)MBGeolocationRestrictedLocationServiceError;
+ (NSError*)MBGeolocationDeniedLocationServiceError;

+ (NSError*)MBCannotQueryImageServiceErrorWithUnderlyingError:(NSError*)underlyingError;

@end

FOUNDATION_EXTERN NSString *const MBHTTPResponseStatusCodeErrorKey;
