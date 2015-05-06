//
//  MyUILabel.m
//  USC Trams
//
//  Created by Hemanth on 05/05/15.
//  Copyright (c) 2015 Hemanth. All rights reserved.
//

#import "MyUILabel.h"

@implementation MyUILabel


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}


@end
