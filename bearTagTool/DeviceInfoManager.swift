//
//  DeviceInfoManager.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/23.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit

class DeviceInfoManager: NSObject {

    /// 获取设备信息
    ///
    /// - Returns: 设备信息字典
    func getDeviceInfo() -> Void {
        
        var deviceInfo = [String:String]()
        
        
        //        1.获取设备信息
        let deviceName = UIDevice.current.name //获取设备名称
        let sysName = UIDevice.current.systemName //获取系统名称
        let sysVersion = UIDevice.current.systemVersion //获取版本
        let model = UIDevice.current.model //获取设备模型
        let locallizedModel = UIDevice.current.localizedModel //本地化的模型
        let uuid = UIDevice.current.identifierForVendor?.uuidString //获取UUID
        let modelName = UIDevice.current.modelName //获取具体的型号
        
        
        deviceInfo["deviceName"] = deviceName
        deviceInfo["sysName"] = sysName
        deviceInfo["sysVersion"] = sysVersion
        deviceInfo["model"] = model
        deviceInfo["locallizedModel"] = locallizedModel
        deviceInfo["uuid"] = uuid
        deviceInfo["modelName"] = modelName
        
        
        //        本地化存储
        let userDefult = UserDefaults.standard
        userDefult.set(modelName, forKey: UserDefaultKeys.DeviceInfo.modelName.rawValue)
        userDefult.set(sysVersion, forKey: UserDefaultKeys.DeviceInfo.sysVersion.rawValue)
        userDefult.set(uuid, forKey: UserDefaultKeys.DeviceInfo.uuid.rawValue)
        
        
        //        return deviceInfo;
        
    }
    
    
    
    
}


//MARK: - UIDevice延展
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}


struct UserDefaultKeys {
    // 设备信息
    
    enum DeviceInfo: String {
        case modelName
        case sysVersion
        case uuid
        
    }
    
}
