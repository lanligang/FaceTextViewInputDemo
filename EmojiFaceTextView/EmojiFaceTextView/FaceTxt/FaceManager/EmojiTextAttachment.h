//
//  EmojiTextAttachment.h
//  FriendChat
//
//  Created by ios2 on 2019/11/20.
//  Copyright © 2019 石家庄光耀. All rights reserved.
//

#import <UIKit/UIKit.h>

//表情附件
@interface EmojiTextAttachment : NSTextAttachment

@property (nonatomic,strong)NSString *emojiText; //表情文本  用于复制文字使用 以及范围光标的查找等等



@end


