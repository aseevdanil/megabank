//
//  MBMapButton.h
//  megabank
//
//  Created by da on 04.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



typedef NS_ENUM(NSUInteger, MBMapButtonType)
{
	MBMapButtonTypeUnk,
	MBMapButtonTypeScaleUp,
	MBMapButtonTypeScaleDown,
	
	MBMapButtonTypeCount,
};


@interface MBMapButton : MBButton

- (instancetype)initWithType:(MBMapButtonType)type;
- (instancetype)initWithFrame:(CGRect)frame type:(MBMapButtonType)type;
@property (nonatomic, assign, readonly) MBMapButtonType type;

+ (CGSize)preferredButtonSizeForMetric:(MBMetric)metric;

@end



@interface MBMapButtonItem : NSObject
{
	NSUInteger _tag;
	id __weak _target;
	SEL _action;
	
	unsigned int _hidden : 1;
	unsigned int _enabled : 1;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action;

@property (nonatomic, assign, getter = isHidden) BOOL hidden;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@end
