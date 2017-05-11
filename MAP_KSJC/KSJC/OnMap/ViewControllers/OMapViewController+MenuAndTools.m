//
//  OMapViewController+MenuAndTools.m
//  zzzf
//
//  Created by zhangliang on 14-3-7.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+MenuAndTools.h"

@implementation OMapViewController (MenuAndTools)

-(void)initMenuAndTools{
    
    [self setBoxLayerStyle:self.switchContainer.layer];
    
    self.mapView.gridLineWidth = 0;
    self.mapView.backgroundColor = [UIColor whiteColor];
    
    [self createMapToolbar];
    [self createDateSelector];
    
    self.btnNavMenu.layer.cornerRadius = 19;
    self.btnNavMenu.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btnNavMenu.layer.shadowOpacity = .5;
    self.btnNavMenu.layer.shadowOffset = CGSizeMake(0,1);
    
    self.btnNavCar.layer.cornerRadius = 19;
    self.btnNavCar.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btnNavCar.layer.shadowOpacity = .5;
    self.btnNavCar.layer.shadowOffset = CGSizeMake(0,1);
    
    self.orgView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.orgView.layer.shadowOpacity = .5;
    self.orgView.layer.shadowOffset = CGSizeMake(0,1);
    self.orgView.layer.cornerRadius = 2;
    self.orgView.backgroundColor = [UIColor whiteColor];
    
//    self.switchContainer.layer.cornerRadius = 5;
    
    
    //增加测量菜单面板
    _mearsureView = [[MearsureView alloc] initWithFrame:CGRectMake(400, self.mapView.frame.size.height-45, 340, 40)];
    _mearsureView.layer.shadowColor = [UIColor grayColor].CGColor;
    _mearsureView.layer.shadowOpacity = 1.0;
    _mearsureView.layer.shadowOffset = CGSizeMake(0,1);
    _mearsureView.backgroundColor = [UIColor whiteColor];
    [_mearsureView setHidden:YES];
    _mearsureView.mapView = self.mapView;
    _mearsureView.mapTouchDelegate = self;
    [_mearsureView CreatMearsureAGSSketchGraphicsLayer];
    [self.view addSubview:_mearsureView];
    
    _layerManager = [[LayerManager alloc] initWithFrame:CGRectMake(-300, 0, 300, 788)];
    _layerManager.delegate = self;
    _layerManager.layerDelegate = self;
    
//    _favoritePanel = [[FavoritePanel alloc] initWithFrame:CGRectMake(-250, 0, 250, 788)];
//    _favoritePanel.delegate = self;
//    _favoritePanel.favoriteDelegate = self;
    
    
    _userInfoPanel = [[UserInfoControlPanel alloc] initWithFrame:CGRectMake(-300, 0, 300, 788)];
    _userInfoPanel.delegate = self;
    
    _settingPanel = [[SettingControlPanel alloc] initWithFrame:CGRectMake(-300, 0, 300, 788)];
    _settingPanel.delegate = self;
    
    _currentDailyJobLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 20, 20)];
    _currentDailyJobLabel.layer.cornerRadius = 10;
    _currentDailyJobLabel.backgroundColor = [UIColor redColor];
    _currentDailyJobLabel.textColor = [UIColor whiteColor];
    _currentDailyJobLabel.textAlignment = NSTextAlignmentCenter;
    _currentDailyJobLabel.font = [_currentDailyJobLabel.font fontWithSize:12];
    _currentDailyJobLabel.hidden = YES;
    [self.mapComtainer addSubview:_currentDailyJobLabel];
    
    _searchResultPanel = [[MapSearchResultPanel alloc] initWithFrame:CGRectMake(143, 59, 484, 60)];
    _searchResultPanel.layer.cornerRadius = 5;
    _searchResultPanel.layer.shadowColor = [UIColor grayColor].CGColor;
    _searchResultPanel.layer.shadowOpacity = .5;
    _searchResultPanel.layer.shadowOffset = CGSizeMake(0,1);
    _searchResultPanel.hidden = YES;
    _searchResultPanel.delegate = self;
    [self.mapComtainer addSubview:_searchResultPanel];
}

-(void)createMapToolbar{
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    QuadCurveMenuItem *locateMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"maptool-locate"]
                                                         highlightedContentImage:nil];
    
    QuadCurveMenuItem *measureMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                 highlightedImage:storyMenuItemImagePressed
                                                                     ContentImage:[UIImage imageNamed:@"maptool-measure"]
                                                          highlightedContentImage:nil];
    
    QuadCurveMenuItem *zoomfullMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                  highlightedImage:storyMenuItemImagePressed
                                                                      ContentImage:[UIImage imageNamed:@"maptool-zoomfull"]
                                                           highlightedContentImage:nil];
    
//    QuadCurveMenuItem *drawMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:[UIImage imageNamed:@"maptool-iQuery"] highlightedContentImage:nil];
    
    /*QuadCurveMenuItem *spacesearchMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:[UIImage imageNamed:@"maptool-spacesearch"] highlightedContentImage:nil];*/
    
    QuadCurveMenuItem *clearMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"maptool-clear"]
                                                        highlightedContentImage:nil];
    
//    NSArray *menus = [NSArray arrayWithObjects:locateMenuItem, measureMenuItem, zoomfullMenuItem, drawMenuItem, spacesearchMenuItem, clearMenuItem, nil];
    NSArray *menus = [NSArray arrayWithObjects:locateMenuItem, measureMenuItem, zoomfullMenuItem, clearMenuItem, nil];
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus];

    menu.delegate = self;
    [self.view addSubview:menu];
}

-(void)createDateSelector{
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    QuadCurveMenuItem *locateMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"maptool-locate"]
                                                         highlightedContentImage:nil];
    
    QuadCurveMenuItem *measureMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                 highlightedImage:storyMenuItemImagePressed
                                                                     ContentImage:[UIImage imageNamed:@"maptool-year"]
                                                          highlightedContentImage:nil];
    
    QuadCurveMenuItem *zoomfullMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                  highlightedImage:storyMenuItemImagePressed
                                                                      ContentImage:[UIImage imageNamed:@"maptool-quarter"]
                                                           highlightedContentImage:nil];
    
    QuadCurveMenuItem *drawMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                              highlightedImage:storyMenuItemImagePressed
                                                                  ContentImage:[UIImage imageNamed:@"maptool-month"]
                                                       highlightedContentImage:nil];
    QuadCurveMenuItem *spacesearchMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                     highlightedImage:storyMenuItemImagePressed
                                                                         ContentImage:[UIImage imageNamed:@"maptool-week"]
                                                              highlightedContentImage:nil];
    
    NSArray *menus = [NSArray arrayWithObjects:locateMenuItem, measureMenuItem, zoomfullMenuItem, drawMenuItem,spacesearchMenuItem, nil];
    
    _dateSelector = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus nearRadius:70.0f endRadius:80.f farRadius:90.0f startPoint:CGPointMake(980, 440) timeOffset:0.026f angle:M_PI];
    
    _dateSelector.delegate = self;
    _dateSelector.tag = 1;
    _dateSelector.hidden = YES;
    [self.view insertSubview:_dateSelector belowSubview:self.switchContainer];
}

-(void)showSysMensu{
    NSArray *images = [[NSArray alloc]initWithObjects:
                       //[UIImage imageNamed:@"star"],
                       [UIImage imageNamed:@"layer"],
                       [UIImage imageNamed:@"chart"],
                       [UIImage imageNamed:@"folder"],
                       [UIImage imageNamed:@"profile"],
                       [UIImage imageNamed:@"help"],nil
                       ];
    
    NSArray *colors = [[NSArray alloc]initWithObjects:
                       //[UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                       [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
                       [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1],
                       [UIColor colorWithRed:119/255.f green:152/255.f blue:255/255.f alpha:1],
                       [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                       [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],nil
                       ];
    NSArray *labels = [[NSArray alloc] initWithObjects:@"图层",@"统计",@"资源",@"用户",@"关于",nil];
    
    RNFrostedSidebar *nav = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:self.optionIndices borderColors:colors labels:labels];
    //RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    nav.delegate = self;
    [nav show];
}

@end
