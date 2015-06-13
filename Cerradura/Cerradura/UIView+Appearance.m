//
//  UIView+Appearance.m
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/12/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

#import "UIView+Appearance.h"

@implementation UIView (Appearance)

+ (instancetype)appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}

@end
