//
//  PSFilmView.m
//  PSKit
//
//  Created by Peter Shih on 11/29/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSFilmView.h"

#define HF_HEIGHT 60.0

@interface PSFilmView (Private)

- (void)setupHeaderAndFooter;

@end

@implementation PSFilmView

@synthesize filmViewDelegate = _filmViewDelegate;
@synthesize filmViewDataSource = _filmViewDataSource;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _state = PSFilmViewStateIdle;
    
    _reusableSlides = [[NSMutableSet alloc] initWithCapacity:2];
    
    _slideIndex = 0;
    _slideCount = 0;
    
    // Setup Header and Footer
    [self setupHeaderAndFooter];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_reusableSlides);
  
  // Views
  RELEASE_SAFELY(_headerView);
  RELEASE_SAFELY(_footerView);
  [super dealloc];
}

#pragma mark - View Setup
- (void)setupHeaderAndFooter {
  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HF_HEIGHT)];
  UILabel *h = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, HF_HEIGHT - 20)] autorelease];
  h.autoresizingMask = ~UIViewAutoresizingNone;
  [PSStyleSheet applyStyle:@"filmViewHeader" forLabel:h];
  [_headerView addSubview:h];
  
  _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HF_HEIGHT)];
  UILabel *f = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, HF_HEIGHT - 20)] autorelease];
  f.autoresizingMask = ~UIViewAutoresizingNone;
  [PSStyleSheet applyStyle:@"filmViewFooter" forLabel:f];
  [_footerView addSubview:f];
  
  [self addSubview:_headerView];
  [self addSubview:_footerView];
}

#pragma mark - Layout
- (void)layoutSubviews {
  [super layoutSubviews];
  
  _headerView.frame = CGRectMake(0, 0, self.width, HF_HEIGHT);
  _footerView.frame = CGRectMake(0, self.height - HF_HEIGHT, self.width, HF_HEIGHT);
}

#pragma mark - Public Methods
- (void)reloadSlides {
  // Find out how many slides are in the dataSource
  NSInteger numSlides = 0;
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(numberOfSlidesInFilmView:)]) {
    numSlides = [self.filmViewDataSource numberOfSlidesInFilmView:self];
    _slideCount = numSlides;
  }
  
  // Unload any previous slides
  if (_activeSlide) {
    [self enqueueReusableSlideView:_activeSlide];
    [_activeSlide release];
    _activeSlide = nil;
  }
  
  // Reset slide index
  _slideIndex = 0;
  
  // Load the first slide (top)
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:slideAtIndex:)]) {
    _activeSlide = [self.filmViewDataSource filmView:self slideAtIndex:_slideIndex];
    // Calculate newSlide's height
    CGFloat newSlideHeight = 0.0;
    if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:heightForSlideAtIndex:)]) {
      newSlideHeight = [self.filmViewDataSource filmView:self heightForSlideAtIndex:_slideIndex];
    } else {
      newSlideHeight = _activeSlide.slideHeight;
    }

    newSlideHeight = fmaxf(newSlideHeight, self.height);
    [_activeSlide setContentHeight:newSlideHeight];
//    _activeSlide.slideContentView.height = fmaxf(newSlideHeight, self.height);
    
    [self addSubview:_activeSlide];
  }
}

- (void)filmViewDidRefresh {
  _slideIndex = 0;
  
  NSInteger numSlides = 0;
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(numberOfSlidesInFilmView:)]) {
    numSlides = [self.filmViewDataSource numberOfSlidesInFilmView:self];
  }
  if (numSlides > _slideCount) {
    _slideIndex = _slideCount;
    _slideCount = numSlides;
    [self filmViewShouldSlideToIndex:_slideIndex direction:PSFilmSlideDirectionUp];;
  } else {
    _state = PSFilmViewStateIdle;
    [UIView animateWithDuration:0.4 animations:^{
      [_activeSlide setContentInset:UIEdgeInsetsZero];
    }];
  }
}

- (void)filmViewDidLoadMore {
  NSInteger numSlides = 0;
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(numberOfSlidesInFilmView:)]) {
    numSlides = [self.filmViewDataSource numberOfSlidesInFilmView:self];
  }
  if (numSlides > _slideCount) {
    _slideIndex = _slideCount;
    _slideCount = numSlides;
    [self filmViewShouldSlideToIndex:_slideIndex direction:PSFilmSlideDirectionDown];
  } else {
    _state = PSFilmViewStateIdle;
    [UIView animateWithDuration:0.4 animations:^{
      [_activeSlide setContentInset:UIEdgeInsetsZero];
    }];
  }
}

- (void)filmViewShouldSlideToIndex:(NSInteger)index direction:(PSFilmSlideDirection)direction {
  CGFloat slideToY = 0.0;
  CGFloat emptyHeight = 0.0;
  _slideIndex = index;
  
  // Get the new slide
  PSSlideView *newSlide = nil;
  CGFloat newSlideHeight = 0.0;
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:slideAtIndex:)]) {
    newSlide = [self.filmViewDataSource filmView:self slideAtIndex:_slideIndex];
    if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:heightForSlideAtIndex:)]) {
      newSlideHeight = [self.filmViewDataSource filmView:self heightForSlideAtIndex:_slideIndex];
    } else {
      newSlideHeight = newSlide.slideHeight;
    }
    
    // Calculate newSlide's height
    newSlideHeight = fmaxf(newSlideHeight, self.height);
    [newSlide setContentHeight:newSlideHeight];
//    newSlide.slideContentView.height = fmaxf(newSlideHeight, self.height);
    
    if (direction == PSFilmSlideDirectionUp) {
      // Calculate empty height
      emptyHeight = 0 - _activeSlide.contentOffset.y;
      slideToY = 0 + self.height + emptyHeight;
      
      newSlide.top = 0 - self.height;
    } else if (direction == PSFilmSlideDirectionDown) {
      // Calculate empty height
      emptyHeight = (_activeSlide.contentOffset.y + _activeSlide.height) - _activeSlide.contentSize.height;
      slideToY = 0 - self.height - emptyHeight;
      
      newSlide.top = self.bottom;
    }
    
    [self addSubview:newSlide];
  }
  
  // Animate the current slide off the screen and the new slide onto the screen
  _headerView.hidden = YES;
  _footerView.hidden = YES;
  BOOL shouldShowVerticalScrollIndicator = _activeSlide.showsVerticalScrollIndicator;
  BOOL shouldShowHorizontalScrollIndicator = _activeSlide.showsHorizontalScrollIndicator;
  _activeSlide.showsVerticalScrollIndicator = NO;
  _activeSlide.showsHorizontalScrollIndicator = NO;
  [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    _activeSlide.frame = CGRectMake(0, slideToY, _activeSlide.width, _activeSlide.height);
    newSlide.frame = CGRectMake(0, 0, newSlide.width, newSlide.height);
  } completion:^(BOOL finished){
    _state = PSFilmViewStateIdle;
    [UIView animateWithDuration:0.3 animations:^{
      [_activeSlide setContentInset:UIEdgeInsetsZero];
    }];
    [self enqueueReusableSlideView:_activeSlide];
    _activeSlide = newSlide;
    _activeSlide.showsVerticalScrollIndicator = shouldShowVerticalScrollIndicator;
    _activeSlide.showsHorizontalScrollIndicator = shouldShowHorizontalScrollIndicator;
    _headerView.hidden = NO;
    _footerView.hidden = NO;
  }];
}

#pragma mark - Reusing Slide Views
- (id)dequeueReusableSlideView {
  PSSlideView *slideView = [_reusableSlides anyObject];
  if (slideView) {
    [slideView retain];
    [slideView prepareForReuse];
    [_reusableSlides removeObject:slideView];
    [slideView autorelease];
  } else {
//    slideView = [[[PSSlideView alloc] initWithFrame:self.bounds] autorelease];
//    slideView.delegate = self;
//    slideView.scrollsToTop = NO;
//    slideView.backgroundColor = [UIColor clearColor];
  }
  return slideView;
}

- (void)enqueueReusableSlideView:(PSSlideView *)slideView {
  [_reusableSlides addObject:slideView];
  [slideView removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_state == PSFilmViewStateRefreshing || _state == PSFilmViewStateLoadingMore) return;
  
  // Detect if either header or footer got triggered 
  CGFloat visibleTop = scrollView.contentOffset.y;
  CGFloat visibleBottom = scrollView.contentOffset.y + scrollView.height;
  
//  NSLog(@"scroll: %@, top: %f, bottom: %f", NSStringFromCGPoint(scrollView.contentOffset), visibleTop, visibleBottom);
  
  UILabel *h = [_headerView.subviews firstObject];
  UILabel *f = [_footerView.subviews firstObject];
  
  BOOL headerShowing = (visibleTop + HF_HEIGHT) < 0;
  BOOL footerShowing = (visibleBottom - HF_HEIGHT) > scrollView.contentSize.height;
  
  if (headerShowing) {
    _state = PSFilmViewStatePullingPrevious;
    h.text = [self.filmViewDataSource filmView:self titleForHeaderAtIndex:_slideIndex forState:_state];
  } else if (!footerShowing) {
    _state = PSFilmViewStateIdle;
    h.text = [self.filmViewDataSource filmView:self titleForHeaderAtIndex:_slideIndex forState:_state];
  }
  
  if (footerShowing) {
    _state = PSFilmViewStatePullingNext;
    f.text = [self.filmViewDataSource filmView:self titleForFooterAtIndex:_slideIndex forState:_state];
  } else if (!headerShowing) {
    _state = PSFilmViewStateIdle;
    f.text = [self.filmViewDataSource filmView:self titleForFooterAtIndex:_slideIndex forState:_state];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (decelerate) {
    PSSlideView *slideView = (PSSlideView *)scrollView;
    if (_state == PSFilmViewStatePullingPrevious) {
      // Check if this is a refresh
      if (_slideIndex == 0) {
        // Refresh Triggered
        UILabel *h = [_headerView.subviews firstObject];
        _state = PSFilmViewStateRefreshing;
        h.text = @"Loading...";
        
        [UIView animateWithDuration:0.4 animations:^{
          [slideView setContentInset:UIEdgeInsetsMake(HF_HEIGHT, 0, 0, 0)];
        }];
        if (self.filmViewDelegate && [self.filmViewDelegate respondsToSelector:@selector(filmViewDidTriggerRefresh:)]) {
          [self.filmViewDelegate filmViewDidTriggerRefresh:self];
        }
      } else {
        _slideIndex--;
        [self filmViewShouldSlideToIndex:_slideIndex direction:PSFilmSlideDirectionUp];
      }
    } else if (_state == PSFilmViewStatePullingNext) {
      // Find out how many slides are in the dataSource
      NSInteger numSlides = 0;
      if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(numberOfSlidesInFilmView:)]) {
        numSlides = [self.filmViewDataSource numberOfSlidesInFilmView:self];
        _slideCount = numSlides;
      }
      
      if (_slideIndex == (numSlides - 1))  {
        // Load more triggered
        UILabel *f = [_footerView.subviews firstObject];
        _state = PSFilmViewStateLoadingMore;
        f.text = @"Loading...";
        
        [UIView animateWithDuration:0.4 animations:^{
          [slideView setContentInset:UIEdgeInsetsMake(0, 0, HF_HEIGHT, 0)];
        }];
        if (self.filmViewDelegate && [self.filmViewDelegate respondsToSelector:@selector(filmViewDidTriggerLoadMore:)]) {
          [self.filmViewDelegate filmViewDidTriggerLoadMore:self];
        }
      } else {
        _slideIndex++;
        [self filmViewShouldSlideToIndex:_slideIndex direction:PSFilmSlideDirectionDown];
      }
    }
  }
}

@end
