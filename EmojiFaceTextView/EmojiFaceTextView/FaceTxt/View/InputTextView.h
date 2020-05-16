//
//  InputTextView.h
//  ChatUI2020
//
//  Created by ios2 on 2020/5/15.
//  Copyright © 2020 CY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputTextView : UITextView
//查找当前文本
-(NSString *)currentText;

//根据现有范围读取当前范围
-(NSRange)textRangeWithRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
