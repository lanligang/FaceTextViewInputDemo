//
//  MatchingResult.h
//  LGCHAT
//
//  Created by ios2 on 2019/10/29.
//  Copyright © 2019 CY. All rights reserved.
//

#import <UIKit/UIKit.h>

//匹配结果

@interface MatchingResult : NSObject
@property (nonatomic, assign) NSRange range;                // 匹配到的表情包文本的range
@property (nonatomic, strong) UIImage *emojiImage;          // 如果能在本地找到emoji的图片，则此值不为空
@property (nonatomic, strong) NSString *showingDescription; // 表情的实际文本(形如：[哈哈])，不为空
@end

