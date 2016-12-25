//
//  MBPointsPanelPointViewCell.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBPointsPanelPointViewCell : UICollectionViewCell

+ (NSString*)identifier;

- (void)setPointURL:(NSURL*)pointURL;

+ (CGSize)itemSizeForMetric:(MBMetric)metric;
+ (CGSize)itemsSpacingForMetric:(MBMetric)metric;

@end
