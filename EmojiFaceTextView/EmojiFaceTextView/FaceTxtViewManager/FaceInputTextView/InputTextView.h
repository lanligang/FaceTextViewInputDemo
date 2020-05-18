//
//  InputTextView.h
//  ChatUI2020
//
//  Created by ios2 on 2020/5/15.
//  Copyright © 2020 CY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, InputTextViewType) {
    InputTextViewType_text = 0,    // 文本输入类型
	InputTextViewType_face = 1,    //表情
	InputTextViewType_dismiss = 2, //不进行表情和文本的输入
};

@class InputTextView;

@protocol InputTextViewDelegate <NSObject>

@optional
/**  输入框中文字发生变化
 *   textView     输入框
 *   absText      输入框中的富文本   显示为： 我是这样的表情🌶
 *   originalText 未加表情时的原始文字   如： 我是这样的表情[辣椒]
 */
-(void)inputTextView:(InputTextView *)textView
	didChangeAbsText:(NSAttributedString *)absText
			 andOriginalText:(NSString *)originalText;
//设置消失类型
-(void)dismissInputTextView:(InputTextView *)textView;

@end


@interface InputTextView : UITextView<UITextViewDelegate>

/**  类构造方法  推荐使用该方法初始化
 *  fontSize   - 字符大小
 *  extColor   - 文字颜色
 *  lineHeight - 行间距
 **/
+(instancetype)textViewWitnFontSize:(CGFloat)fontSize
					   andTextColor:(UIColor *)textColor
					  andLineHeight:(CGFloat)lineHeight;

//初始化控件 fontSize - 字符大小  textColor - 文字颜色  lineHeight - 行间距
-(instancetype)initWithFontSize:(CGFloat)fontSize
				   andTextColor:(UIColor *)textColor
				  andLineHeight:(CGFloat)lineHeight;

//输入面板的代理方法
@property(nonatomic,weak)id <InputTextViewDelegate> input_delegate;

@property(nonatomic,assign)InputTextViewType textType; //修改类型调用 用来修改键盘升降

//添加表情文字 如 ： [开心]
-(void)addFaceText:(NSString *)faceText;

//清理掉富文本文字
-(void)clearText;

//删除一个文字或者表情
-(void)deleteOneText;


@end

NS_ASSUME_NONNULL_END
