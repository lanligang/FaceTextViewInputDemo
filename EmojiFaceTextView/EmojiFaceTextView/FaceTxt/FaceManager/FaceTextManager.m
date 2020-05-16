//
//  FaceTextManager.m
//  LGCHAT
//
//  Created by ios2 on 2019/10/29.
//  Copyright © 2019 CY. All rights reserved.
//

#import "FaceTextManager.h"
#import "NSBundle+FaceImage.h"
#import "EmojiTextAttachment.h"
@interface FaceTextManager ()
@end

@implementation FaceTextManager

+ (instancetype)manager {
    static FaceTextManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FaceTextManager alloc] init];
    });
    return manager;
}

+ (void)loadLocalFaceSourceNames:(NSArray<NSString *> *)faces {
    if (faces && [faces isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < faces.count; i++) {
            NSString *plistName = faces[i];
            NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
            if (path) {
                id faceSource = [[NSArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
                if (faceSource && [faceSource isKindOfClass:[NSArray class]])
				 {
                    [[FaceTextManager manager].faceDataArray addObject:faceSource];
                }
            }
        }
    }
}

+ (NSMutableAttributedString *)attributedStringForString:(NSString *)text
                                                 andFont:(UIFont *)font
                                           andLineHeight:(CGFloat)lineHeight {
    if (text && [text isKindOfClass:[NSString class]]) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = lineHeight; //设置行间距
        NSMutableAttributedString *abs = [[NSMutableAttributedString alloc] initWithString:text
                                                                                attributes:@{
                                                                                    NSFontAttributeName: font,
                                                                                    NSParagraphStyleAttributeName: style
                                                                                }];
        [[FaceTextManager manager] replaceEmojiForAttributedString:abs font:font];
        NSMutableParagraphStyle *phstyle = [[NSMutableParagraphStyle alloc] init];
        phstyle.lineSpacing = lineHeight;
        [abs addAttribute:NSParagraphStyleAttributeName value:phstyle range:NSMakeRange(0, abs.length)];
        return abs;
    }
    return nil;
}

+ (CGSize)sizeForAttributedString:(NSAttributedString *)attributedString
                      andMaxWidth:(CGFloat)maxWidth {
    if (!attributedString)
        return CGSizeZero;
    CGSize attSize = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    CGFloat textHeight = ceill(attSize.height);
    attSize.height = textHeight;
    return attSize;
}
#pragma mark - public method
//替换文本的核心代码
- (void)replaceEmojiForAttributedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font {
    if (!attributedString || !attributedString.length || !font) {
        return;
    }
    NSArray<MatchingResult *> *matchingResults = [self matchingEmojiForString:attributedString.string];

    if (matchingResults && matchingResults.count) {
        NSUInteger offset = 0;
        for (MatchingResult *result in matchingResults) {
            if (result.emojiImage) {
                CGFloat emojiHeight = font.lineHeight; //行高
                EmojiTextAttachment *attachment = [[EmojiTextAttachment alloc] init];
                attachment.image = result.emojiImage;
                attachment.emojiText = result.showingDescription;
                attachment.bounds = CGRectMake(0, font.descender, emojiHeight, emojiHeight);
                NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                if (!emojiAttributedString) {
                    continue;
                }
                NSRange actualRange = NSMakeRange(result.range.location - offset, result.showingDescription.length);
                [attributedString replaceCharactersInRange:actualRange withAttributedString:emojiAttributedString];
                offset += result.showingDescription.length - emojiAttributedString.length;
            }
        }
    }
}

#pragma mark - private method

- (NSArray<MatchingResult *> *)matchingEmojiForString:(NSString *)string {
    if (!string.length) {
        return nil;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\]" options:0 error:NULL];

    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];

    if (results && results.count)
	{
        NSMutableArray *emojiMatchingResults = [[NSMutableArray alloc] init];

        for (NSTextCheckingResult *result in results)
		{
            NSString *showingDescription = [string substringWithRange:result.range]; //拿到系统的文字

            //			NSString *emojiSubString = [showingDescription substringFromIndex:1];       // 去掉[
            //
            //			emojiSubString = [emojiSubString substringWithRange:NSMakeRange(0, emojiSubString.length - 1)];    // 去掉]
            EmojiModel *emoji = [self emojiWithEmojiDescription:showingDescription]; //通过表情库拿表情 model
            if (emoji) {
                MatchingResult *emojiMatchingResult = [[MatchingResult alloc] init];
                emojiMatchingResult.range = result.range;
                emojiMatchingResult.showingDescription = showingDescription;

                emojiMatchingResult.emojiImage = [NSBundle faceImage:[NSString stringWithFormat:@"%@@3x", emoji.imageName]]; //加载图片
                [emojiMatchingResults addObject:emojiMatchingResult];
            }
        }
        return emojiMatchingResults;
    }
    return nil;
}
//构造 一个Emojimodel
- (EmojiModel *)emojiWithEmojiDescription:(NSString *)emojiDescription {
	//表情数组
    for (NSArray *faceDicArray in self.faceDataArray) {
	   NSString *predStr = [NSString stringWithFormat:@" text  = '%@'",emojiDescription];
	   NSPredicate *pred = [NSPredicate predicateWithFormat:predStr];
	   NSArray *array =  [faceDicArray filteredArrayUsingPredicate:pred];
	   if (!array) return nil;
	   NSDictionary *faceDic = (NSDictionary *)array.firstObject;
	   EmojiModel *emoji = [[EmojiModel alloc] init];
	   emoji.imageName = faceDic[@"image"]; // emojiDescription;//faceDic[emojiDescription];
	   emoji.emojiDescription = emojiDescription;
	   return emoji;
    }
    return nil;
}

+(NSRange)textRangeWithRange:(NSRange)range withAttributeString:(NSAttributedString *)attributedText
{
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger length = NSMaxRange(NSMakeRange(0, attributedText.length));
	NSInteger rangeAdd = 0;
    while (NSMaxRange(effectiveRange) < length) {
        NSTextAttachment *attachment = [attributedText attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if (attachment) {
            if ([attachment isKindOfClass:[EmojiTextAttachment class]]) {
				//如果是 emoji 表情的 附件 给改索引值加一
                EmojiTextAttachment *emojiAttachment = (EmojiTextAttachment *) attachment;
				rangeAdd = rangeAdd + (emojiAttachment.emojiText.length -1);
            }
        }
		if (effectiveRange.location + effectiveRange.length >= range.location) {
			break;  //如果超过我们想要找寻的位置 也可以说是光标位置就不在循环
		}
    }
    return NSMakeRange(range.location+rangeAdd, range.length);
}

//查找当前文本
+(NSString *)originalTextWithAbs:(NSAttributedString *)abs
{
	NSRange range = NSMakeRange(0, abs.length);
	return [self originalTextInRange:range withAttributedText:abs];
}

+ (NSString *)originalTextInRange:(NSRange)range
			   withAttributedText:(NSAttributedString *)abs {

    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:10];
    NSRange effectiveRange = NSMakeRange(range.location, 0);
    NSUInteger length = NSMaxRange(range);
    while (NSMaxRange(effectiveRange) < length) {
        NSTextAttachment *attachment = [abs attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if (attachment) {
            if ([attachment isKindOfClass:[EmojiTextAttachment class]]) {
                EmojiTextAttachment *emojiAttachment = (EmojiTextAttachment *) attachment;
                [result appendString:emojiAttachment.emojiText];
            }
        } else {
            NSString *subStr = [abs.string substringWithRange:effectiveRange];
            [result appendString:subStr];
        }
    }
    return [result copy];
}

#pragma mark - getter
- (NSMutableArray *)faceDataArray {
    if (!_faceDataArray) {
        _faceDataArray = [[NSMutableArray alloc] init];
    }
    return _faceDataArray;
}

@end
