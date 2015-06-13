//
//  UIView+Appearance.h
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/12/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Appearance)

+ (instancetype)appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;

@end
