//
//  UIScreen+DA.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



CGFloat UIScreenScale();
CGFloat UIScreenPixel();


#define SCREEN_LENGTH(l, round_up)	(((round_up) ? ceil((l) * UIScreenScale()) : floor((l) * UIScreenScale())) / UIScreenScale())
#define SCREEN_SIZE(s, round_up)	(s.width = (((round_up) ? ceil((s.width) * UIScreenScale()) : floor((s.width) * UIScreenScale())) / UIScreenScale()), s.height = (((round_up) ? ceil((s.height) * UIScreenScale()) : floor((s.height) * UIScreenScale())) / UIScreenScale()));
