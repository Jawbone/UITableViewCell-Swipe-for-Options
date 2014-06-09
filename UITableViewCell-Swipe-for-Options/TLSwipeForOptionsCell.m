//
//  TLSwipeForOptionsCell.m
//  UITableViewCell-Swipe-for-Options
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLSwipeForOptionsCell.h"

NSString *const TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification = @"TLSwipeForOptionsCellEnclosingTableViewDidScrollNotification";

#define kCatchWidth 120

@interface TLSwipeForOptionsCell () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIView *scrollViewContentView;      //The cell content (like the label) goes in this view.
@property (nonatomic, weak) UIView *scrollViewButtonView;       //Contains our two buttons

@property (nonatomic, weak) UILabel *scrollViewLabel;

@property (nonatomic, strong, readwrite) UIButton *deleteButton;
@property (nonatomic, strong, readwrite) UIButton *moreButton;

@end

@interface TLTouchPassthroughScrollView : UIScrollView
@end

@implementation TLSwipeForOptionsCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup {
    // Set up our contentView hierarchy
    UIScrollView *scrollView = [[TLTouchPassthroughScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
	NSMutableArray *viewsInContentView = [self.contentView.subviews copy];
	
    [self.contentView insertSubview:scrollView atIndex:0];
    self.scrollView = scrollView;
	self.scrollView.delaysContentTouches = NO;
    UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kCatchWidth, 0, kCatchWidth, CGRectGetHeight(self.bounds))];
    self.scrollViewButtonView = scrollViewButtonView;
    [self.scrollView addSubview:scrollViewButtonView];

    // Set up our two buttons
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    self.moreButton.frame = CGRectMake(0, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    [self.moreButton setTitle:@"More" forState:UIControlStateNormal];
    [self.moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(userPressedMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewButtonView addSubview:self.moreButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
    self.deleteButton.frame = CGRectMake(kCatchWidth / 2.0f, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(userPressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewButtonView addSubview:self.deleteButton];
    
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    scrollViewContentView.backgroundColor = self.contentView.backgroundColor;
    [self.scrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
	
	for (UIView *view in viewsInContentView)
	{
		[view removeFromSuperview];
		[self.scrollViewContentView addSubview:view];
	}
    
    UILabel *scrollViewLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.scrollViewContentView.bounds, 10, 0)];
    scrollViewLabel.backgroundColor = [UIColor clearColor];
    self.scrollViewLabel = scrollViewLabel;
    [self.scrollViewContentView addSubview:scrollViewLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingTableViewDidScroll) name:TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification  object:nil];
}

- (BOOL)delegateSupportsOptionalMethods {
	return [_delegate respondsToSelector:@selector(cellDidSelectDelete:)] && [_delegate respondsToSelector:@selector(cellDidSelectMore:)];
}

- (void)setDelegate:(id<TLSwipeForOptionsCellDelegate>)delegate {
	_delegate = delegate;
	self.scrollView.scrollEnabled = self.delegateSupportsOptionalMethods;
}

-(void)enclosingTableViewDidScroll {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)setShouldHideDeleteButton:(BOOL)shouldHideDeleteButton
{
    _shouldHideDeleteButton = shouldHideDeleteButton;
    
    if (_shouldHideDeleteButton)
    {
        self.deleteButton.hidden = YES;
        self.moreButton.frame = CGRectMake(kCatchWidth / 2.0f, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    }
    else
    {
        self.deleteButton.hidden = NO;
        self.moreButton.frame = CGRectMake(0, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + self.catchWidth, CGRectGetHeight(self.bounds));
}

#pragma mark - Options

- (BOOL)optionsVisible {
	return self.scrollView.contentOffset.x == kCatchWidth;
}

- (void)setOptionsVisible:(BOOL)optionsVisible {
	if (optionsVisible) {
		[self.scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:YES];
	} else {
		[self.scrollView setContentOffset:CGPointZero animated:YES];
	}
}

#pragma mark - Private Methods 

-(void)userPressedDeleteButton:(id)sender {
    [self.delegate cellDidSelectDelete:self];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)userPressedMoreButton:(id)sender {
    [self.delegate cellDidSelectMore:self];
}

#pragma mark - Overridden Methods

-(void)prepareForReuse {
    [super prepareForReuse];
    
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    self.scrollView.scrollEnabled = !self.editing && self.delegateSupportsOptionalMethods;
    
    // Corrects effect of showing the button labels while selected on editing mode (comment line, build, run, add new items to table, enter edit mode and select an entry)
    self.scrollViewButtonView.hidden = editing;
}

-(UILabel *)textLabel {
    // Kind of a cheat to reduce our external dependencies
    return self.scrollViewLabel;
}

#pragma mark - UIScrollViewDelegate Methods

- (CGFloat)catchWidth
{
    if (self.shouldHideDeleteButton)
    {
        return kCatchWidth / 2.0;
    }
    
    return kCatchWidth;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (scrollView.contentOffset.x > self.catchWidth) {
        targetContentOffset->x = self.catchWidth;
    }
    else {
        *targetContentOffset = CGPointZero;
        
        // Need to call this subsequently to remove flickering. Strange. 
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointZero animated:YES];
        });
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - kCatchWidth), 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
}

@end

#undef kCatchWidth

// Pass through scroll view allows for touches to make it to the enclosing tableview cell
@implementation TLTouchPassthroughScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end