//
//  InputTextView.m
//  ChatUI2020
//
//  Created by ios2 on 2020/5/15.
//  Copyright © 2020 CY. All rights reserved.
//

#import "InputTextView.h"
#import "FaceTextManager.h"

@implementation InputTextView{
	NSRange _currentTextRange; //当前输入框的位置
	UIColor *_textColor;  //字体颜色
	CGFloat  _fontSize;   //字体大小
	CGFloat  _lineHeight; //行间距
	NSDictionary * _textTypingAttributes;
}
+(instancetype)textViewWitnFontSize:(CGFloat)fontSize
 andTextColor:(UIColor *)textColor
andLineHeight:(CGFloat)lineHeight
{
	return [[self alloc]initWithFontSize:fontSize andTextColor:textColor andLineHeight:lineHeight];
}

-(instancetype)initWithFontSize:(CGFloat)fontSize
				   andTextColor:(UIColor *)textColor
				  andLineHeight:(CGFloat)lineHeight
{
	self =[super init];
	if (self) {
		_textColor = textColor?textColor:[UIColor blackColor];
		_fontSize = MAX(fontSize, 5.0);
		_lineHeight = MAX(lineHeight, 0);
		self.allowsEditingTextAttributes = YES;
		self.delegate = self;
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidChangeTextNotification:) name:UITextViewTextDidChangeNotification object:nil];
		
		NSMutableParagraphStyle *phStyle = [[NSMutableParagraphStyle alloc]init];
		phStyle.lineSpacing = _lineHeight;
		_textTypingAttributes = @{
			NSForegroundColorAttributeName:_textColor,
			NSFontAttributeName:[UIFont systemFontOfSize:_fontSize],
			NSParagraphStyleAttributeName:phStyle
		};
	}
	return self;
}

-(void)changeTextWithRange:(NSRange)range andText:(NSString *)text andTextView:(UITextView *)textView
{
	InputTextView *inputTextV = (InputTextView *)textView;
	NSRange newRange =  [inputTextV textRangeWithRange:range];
	NSInteger startIndex = range.location; //起始位置
	NSInteger startLength = inputTextV.attributedText.length; //文字开始的长度
	NSMutableString *mstr = [[NSMutableString alloc]initWithString:[inputTextV currentText]];
	[mstr insertString:text atIndex:newRange.location];
	NSAttributedString *abs = [FaceTextManager attributedStringForString:mstr andFont:[UIFont systemFontOfSize:_fontSize]  andTextColor:_textColor andLineHeight:_lineHeight];
	NSInteger endLength = abs.length; //结束后的长度
	NSInteger index = startIndex + (endLength - startLength);
	[self setAttributedText:abs];
	NSRange gbRange = NSMakeRange(index, 0);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), (^{
		  [textView setSelectedRange:gbRange];
	  }));
	[self textViewDidChangeText]; //输入的文本发生变化
}

- (void)textViewDidChangeTextNotification:(NSNotification *)noti
{
    if (noti.object == self) {
		[self textViewDidChangeText];
    }
}
//改变
-(void)textViewDidChangeText
{
	if ([self.input_delegate respondsToSelector:@selector(inputTextView:didChangeAbsText:andOriginalText:)]) {
		[self.input_delegate inputTextView:self didChangeAbsText:self.attributedText andOriginalText:self.currentText];
	}
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(nonnull NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    return NO;
}

-(BOOL)shouldUpdateFocusInContext:(UIFocusUpdateContext *)context
{
	return NO;
}

- (void)copy:(id)sender {
    NSRange range = self.selectedRange;
    NSString *content = [self getStrContentInRange:range];
    if (content.length > 0) {
        UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
        [defaultPasteboard setString:content];
        return;
    }
    [super copy:sender];
}

- (void)cut:(id)sender {
    NSRange range = self.selectedRange;
    NSString *content = [self getStrContentInRange:range];
    if (content.length > 0) {
        [super cut:sender];
        UIPasteboard *defaultPasteboard = [UIPasteboard generalPasteboard];
        [defaultPasteboard setString:content];
        return;
    }
    [super cut:sender];
}

#pragma mark - 协议方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	textView.typingAttributes = _textTypingAttributes;
	NSAttributedString *abs =  [FaceTextManager attributedStringForString:text andFont:[UIFont systemFontOfSize:_fontSize] andLineHeight:_lineHeight];
	if (abs.length < text.length) {
		[self changeTextWithRange:range andText:text andTextView:textView];
		return NO;
	}
	return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	textView.typingAttributes = _textTypingAttributes;
	return YES;
}
#pragma mark - public method
-(void)setTextType:(InputTextViewType)textType
{
	_textType = textType;
	if (_textType == InputTextViewType_text) {
		[self becomeFirstResponder];//成为第一响应者
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), (^{
			  self.selectedRange = self->_currentTextRange;
		   }));
	}else if(_textType == InputTextViewType_face){
		_currentTextRange = self.selectedRange;
		[self resignFirstResponder];
	}else if (_textType == InputTextViewType_dismiss){
		_currentTextRange = NSMakeRange(self.attributedText.length, 0);
		[self resignFirstResponder];
		if ([self.input_delegate respondsToSelector:@selector(dismissInputTextView:)]) {
			[self.input_delegate dismissInputTextView:self];
		}
	}
}
-(void)addFaceText:(NSString *)faceText
{
	if (faceText)
	{
	   [self changeTextWithRange:NSMakeRange(_currentTextRange.location, faceText.length) andText:faceText andTextView:self];
	   [self scrollRangeToVisible:_currentTextRange];
	   //修改当前 textRange
	   _currentTextRange = NSMakeRange(_currentTextRange.location + 1, _currentTextRange.length);
	}
}

-(void)clearText
{
	NSMutableAttributedString *abs = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
	[abs deleteCharactersInRange:NSMakeRange(0, abs.length)];
	self.attributedText = abs;
	_currentTextRange = NSMakeRange(0, 0);
	//修改了 输入框文字
	[self textViewDidChangeText];
}

- (NSString *)getStrContentInRange:(NSRange)range {
	return  [FaceTextManager originalTextInRange:range withAttributedText:self.attributedText];
}
//查找当前文本
-(NSString *)currentText
{
	return [FaceTextManager originalTextWithAbs:self.attributedText];
}

-(void)deleteOneText
{
	if (_currentTextRange.location <= 0) return;
	NSMutableAttributedString *abs = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
	_currentTextRange = NSMakeRange(_currentTextRange.location - 1, 0);
	[abs deleteCharactersInRange:NSMakeRange(_currentTextRange.location, 1)];
	self.attributedText = abs;
	[self textViewDidChangeText];
}

-(NSRange)textRangeWithRange:(NSRange)range
{
	return [FaceTextManager textRangeWithRange:range withAttributeString:self.attributedText];
}

-(void)dealloc
{
	//移除通知监听
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
