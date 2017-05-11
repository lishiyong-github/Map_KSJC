//
//  MapConfig.h
//  KSJC
//  昆山地图数据配置,时间仓促，后期规范化
//  Created by dist on 16/11/9.
//  Copyright © 2016年 dist. All rights reserved.
//

#ifndef MapConfig_h
#define MapConfig_h


#endif /* MapConfig_h */


typedef enum : NSUInteger {
    IdentifyStateTypeHasResult,
    IdentifyStateTypeNoResult,
    IdentifyStateTypeIdentifying,
    IdentifyStateTypeFail
} IdentifyStateType;


/**
 *  底图
 */

//行政区划
#define KSXZQHMAP @"http://61.155.216.8:6080/arcgis/rest/services/KSMAP/MapServer"
#define KSXZQHNAME @"行政区划"

//影像
#define KSIMGMAP @"http://61.155.216.8:6080/arcgis/rest/services/KSDOM2015/MapServer"
#define KSIMGNAME @"影像底图"

//默认显示位置
#define DEFAULT_X_MIN -22002.9939
#define DEFAULT_Y_MIN 38457.9445
#define DEFAULT_X_MAX 81528.6714
#define DEFAULT_Y_MAX 93187.1165

/**
 *  图层树
 */

//控规
#define KSKG @"http://61.155.216.8:6080/arcgis/rest/services/KSGHCG/MapServer"
#define KSKGID @[@89,@113]

//地名
#define KSDM @"http://61.155.216.8:6080/arcgis/rest/services/KSYDDMDZ/MapServer"
#define KSDMID @[@0]

//蓝线
#define KSLX @"http://61.155.216.8:6080/arcgis/rest/services/KSGHCG/MapServer"
#define KSLXID @[@106]

//红线
#define KSHX @"http://61.155.216.8:6080/arcgis/rest/services/KSGHCG/MapServer"
#define KSHXID @[@105]

//规划路网
#define KSGHLW @"http://61.155.216.8:6080/arcgis/rest/services/KSGHCG/MapServer"
#define KSGHLWID @[@89,@90,@93,@94,@96,@97,@98]

/**
 *  业务
 */

//放验线
#define KSFYX @"http://61.155.216.8:6080/arcgis/rest/services/KSSPHX/MapServer"
#define KSFYXID @[@33,@34,@35]
#define KSFYXFIELD @[@"XMMC",@"XMBH",@"SLBH"]

/**
 *  坐标转换
 */

#define KSGPSSERVERURL @"http://61.155.216.5:8189/ksserver1/rest/mobileservice/convertCoordinate"



/**
 *  在线巡查 专题
 */

//控制性详细规划
#define KSKG0 @"http://61.155.216.8:6080/arcgis/rest/services/KSKFQZT/MapServer"
#define KSKG0ID @[@44]
#define KSKG1 @"http://61.155.216.8:6080/arcgis/rest/services/KSGHCG/MapServer"
#define KSKG1ID @[@113]

//选址红线
#define KSXZHX @"http://61.155.216.8:6080/arcgis/rest/services/SPHX_YD/MapServer"
#define KSXZHXID @[@0]


//用地红线
#define KSYDHX @"http://61.155.216.8:6080/arcgis/rest/services/SPHX_YD/MapServer"
#define KSYDHXID @[@1]

/**
 *  巡查 定位查询
 */
//建筑红线 用于保存位置
#define KSJZHX @"http://61.155.216.8:6080/arcgis/rest/services/SPHX_YD/MapServer/"
#define KSJZHXID @[@2]


/**
 *  i 查询 过滤字段
 */

#define IDENTIFY_SYS_FIELDS @[@"OBJECTID",@"SHAPE",@"SHAPE_Length",@"SHAPE_Area",@"SHAPE.AREA",@"SHAPE.LEN"]
#define CUSTOM_SYS_FIELDS @[@"layerId",@"layerName",@"serviceLayerName"]














