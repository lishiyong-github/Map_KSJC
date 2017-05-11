//
//  SettingControlPanel.m
//  wenjiang
//
//  Created by zhangliang on 13-12-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "SettingControlPanel.h"

@implementation SettingControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

-(void)createSubViews{
    /*
     UILabel *lblServerIp = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, 100, 30)];
     lblServerIp.text = @"服务器地址";
     lblServerIp.backgroundColor = [UIColor clearColor];
     
     UITextField *txtServerIp = [[UITextField alloc] initWithFrame:CGRectMake(30, 110, 200, 40)];
     txtServerIp.borderStyle = UITextBorderStyleLine;
     txtServerIp.layer.borderWidth = 2;
     txtServerIp.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
     txtServerIp.layer.borderColor = [[UIColor grayColor] CGColor];
     txtServerIp.text = @"192.168.1.39";
     
     [self addSubview:lblServerIp];
     [self addSubview:txtServerIp];
     */
    
    UILabel *lblDiskInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 280, 20)];
    lblDiskInfo.text = @"株洲规划局移动监察系统";
    lblDiskInfo.font = [lblDiskInfo.font fontWithSize:16];
    lblDiskInfo.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:lblDiskInfo];
    
    UIView *sysInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.frame.size.width, 280)];
    sysInfoView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:sysInfoView];
    
    UILabel *sysText = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40,240)];
    [sysText setNumberOfLines:0];
    
    //设置字体
    sysText.font = [sysText.font fontWithSize:13];
    NSString *text=@" 建设宜居城市，需要科学的规划，更需要有力的监管，随着现代网络、通信技术、终端设备的发展也推动着规划执法监察的方式的转变，我们也积极探寻移动监察信息化应用方式，通过系统的建设覆盖规划批后管理的各个环节，实行“全员监管”、“全程监管”在规划管理的各个环节严格把关，防范规划项目违法违规行为的发生。形成“发现及时、处置快速、解决有效、监督有力”的长效管理机制，为规划的管理决策提供支持，也是利用现代科学技术提高行政管理能力的有效措施。";
    
    sysText.text = text;
    [sysInfoView addSubview:sysText];
    
    UIView *copyrightView = [[UIView alloc] initWithFrame:CGRectMake(0, 360, self.frame.size.width, 50)];
    copyrightView.backgroundColor = [UIColor whiteColor];
    
    UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 16, 280, 20)];
    [copyrightLabel setFont:[copyrightLabel.font fontWithSize:14]];
    copyrightLabel.backgroundColor=[UIColor clearColor];
    copyrightLabel.text = @"上海数慧系统技术有限公司 @Copyright";
    [copyrightView addSubview:copyrightLabel];
    [self.contentView addSubview:copyrightView];
   
    /*
    UILabel *cacheSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-70, 8, 60, 40)];
    [cacheSizeLabel setFont:[cacheSizeLabel.font  fontWithSize:18]];
    cacheSizeLabel.text = @"12";
    cacheSizeLabel.backgroundColor = [UIColor clearColor];
    
    [cacheView addSubview:cacheViewTitle];
    [cacheView addSubview:cacheSizeLabel];
    
    [self.contentView addSubview:cacheView];
    UIView *resourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 115, self.frame.size.width, 50)];
    resourceView.backgroundColor = [UIColor whiteColor];
    
    UILabel *resourceViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(17, 16, 100, 20)];
    resourceViewTitle.text = @"本地资源(MB)";
    [resourceViewTitle setFont:[resourceViewTitle.font fontWithSize:14]];
    resourceViewTitle.backgroundColor = [UIColor clearColor];
    
    UILabel *resourceSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-70, 8, 60, 40)];
    [resourceSizeLabel setFont:[cacheSizeLabel.font  fontWithSize:18]];
    resourceSizeLabel.text = @"24";
    resourceSizeLabel.backgroundColor = [UIColor clearColor];
    
    [resourceView addSubview:resourceViewTitle];
    [resourceView addSubview:resourceSizeLabel];
    
    [self.contentView addSubview:resourceView];
    */
    
    UIView *versionView = [[UIView alloc] initWithFrame:CGRectMake(0, 420, self.frame.size.width, 50)];
    versionView.backgroundColor = [UIColor whiteColor];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 16, 120, 20)];
    [versionLabel setFont:[versionLabel.font fontWithSize:14]];
    versionLabel.backgroundColor=[UIColor clearColor];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    versionLabel.text = [NSString stringWithFormat:@"当前版本：%@",currentVersion];
    [versionView addSubview:versionLabel];
    [self.contentView addSubview:versionView];
    
    /*
    SysButton *checkUpdateButton = [SysButton buttonWithType:UIButtonTypeCustom];
    [checkUpdateButton setTitle:@"检测更新" forState:UIControlStateNormal];
    [checkUpdateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkUpdateButton setBackgroundColor:[UIColor colorWithRed:61.0/255.0 green:136.0/255.0 blue:243.0/255.0 alpha:1]];
    checkUpdateButton.defaultBackground = checkUpdateButton.backgroundColor;
    checkUpdateButton.frame = CGRectMake(self.frame.size.width-130, 280, 120, 40);
    checkUpdateButton.layer.cornerRadius = 8;
    [self.contentView addSubview:checkUpdateButton];
    */
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
