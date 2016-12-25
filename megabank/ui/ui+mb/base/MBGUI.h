//
//  MBGUI.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



#define MBStatusBarStyle UIStatusBarStyleDefault


#define FRAME_WIDTH			3.



#pragma mark MBMetric


static const struct
{
	CGSize boundsMargins, itemsSpacing;
}
MBMetricTable[] =
{
	/*MBMetricCompact*/	(CGSize){12., 12.},	(CGSize){10., 8.},
	/*MBMetricRegular*/	(CGSize){18., 18.},	(CGSize){14., 12.},
};




#pragma mark MBUserInterfaceItem


@protocol MBMetricedItem
@property (nonatomic, assign, readonly) MBMetric metric;
@end


@protocol MBUserInterfaceItem <MBMetricedItem>
@end
