//
//  PSSlideView.h
//  PSKit
//
//  Created by Peter Shih on 11/30/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSlideView : UIScrollView {
  UIView *_slideContentView;
  CGFloat _slideHeight;
  CAGradientLayer *_topGradient;
  CAGradientLayer *_bottomGradient;
}

@property (nonatomic, retain) UIView *slideContentView;
@property (nonatomic, assign) CGFloat slideHeight;

- (void)prepareForReuse;

- (void)setContentHeight:(CGFloat)height;

+ (CGFloat)heightForObject:(id)object;

@end
