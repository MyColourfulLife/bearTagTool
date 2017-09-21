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
    @objc dynamic var x = 0.0
    @objc dynamic var y = 0.0
    @objc dynamic var width = 0.0
    @objc dynamic var height = 0.0
}


class PhotoItem: Object {
    @objc dynamic var fileName = ""//文件名
    @objc dynamic var deviceType = ""//设备类型
    @objc dynamic var deviceName = ""//设备名称
    @objc dynamic var fileSize = 0//文件大小
    @objc dynamic var fileWidth = 0.00//文件宽
    @objc dynamic var fileHeight = 0.00//文件高
    @objc dynamic var createDate = 0//创建日期
    @objc dynamic var filePath = ""//图片路径
    @objc dynamic var frame:FramePostion?//图框位置
    @objc dynamic var smallImgName = ""//缩略图图片名
    @objc dynamic var smallImgPath = ""//缩略图图片路径
}

