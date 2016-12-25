//
//  MBMapControlsView.h
//  megabank
//
//  Created by da on 04.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBMapButton.h"



@interface MBMapControlsView : MBView
{
	UIActivityIndicatorView *_loadingView;
	
	MBMapButton *_scaleUpButton;
	MBMapButton *_scaleDownButton;
	
	MBMapButtonItem *_scaleUpButtonItem;
	MBMapButtonItem *_scaleDownButtonItem;
}

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, strong) MBMapButtonItem *scaleUpButtonItem;
@property (nonatomic, strong) MBMapButtonItem *scaleDownButtonItem;

@end
