//
//  PersistView.h
//  fh-ios-sdk
//
//  Created by Craig Brookes on 31/01/2012.
//  Copyright (c) 2012 Feedhenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersistView : UIViewController<UITextFieldDelegate>{
    UITextField * keyStore;
    UITextField * valStore;
    UITextField * valRet;
    UILabel *valShow;
    CGRect oldTextField;
    CGRect oldButton;
    UILabel * topersist;
    UIButton * persistButton;
    UIButton * retButton;
}

@property(strong,nonatomic)IBOutlet UITextField  * keyStore;
@property(nonatomic,strong)IBOutlet UITextField * valStore;
@property(nonatomic,strong)IBOutlet UITextField * keyRet;
@property(strong,nonatomic)IBOutlet UILabel * valShow;
@property(strong,nonatomic)IBOutlet UILabel * topersist;
@property(nonatomic,strong)IBOutlet UIButton * retButton;
@property(nonatomic,strong)IBOutlet UIButton * persistButton;
- (IBAction)saveData;
- (IBAction)retreieveData;

@end
