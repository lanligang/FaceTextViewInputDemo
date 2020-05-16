//
//  InputTextView.m
//  ChatUI2020
//
//  Created by ios2 on 2020/5/15.
//  Copyright © 2020 CY. All rights reserved.
//

#import "InputTextView.h"
#import "EmojiTextAttachment.h"

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
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:10];
    NSRange effectiveRange = NSMakeRange(range.location, 0);
    NSUInteger length = NSMaxRange(range);
    while (NSMaxRange(effectiveRange) < length) {
        NSTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if (attachment) {
            if ([attachment isKindOfClass:[EmojiTextAttachment class]]) {
                EmojiTextAttachment *emojiAttachment = (EmojiTextAttachment *) attachment;
                [result appendString:emojiAttachment.emojiText];
            }
        } else {
            NSString *subStr = [self.text substringWithRange:effectiveRange];
            [result appendString:subStr];
        }
    }
    return [result copy];
}
//查找当前文本
-(NSString *)currentText
{
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:10];
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger length = NSMaxRange(NSMakeRange(0, self.attributedText.length));
    while (NSMaxRange(effectiveRange) < length) {
        NSTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if (attachment) {
            if ([attachment isKindOfClass:[EmojiTextAttachment class]]) {
                EmojiTextAttachment *emojiAttachment = (EmojiTextAttachment *) attachment;
                [result appendString:emojiAttachment.emojiText];
            }
        } else {
            NSString *subStr = [self.text substringWithRange:effectiveRange];
            [result appendString:subStr];
        }
    }
    return [result copy];
}

-(NSRange)textRangeWithRange:(NSRange)range
{
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger length = NSMaxRange(NSMakeRange(0, self.attributedText.length));
	NSInteger rangeAdd = 0;
    while (NSMaxRange(effectiveRange) < length) {
        NSTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if (attachment) {

            if ([attachment isKindOfClass:[EmojiTextAttachment class]]) {
				//如果是 emoji 表情的 附件 给改索引值加一
                EmojiTextAttachment *emojiAttachment = (EmojiTextAttachment *) attachment;
				rangeAdd = rangeAdd + (emojiAttachment.emojiText.length -1);
            }
        }
		if (effectiveRange.location + effectiveRange.length >= range.location) {
			break;
		}
    }
    return NSMakeRange(range.location+rangeAdd, range.length);
}


@end
