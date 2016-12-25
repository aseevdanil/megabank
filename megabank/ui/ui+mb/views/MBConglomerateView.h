//
//  MBConglomerateView.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBConglomerateView : MBView
{
	MBImageForm _imageForm;
	NSMutableArray<MBImageView*> *_imagesViews;
	UILabel *_placeholderLabel;
	unsigned int _highlighted : 1;
	unsigned int _adjustsWhenHighlighted : 1;
}

- (instancetype)initWithImageForm:(MBImageForm)imageForm;
- (instancetype)initWithFrame:(CGRect)frame imageForm:(MBImageForm)imageForm;
@property (nonatomic, assign, readonly) MBImageForm imageForm;
+ (CGSize)preferredViewSizeForMetric:(MBMetric)metric withImageForm:(MBImageForm)form;

- (void)setImagesURLs:(NSArray<NSURL*>*)imagesURLs withPlaceholder:(NSString*)placeholder;
+ (NSUInteger)maximumPresentedImagesWithPlaceholder:(BOOL)placeholder;

@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, assign, getter = isAdjustsWhenHighlighted) BOOL adjustsWhenHighlighted;

@end
