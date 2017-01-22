//
//  ViewController.m
//  NKCWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "ViewController.h"

#import "NKCWeakTimer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *countingLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property  NSInteger count;
@property (nonatomic, strong) NKCWeakTimer *weakTimer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"mm:ss.SSS";
}

- (IBAction)startTimerAction:(id)sender {
    self.count = 0;
    self.messageTextView.text = @"";
    __weak ViewController *weakSelf = self;
    self.weakTimer = [NKCWeakTimer scheduledTimerWithTimeInterval:1.0f userInfo:nil repeats:TRUE block:^(NKCWeakTimer * _Nonnull timer) {
        weakSelf.count++;
        NSString *dateString = [weakSelf.dateFormatter stringFromDate:[NSDate date]];
        weakSelf.messageTextView.text = [NSString stringWithFormat:@"count = %ld, fireTime = %@\n%@", weakSelf.count, dateString, weakSelf.messageTextView.text];
        weakSelf.countingLabel.text = [NSString stringWithFormat:@"%ld", weakSelf.count];
    }];
}

- (IBAction)fireAction:(id)sender {
    [self.weakTimer fire];
}

- (IBAction)stopAction:(id)sender {
    [self.weakTimer invalidate];
}

@end
