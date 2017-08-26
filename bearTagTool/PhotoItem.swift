//
//  PhotoItem.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/25.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import Foundation
import RealmSwift

//框的位置
class FramePostion:Object {
    dynamic var x = 0.0
    dynamic var y = 0.0
    dynamic var width = 0.0
    dynamic var height = 0.0
}


class PhotoItem: Object {
    dynamic var fileName = ""//文件名
    dynamic var fileSize = 0//文件大小
    dynamic var fileWidth = 0.00//文件宽
    dynamic var fileHeight = 0.00//文件高
    dynamic var createDate = 0//创建日期
    dynamic var filePath = ""//图片路径
    dynamic var deviceType = ""//设备类型
    dynamic var frame:FramePostion?//图框位置
}

