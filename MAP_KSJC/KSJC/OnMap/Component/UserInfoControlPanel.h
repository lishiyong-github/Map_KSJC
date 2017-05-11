//
//  UserInfoControlPanel.h
//  wenjiang
//
//  Created by zhangliang on 13-12-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ControlPanel.h"
#import "SysButton.h"
#import "ServiceProvider.h"

@interface UserInfoControlPanel : ControlPanel<ServiceCallbackDelegate,UIAlertViewDelegate>{
    UITextField *pwd1;
    UITextField *pwd2;
    UITextField *pwd3;
    SysButton *modifyPwdButton;
}

@end
