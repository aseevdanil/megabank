//
//  MBImageView.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBImageView : MBImageBaseView
{
	MBImageForm _imageForm;
	MBImageEffect _imageEffect;
	
	NSURL *_loadableImageURL;
	CGSize _loadableImageSize;
	id<MBOperation> _loadingOperation;
	unsigned int _loadableImageLoading : 1;
	unsigned int _loadableImageFailed : 1;
	
	unsigned int _adjustsWhenHighlighted : 1;
}

- (instancetype)initWithImageForm:(MBImageForm)imageForm andEffect:(MBImageEffect)imageEffect;
- (instancetype)initWithFrame:(CGRect)frame imageForm:(MBImageForm)imageForm andEffect:(MBImageEffect)imageEffect;
@property (nonatomic, assign, readonly) MBImageForm imageForm;
@property (nonatomic, assign, readonly) MBImageEffect imageEffect;
+ (CGSize)preferredViewSizeForMetric:(MBMetric)metric withImageForm:(MBImageForm)form;

@property (nonatomic, assign, getter = isAdjustsWhenHighlighted) BOOL adjustsWhenHighlighted;

@property (nonatomic, assign, readonly, getter = isLoadableImage) BOOL loadableImage;
@property (nonatomic, assign, readonly, getter = isLoadableImageLoading) BOOL loadableImageLoading;
@property (nonatomic, assign, readonly, getter = isLoadableImageFailed) BOOL loadableImageFailed;
- (void)setLoadableImageURL:(NSURL*)imageURL;

@end
