//
//  FLYRechargeViewController.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYRechargeViewController : FLYBaseViewController<UIActionSheetDelegate,UITextFieldDelegate>{
    UILabel *infoLabel;
    UITextField *amountLabel;
    UIButton *okBtn;
    NSString *privateKey;
    NSString *publicKey;
}

@property (weak, nonatomic) IBOutlet UITextField *moneyText;

- (IBAction)backgroupTap:(id)sender;


@end
