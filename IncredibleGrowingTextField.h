//
//  IncredibleGrowingTextField.h
//
//  Created by Jake Bromberg on 12/20/12.
//

#import <UIKit/UIKit.h>

@protocol IncredibleGrowingTextFieldDelegate;

@interface IncredibleGrowingTextField : UIView <UITextViewDelegate>

@property (nonatomic) int minimumLines;
@property (nonatomic) int maximumLines;

@property (weak) id<IncredibleGrowingTextFieldDelegate> delegate;
@property (nonatomic, weak) NSString *text;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) UIKeyboardType keyboardType;

@end


@protocol IncredibleGrowingTextFieldDelegate<NSObject>

@optional

- (void)textBox:(IncredibleGrowingTextField*)textBox didResizeWith:(float)heightChange;
- (void)textBox:(IncredibleGrowingTextField*)textBox textDidChange:(NSString*)text;

- (void)textBoxDidBeginEditing:(UITextView *)textView;
- (void)textBoxDidEndEditing:(UITextView *)textView;

@end
