//
//  ViewController.m
//  EmojiFaceTextView
//
//  Created by ios2 on 2020/5/16.
//  Copyright © 2020 CY. All rights reserved.
//

#import "ViewController.h"
#import "EditeKeyboardView.h"
@interface ViewController ()
{
	EditeKeyboardView * _editeV;
}
@end

@implementation ViewController
-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}
- (void)viewDidLoad {
	[super viewDidLoad];
	_editeV = [[EditeKeyboardView alloc]init];
	_editeV.hidden = YES;
	[self.view addSubview:_editeV];
	
}

- (IBAction)commitClicked:(id)sender {
	[_editeV show];
}




@end
