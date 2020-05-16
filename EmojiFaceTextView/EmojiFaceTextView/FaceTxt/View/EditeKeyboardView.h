//
//  EditeKeyboardView.h
//  ChatUI2020
//
//  Created by ios2 on 2020/5/7.
//  Copyright © 2020 CY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EditeKeyboardView;

@protocol EditeTextViewDelegate <NSObject>
@optional
//输入框进行输入
-(void)editeKeyboardView:(EditeKeyboardView *)editeView textDidChange:(UITextView *)textView;
//点击了提交按钮
-(void)editeKeyboardView:(EditeKeyboardView *)editeView clickedCommitWithText:(NSAttributedString *)text;
//隐藏和显示状态变化
-(void)editeKeyboardView:(EditeKeyboardView *)editeView didChangeHiddenState:(BOOL)isHidden;
@end

@interface EditeKeyboardView : UIControl<UITextViewDelegate> 

@property(nonatomic,weak)id <EditeTextViewDelegate> delegate;

@property (nonatomic,strong)UITextView *textView;    //输入框
@property (nonatomic,strong)UIView *contentView;
// ===========================================================
@property (nonatomic,copy)void(^didChangeHiddenState)(BOOL isHidden);     //手否隐藏状态发生改变
@property (nonatomic,copy)void(^textDidChangeText)(UITextView *textView); //文字正在编辑
@property (nonatomic,copy)void(^clickedCommitText)(NSAttributedString *text);       //点击提交评论

-(void)show;   //显示

-(void)clearText; //清理掉文字

@end


NS_ASSUME_NONNULL_END
