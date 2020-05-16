//
//  InputTextView.m
//  ChatUI2020
//
//  Created by ios2 on 2020/5/15.
//  Copyright © 2020 CY. All rights reserved.
//

#import "InputTextView.h"
#import "FaceTextManager.h"
@implementation InputTextView

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
- (NSString *)getStrContentInRange:(NSRange)range {
	return  [FaceTextManager originalTextInRange:range withAttributedText:self.attributedText];
}
//查找当前文本
-(NSString *)currentText
{
	return [FaceTextManager originalTextWithAbs:self.attributedText];
}

-(NSRange)textRangeWithRange:(NSRange)range
{
	return [FaceTextManager textRangeWithRange:range withAttributeString:self.attributedText];
}


@end
