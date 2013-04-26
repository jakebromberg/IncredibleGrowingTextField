//
//  IncredibleGrowingTextField.m
//
//  Created by Jake Bromberg on 12/20/12.
//

#import "IncredibleGrowingTextField.h"
#import <QuartzCore/QuartzCore.h>

@interface internalTextBox : UITextView

@end

@implementation internalTextBox

- (void)setContentInset:(UIEdgeInsets)insets
{
	insets.bottom = 5;
	insets.top = 0;
	
	[super setContentInset:insets];
}

@end

@interface IncredibleGrowingTextField () {
	int maxHeight;
	int minHeight;
}

@property (nonatomic, strong) UITextView *textEntryBox;
@property (nonatomic, strong) UIView *shadowView;

@end


@implementation IncredibleGrowingTextField

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self commonInitializations];
    }
	
    return self;
}

- (void)awakeFromNib
{
	[self commonInitializations];
}

- (void)commonInitializations
{
	[self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
	[self addSubview:self.shadowView];
	[self addSubview:self.textEntryBox];
	
	self.minimumLines = 1;
	self.maximumLines = 6;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"frame"])
	{
		_textEntryBox.frame = self.textBoxFrame;
		_shadowView.frame = self.textBoxFrame;
	}
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"frame"];
}

- (CGRect)textBoxFrame
{
	CGRect frame = self.frame;
	frame.origin.x = 0;
	frame.origin.y = 1;
	frame.size.height = self.frame.size.height - 2;

	return frame;
}

- (UITextView*)textEntryBox
{
	if (!_textEntryBox)
	{
		_textEntryBox = [[internalTextBox alloc] initWithFrame:self.textBoxFrame];
		_textEntryBox.delegate = self;
		_textEntryBox.font = [UIFont fontWithName:@"Helvetica" size:14];
		_textEntryBox.text = @"";
		_textEntryBox.scrollEnabled = NO;
		_textEntryBox.showsHorizontalScrollIndicator = NO;
		_textEntryBox.backgroundColor = [UIColor whiteColor];
		
		_textEntryBox.layer.cornerRadius = 8;
		_textEntryBox.layer.masksToBounds = YES;
	}
	
	return _textEntryBox;
}

- (UIView*)shadowView
{
	if (!_shadowView)
	{
		_shadowView = [[UIView alloc] initWithFrame:self.textBoxFrame];
		_shadowView.layer.borderWidth = 1;
		_shadowView.layer.borderColor = [UIColor lightGrayColor].CGColor;
		_shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
		_shadowView.layer.shadowOffset = CGSizeMake(0, -1);
		_shadowView.layer.shadowRadius = 1;
		_shadowView.layer.shadowOpacity = 1;
		_shadowView.layer.backgroundColor = [UIColor whiteColor].CGColor;
		_shadowView.layer.masksToBounds = NO;
		_shadowView.layer.cornerRadius = 8;
		_shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	
	return _shadowView;
}

- (void)setMinimumLines:(int)ml
{
	minHeight = [self calcHeight:ml];
	_minimumLines = ml;
}

- (void)setMaximumLines:(int)ml
{
	if (ml == 0) {
		maxHeight = 0;
	} else {
		maxHeight = [self calcHeight:ml];
	}
	
	_maximumLines = ml;
}

- (void)setText:(NSString *)t
{
	_textEntryBox.text = t;
	[self textViewDidChange:_textEntryBox];
}

- (NSString*)text
{
	return _textEntryBox.text;
}

- (int)calcHeight:(int)lines
{
	float heightOfOneLine = [@"X" sizeWithFont:_textEntryBox.font constrainedToSize:_textEntryBox.frame.size].height;
	return MAX(32, heightOfOneLine) * lines;
}

- (float)textHeight
{
	int textHeight = _textEntryBox.contentSize.height;
	
	if (textHeight < minHeight || _textEntryBox.text.length == 0)
	{
		textHeight = minHeight;
	}
	
	if (maxHeight > 0 && textHeight > maxHeight) {
		textHeight = maxHeight;
	}

	return textHeight;
}

- (void)textViewDidChange:(UITextView *)textView
{
	if (self.textHeight != _textEntryBox.frame.size.height)
	{
		// We are resizing the textBox
		float heightChange = self.textHeight - _textEntryBox.frame.size.height;
		
		if (heightChange < 0)
		{
			// We are shrinking the size of the text box
			if (self.textHeight < maxHeight)
			{
				_textEntryBox.scrollEnabled = NO;
				[self scaleBox:heightChange];
			}
		} else if (heightChange > 0) {
			if (self.textHeight == maxHeight)
			{
				_textEntryBox.scrollEnabled = YES;
				[_textEntryBox flashScrollIndicators];
			}
			
			[self scaleBox:heightChange];
		}
		
		if ([_delegate respondsToSelector:@selector(textBox:didResizeWith:)])
		{
			[_delegate textBox:self didResizeWith:heightChange];
		}
	}

	if ([_delegate respondsToSelector:@selector(textBox:textDidChange:)])
	{
		[_delegate textBox:self textDidChange:_textEntryBox.text];
	}
}

- (void)scaleBox:(float)heightChange
{
	[UIView animateWithDuration:.25 animations:^{
		[self newHeight:self.frame.size.height + heightChange forView:self];
		[self newHeight:self.textHeight forView:_textEntryBox];
	}];
}

- (void)newHeight:(float)height forView:(UIView*)view
{
	view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
    {
        [_delegate textBoxDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(textViewDidEndEditing:)])
    {
        [_delegate textBoxDidEndEditing:textView];
    }
}


@end