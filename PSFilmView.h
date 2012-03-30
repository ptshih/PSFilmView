//
//  PSFilmView.h
//  PSKit
//
//  Created by Peter Shih on 11/29/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSView.h"
#import "PSSlideView.h"

typedef enum {
  PSFilmSlideDirectionUp = 0,
  PSFilmSlideDirectionDown = 1
} PSFilmSlideDirection;

typedef enum {
  PSFilmViewStateIdle = 0,
  PSFilmViewStatePullingPrevious = 1,
  PSFilmViewStatePullingNext = 2,
  PSFilmViewStateRefreshing = 3,
  PSFilmViewStateLoadingMore = 4
} PSFilmViewState;

@protocol PSFilmViewDelegate, PSFilmViewDataSource;

@interface PSFilmView : PSView <UIScrollViewDelegate> {
  PSFilmViewState _state;
  NSMutableSet *_reusableSlides;
  PSSlideView *_activeSlide; // Just a pointer
  NSInteger _slideIndex;
  NSInteger _slideCount;
  
  // Views
  UIView *_headerView;
  UIView *_footerView;
  
  id <PSFilmViewDelegate> _filmViewDelegate;
  id <PSFilmViewDataSource> _filmViewDataSource;
}

@property (nonatomic, assign) id <PSFilmViewDelegate> filmViewDelegate;
@property (nonatomic, assign) id <PSFilmViewDataSource> filmViewDataSource;

#pragma mark - Public Methods
- (void)reloadSlides;
- (void)filmViewDidRefresh;
- (void)filmViewDidLoadMore;

#pragma mark - Transition Previous or Next
- (void)filmViewShouldSlideToIndex:(NSInteger)index direction:(PSFilmSlideDirection)direction;

#pragma mark - Reusing Slide Views
- (id)dequeueReusableSlideView;
- (void)enqueueReusableSlideView:(PSSlideView *)slideView;

@end

@protocol PSFilmViewDelegate <NSObject>

@optional
- (void)filmViewDidTriggerRefresh:(PSFilmView *)filmView;
- (void)filmViewDidTriggerLoadMore:(PSFilmView *)filmView;

@end

@protocol PSFilmViewDataSource <NSObject>

@optional
- (NSString *)filmView:(PSFilmView *)filmView titleForHeaderAtIndex:(NSInteger)index forState:(PSFilmViewState)state;
- (NSString *)filmView:(PSFilmView *)filmView titleForFooterAtIndex:(NSInteger)index forState:(PSFilmViewState)state;

- (CGFloat)filmView:(PSFilmView *)filmView heightForSlideAtIndex:(NSInteger)index;

@required
- (NSInteger)numberOfSlidesInFilmView:(PSFilmView *)filmView;
- (PSSlideView *)filmView:(PSFilmView *)filmView slideAtIndex:(NSInteger)index;

@end
