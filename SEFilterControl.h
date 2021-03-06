//
//  SEFilterControl.h
//  SEFilterControl_Test
//
//  Created by Shady A. Elyaski on 6/13/12.
//  Copyright (c) 2012 mash, ltd. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import <UIKit/UIKit.h>

@class SEFilterKnob;

extern NSString *const kTitlesTextKey;
extern NSString *const kTitlesSelectedColorKey;
extern NSString *const kTitlesSelectedFontKey;

@interface SEFilterControl : UIControl

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (retain, nonatomic) UIColor *progressColor;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *titleLabels;
@property (strong, nonatomic) SEFilterKnob *handler;
@property (assign, nonatomic) UIEdgeInsets padding;
@property (assign, nonatomic) CGSize selectedOffset;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIView *backgroundView;
@property (assign, nonatomic) CGFloat progressBarCenterY;
@property (assign, nonatomic) CGFloat progressBarHeight;
@property (assign, nonatomic) CGFloat progressBarSelectionCircleLength;
@property (assign, nonatomic) CGFloat titleCenterY;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *titleColor;
@property (assign, nonatomic) CGFloat titleAlpha;

- (id)initWithFrame:(CGRect)theFrame padding:(UIEdgeInsets)thePadding titles:(NSArray *)theTitles;
- (void)setHandlerColor:(UIColor *)theColor;
- (void)setSelectedIndex:(NSInteger)theSelectedIndex animated:(BOOL)theAnimated;

@end
