//
//  ViewController.m
//  DCURLRouter_Demo
//
//  Created by lijun on 2018/3/12.
//  Copyright © 2018年 lijun. All rights reserved.
//

#import "ViewController.h"
#import "DCURLRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)jump:(id)sender {
    NSString *urlStr = @"https://www.baidu.com";
    [DCURLRouter pushURLString:urlStr animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
