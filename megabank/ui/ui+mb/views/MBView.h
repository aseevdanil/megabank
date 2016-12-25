//
//  MBView.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//


@protocol MBView <MBUserInterfaceItem>
- (void)updateMetric;
@end



@interface MBView : UIView <MBView>
{
	struct
	{
		unsigned int metric : 1;
		unsigned int needsUpdateMetric : 1;
	}
	_mbviewFlags;
}

@end



@interface MBImageBaseView : UIImageView <MBView>
{
	struct
	{
		unsigned int metric : 1;
		unsigned int needsUpdateMetric : 1;
	}
	_mbviewFlags;
}

- (void)didChangeMetric;
@property (nonatomic, assign, readonly) BOOL needsUpdateMetric;

@end



@interface MBButton : UIButton <MBView>
{
	struct
	{
		unsigned int metric : 1;
		unsigned int needsUpdateMetric : 1;
	}
	_mbviewFlags;
}

@end



@interface MBAnnotationView : MKAnnotationView <MBView>
{
	struct
	{
		unsigned int metric : 1;
		unsigned int needsUpdateMetric : 1;
	}
	_mbviewFlags;
}

@end
