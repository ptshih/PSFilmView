//
//  PSSlideView.m
//  PSKit
//
//  Created by Peter Shih on 11/30/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSSlideView.h"

@implementation PSSlideView

@synthesize slideContentView = _slideContentView;
@synthesize slideHeight = _slideHeight;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.alwaysBounceVertical = YES;
    self.autoresizingMask = ~UIViewAutoresizingNone;
    
    _slideContentView = [[UIView alloc] initWithFrame:frame];
    _slideHeight = _slideContentView.height;
    
    // Add top and bottom gradient
    const CGFloat gradientHeight = 5.0;
    const CGFloat gradientStrength = 0.5;
    NSArray *topColors = [NSArray arrayWithObjects:(id)[RGBACOLOR(0, 0, 0, 0.0) CGColor], (id)[RGBACOLOR(0, 0, 0, gradientStrength) CGColor], nil];
    NSArray *bottomColors = [NSArray arrayWithObjects:(id)[RGBACOLOR(0, 0, 0, gradientStrength) CGColor], (id)[RGBACOLOR(0, 0, 0, 0.0) CGColor], nil];
    NSArray *locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    _topGradient = [[self addGradientLayerWithFrame:CGRectMake(0, -gradientHeight, self.width, gradientHeight) colors:topColors locations:locations startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)] retain];
    _bottomGradient = [[self addGradientLayerWithFrame:CGRectMake(0, self.height, self.width, gradientHeight) colors:bottomColors locations:locations startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)] retain];

    [self addSubview:_slideContentView];
  }
  return self;
}

- (void)dealloc {
  // Views
  RELEASE_SAFELY(_topGradient);
  RELEASE_SAFELY(_bottomGradient);
  RELEASE_SAFELY(_slideContentView);
  [super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
//  self.contentSize = _slideContentView.bounds.size;
}

- (void)prepareForReuse {
  self.contentOffset = CGPointMake(0, 0); // reset reused slide's contentOffset to top
}

- (void)setContentHeight:(CGFloat)height {
  _slideContentView.height = height;
  self.contentSize = CGSizeMake(self.contentSize.width, height);
  
  _bottomGradient.frame = CGRectMake(0, self.contentSize.height, self.width, 5.0);
}

+ (CGFloat)heightForObject:(id)object {
  return 0.0;
}

@end
