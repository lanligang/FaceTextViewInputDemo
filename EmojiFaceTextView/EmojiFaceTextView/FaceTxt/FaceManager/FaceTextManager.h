//
//  FaceTextManager.h
//  LGCHAT
//
//  Created by ios2 on 2019/10/29.
//  Copyright © 2019 CY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MatchingResult.h"
#import "EmojiModel.h"

@interface FaceTextManager : NSObject

//表情数组
@property (nonatomic, strong) NSMutableArray *faceDataArray;

//表情只加载一次
+ (instancetype)manager;

//加载所有的表情策略

/** 只调用一次
  faces plist 名称数组
 */
+ (void)loadLocalFaceSourceNames:(NSArray<NSString *> *)faces;

/** 获取表情富文本   | >>  ~~~ [开心] ····· 格式
 * text ： 原始文本
 * font  ： 字号
 * lineHeight ： 行高
 */
+ (NSMutableAttributedString *)attributedStringForString:(NSString *)text
                                                 andFont:(UIFont *)font
                                           andLineHeight:(CGFloat)lineHeight;

//获取某个富文本的size
/**
 *  attributedString : 富文本字符串
 *  maxWidth    ： 最大宽度
 * return size
 */
+ (CGSize)sizeForAttributedString:(NSAttributedString *)attributedString
                      andMaxWidth:(CGFloat)maxWidth;
/**
*  直接替换使用富文本替换表情
 * attributedString : 富文本
 */
- (void)replaceEmojiForAttributedString:(NSMutableAttributedString *)attributedString
								   font:(UIFont *)font;

/**
 *  range 富文本每个附件算一个 长度的range
 *  attributedText  带有附件的富文本
 *  return NSRange   得到转化成 '[笑哭]aaa[奸笑]防守打法的'匹配文本后光标所在的位置
 **/
+(NSRange)textRangeWithRange:(NSRange)range
		 withAttributeString:(NSAttributedString *)attributedText;
/**
 *  获取富文本本指定范围内的未转化的文字 比如:  aaa[捂脸]bbb
 *  return string 类型
 */
+ (NSString *)originalTextInRange:(NSRange)range
				withAttributedText:(NSAttributedString *)abs;


/**
 * 方法和上面的一样都是用来查找当前文字 只是查找范围大小不同
 **/
+(NSString *)originalTextWithAbs:(NSAttributedString *)abs;


@end

