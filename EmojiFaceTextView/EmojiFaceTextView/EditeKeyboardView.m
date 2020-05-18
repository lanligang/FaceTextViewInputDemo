//
//  EditeKeyboardView.m
//  ChatUI2020
//
//  Created by ios2 on 2020/5/7.
//  Copyright © 2020 CY. All rights reserved.
//

#import "EditeKeyboardView.h"
#import "Masonry.h"
#import "FaceTextManager.h"
#import "InputTextView.h"  //输入框
#import "NSBundle+FaceImage.h"

static float inputKeyBoardHeight = 150.0;

static float faceView_height = 240.0f;
@interface EditeKeyboardView()
<InputTextViewDelegate>
@end


@implementation EditeKeyboardView
{
    UIVisualEffectView *_effectView;
    UIButton *_commitBtn;
	UIView * _faceView;  //表情面板
	NSRange _currentTextRange; //当前输入框的位置
	UIButton * _faceButton;    //表情按钮
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        //创建蒙版
        [self initSubViews];
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.alpha = 0.7;
        effectView.userInteractionEnabled = NO;
        effectView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        [self insertSubview:effectView atIndex:0];
        _effectView = effectView;
    }
    return self;
}

#pragma mark - 创建控件
- (void)initSubViews
{
    self.frame = [UIScreen mainScreen].bounds;     //设置成屏幕大小
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];

    self.textView.textColor = [UIColor blackColor];
    [self.textView setContentInset:UIEdgeInsetsMake(5, 10, 5, 5)];

    [self addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];

    [self addTarget:self action:@selector(downKeyBoard:) forControlEvents:UIControlEventTouchUpInside];

    //添加评论按钮
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:@"发布" forState:UIControlStateNormal];
    _commitBtn = commitBtn;
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [commitBtn setTitleColor:[self colorRred:0xd9 andGreen:0xd9 abdBlue:0xd9] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[self colorRred:0x2a andGreen:0x8b abdBlue:0xd3] forState:UIControlStateSelected];


    [self.contentView addSubview:commitBtn];
	[commitBtn addTarget:self action:@selector(commitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textView.mas_right).offset(2.0);
        make.centerY.equalTo(self.textView);
        make.right.mas_equalTo(-2);
        make.height.mas_equalTo(25.0);
    }];

	[self loadFaceView];

	UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[faceButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[faceButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
	faceButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
	[faceButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
	_faceButton = faceButton;
	[self.contentView addSubview:faceButton];
	[faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.textView.mas_left).offset(2);
		make.top.equalTo(self.textView.mas_bottom).offset(2);
		make.height.mas_equalTo(30);
		make.width.mas_equalTo(30);
	}];
}

-(void)faceButtonClicked:(id)sender
{
	_faceButton.selected = !_faceButton.selected;
	if (!_faceButton.selected) {
		InputTextView *tv = (InputTextView *)self.textView;
		tv.textType = InputTextViewType_text;
	}else{
		_faceView.hidden = NO;
		InputTextView *tv = (InputTextView *)self.textView;
		tv.textType = InputTextViewType_face;
	}
}

-(void)loadFaceView
{
	UIView *faceView = [UIView new];
	faceView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - faceView_height, CGRectGetWidth(self.bounds), faceView_height);
	faceView.backgroundColor =[UIColor whiteColor];
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 2, CGRectGetWidth(faceView.bounds), faceView_height - 2)];
	[faceView addSubview:scrollView];

	_faceView = faceView;
	_faceView.hidden = YES;
	[self addSubview:faceView];
	NSInteger coloum = 8;
	CGFloat itemSpace = 10;

	CGFloat item_w = (CGRectGetWidth(self.bounds) - 20 - itemSpace * (coloum -1)) / coloum;

	NSArray *faceArray = [FaceTextManager manager].faceDataArray.firstObject;
	for (int i = 0; i< faceArray.count+ 1 ; i++) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[scrollView addSubview:button];
		button.tag = i + 100;
		button.frame = CGRectMake((i % coloum) * (item_w + itemSpace)  + 10 , i/coloum * (item_w + itemSpace) + 10, item_w, item_w);
		[button addTarget:self action:@selector(emojiButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		if (i<faceArray.count) {
			NSDictionary *mdic = faceArray [i];
			NSString *imageName = mdic[@"image"];
			UIImage *image =  [NSBundle faceImage:[NSString stringWithFormat:@"%@", imageName]];
			[button setImage:image forState:UIControlStateNormal];
		}
		scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame), CGRectGetMaxY(button.frame));
	}

	//创建一个删除按钮



	UIButton *faceDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[scrollView addSubview:faceDeleteButton];
	faceDeleteButton.backgroundColor =[UIColor whiteColor];
	UIImage *image = [UIImage imageNamed:@"Delete_ios7"];
	[faceDeleteButton setImage:image forState:UIControlStateNormal];
	[faceView addSubview:faceDeleteButton];
	faceDeleteButton.frame = CGRectMake(CGRectGetWidth(scrollView.bounds) - item_w - 10, CGRectGetMaxY(scrollView.frame) - 30 - item_w, item_w, item_w);
	[faceDeleteButton addTarget:self action:@selector(deleteClickedAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)deleteClickedAction:(id)sender
{
	InputTextView *textV  =  (InputTextView *)self.textView;
	[textV deleteOneText];
}

-(void)emojiButtonClicked:(UIButton *)button
{
	NSArray *faceArray = [FaceTextManager manager].faceDataArray.firstObject;
	NSInteger index = button.tag - 100;
	InputTextView *textV  =  (InputTextView *)self.textView;
	if (index < faceArray.count) {
		NSDictionary *mdic = faceArray [index];
		NSString *text = mdic[@"text"];
		[textV addFaceText:text];
	}
}
//点击提交按钮
-(void)commitClicked:(id)sender
{
	NSAttributedString *text =  [self.textView.attributedText copy];
	InputTextView *textV  =  (InputTextView *)self.textView;
	[textV clearText];
	if ([self.delegate respondsToSelector:@selector(editeKeyboardView:clickedCommitWithText:)]) {
		[self.delegate editeKeyboardView:self clickedCommitWithText:text];
	}else{
		!_clickedCommitText?:_clickedCommitText(text);   //提交评论按钮
	}
	[self dismiss];  //隐藏
}
#pragma mark - InputTextViewDelegate
-(void)inputTextView:(InputTextView *)textView
didChangeAbsText:(NSAttributedString *)absText
		 andOriginalText:(NSString *)originalText
{
	BOOL isShowSend = (absText.length > 0 && absText.length != NSNotFound);
	_commitBtn.userInteractionEnabled = isShowSend;
	_commitBtn.selected = isShowSend;

	if ([self.delegate respondsToSelector:@selector(editeKeyboardView:textDidChange:)]) {
		[self.delegate editeKeyboardView:self textDidChange:self.textView];
	}else{
		!_textDidChangeText?:_textDidChangeText(self.textView);
	}
}


- (void)downKeyBoard:(id)sender
{
    [self.textView resignFirstResponder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"]) {
		if ([self.delegate respondsToSelector:@selector(editeKeyboardView:didChangeHiddenState:)]) {
			[self.delegate editeKeyboardView:self didChangeHiddenState:self.hidden];
		}else{
			!_didChangeHiddenState ? : _didChangeHiddenState(self.hidden);
		}
    }
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
		_contentView.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), inputKeyBoardHeight);
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[InputTextView alloc]initWithFontSize:20.0 andTextColor:[UIColor redColor] andLineHeight:4.0];

		InputTextView *inputV = (InputTextView *)_textView;
		inputV.input_delegate = self;

        _textView.layer.cornerRadius = 5.0;
        _textView.layer.borderColor = [self colorRred:0xf5 andGreen:0xf5 abdBlue:0xf5].CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.clipsToBounds = YES;
        _textView.backgroundColor = [self colorRred:0xf5 andGreen:0xf5 abdBlue:0xf5];
        [self.contentView addSubview:_textView];

        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-80);
            make.top.mas_equalTo(15);
            make.bottom.mas_equalTo(-40.0);
        }];
        self.contentView.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), inputKeyBoardHeight);
    }
    return _textView;
}

- (UIColor *)colorRred:(CGFloat)r andGreen:(CGFloat)g abdBlue:(CGFloat)b
{
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
}

- (void)keyBoardWillShowNotification:(NSNotification *)noti
{
    //在可视区域内
	_faceView.hidden = YES;
	_faceButton.selected = NO;
    NSDictionary *keyBordInfo = [noti userInfo];
    NSValue *value = [keyBordInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardRect = [value CGRectValue];
    float height = keyBoardRect.size.height;
    float duration = [keyBordInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    CGRect f = CGRectMake(0, CGRectGetHeight(self.frame) - height - inputKeyBoardHeight, CGRectGetWidth(self.frame), inputKeyBoardHeight);
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = f;
    }];
}

- (void)keyBoardWillHideNotification:(NSNotification *)noti
{
	InputTextView *textV = (InputTextView *)self.textView;
	if (textV.textType == InputTextViewType_face) {
		CGFloat height = faceView_height;
		[UIView animateWithDuration:0.2 animations:^{
			   self.contentView.frame = CGRectMake(0, CGRectGetHeight(self.frame)- height - inputKeyBoardHeight, CGRectGetWidth(self.frame), inputKeyBoardHeight);
		   } completion:nil];
		return;
	}else{
		_effectView.hidden = YES;
		[UIView animateWithDuration:0.2 animations:^{
			self.contentView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), inputKeyBoardHeight);
		} completion:nil];
	}
}

- (void)keyBoardDidHideNotification:(NSNotification *)noti
{
	if (!_faceView.hidden) {
		_faceButton.selected = YES;
		CGFloat height = faceView_height;
		[UIView animateWithDuration:0.2 animations:^{
			   self.contentView.frame = CGRectMake(0, CGRectGetHeight(self.frame)- height - inputKeyBoardHeight, CGRectGetWidth(self.frame), inputKeyBoardHeight);
		   } completion:nil];
		return;
	}
    __weak typeof(self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), (^{
        ws.hidden = YES;
    }));
}

#pragma mark - publick method

- (void)dismiss
{
	[self downKeyBoard:nil];//取消第一响应
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), inputKeyBoardHeight);
    } completion:nil];

    __weak typeof(self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), (^{
        ws.hidden = YES;
    }));
}
-(void)clearText
{
	self.textView.attributedText = [[NSAttributedString alloc]initWithString:@""];
}
- (void)show {
    self.hidden = NO;
    _effectView.hidden = NO;
	self.contentView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - inputKeyBoardHeight, CGRectGetWidth(self.bounds), inputKeyBoardHeight);
    [self.textView becomeFirstResponder];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"hidden"];
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
