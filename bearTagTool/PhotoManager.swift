//
//  PhotoManager.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/24.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import Photos

class PhotoManager: NSObject {

    var assetCollection:PHAssetCollection?
    
    let imageCollectionName = "小熊图库"
    
    let file_manager = FileManager.default
    
    
    static let defaultManager = PhotoManager()
    
    private override init() {
        super.init()
    }
    
    
    /// 如果文件夹不存在，会自动创建
    ///
    /// - Returns: 文件存储路径
    func createImageSandBoxPath()->String {
        
//        1. 获取沙盒路径
        let documentPath:NSString! = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let imageStoragePath = documentPath.appendingPathComponent(imageCollectionName)
        
        print(imageStoragePath)
        
//        2. 如果路径不存在 则创建
        
        var isDir : ObjCBool = false
        if file_manager.fileExists(atPath: imageStoragePath, isDirectory:&isDir) {
            if isDir.boolValue {
                return imageStoragePath
                
            } else {
                // 存在但不是个文件夹
                try!  file_manager.createDirectory(atPath: imageStoragePath, withIntermediateDirectories: true, attributes: nil)
            }
        } else {
            // 文件不存在
          try!  file_manager.createDirectory(atPath: imageStoragePath, withIntermediateDirectories: true, attributes: nil)
            
        }
        
        return imageStoragePath
        
    }
    
    
    func createFile(at filePath:String, contents:Data) {
        if file_manager.createFile(atPath: filePath, contents: contents, attributes: nil) {
            print("文件创建成功:\(filePath)");
        } else {
            print("文件创建失败:\(filePath)");
        }
    }
    
    /// 获取文件列表
    ///
    /// - Parameter path: 文件夹名
    /// - Returns: 文件夹下所有的文件 如果只需要img类型的需要进一步判断
    func getImgList(path:String) -> Array<String>? {
        
        return file_manager.subpaths(atPath:path)
        
    }
    
    
    /// 根据文件名创建路径
    ///
    /// - Parameter fileName: 文件名
    /// - Returns: 返回文件路名
    func createFilePath(fileName:String) -> String {
        let path = createImageSandBoxPath() as NSString
        return path.appendingPathComponent(fileName) as String
    }
    
    
    /// 读取文件的内容
    ///
    /// - Parameter filePath: 文件路径
    /// - Returns: 文件的二进制数据
    func readFile(filePath:String) -> Data? {
        var data: Data?
        if file_manager.fileExists(atPath: filePath) {
            data = file_manager.contents(atPath: filePath)
        }
        return data
    }
    
    
    /// 获取文件信息
    ///
    /// - Parameter filePath: 文件路径
    /// - Returns: 返回字典，key是FileAttributeKey这些
    func getFileInfo(filePath:String ) -> [FileAttributeKey : Any]? {
        
        let attributes:[FileAttributeKey : Any]?
        
        if file_manager.fileExists(atPath: filePath) {
        attributes = try?  file_manager.attributesOfItem(atPath: filePath)
            
        print("属性:\(attributes!)")
            
//        attributes?[.creationDate]
            
            
        }else {
            attributes = nil
            print("文件不存在")
        }
        
        return attributes
        
    }
    
    
    
    /// 删除所有文件
    func deleateAllFiles() {
        
            let documentPath:NSString! = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            let imageStoragePath = documentPath.appendingPathComponent(imageCollectionName)
        
            try! file_manager.removeItem(atPath: imageStoragePath)
            
            try! file_manager.createDirectory(atPath: imageStoragePath, withIntermediateDirectories: true, attributes: nil)
    }

    
    
    /// 删除单个文件
    ///
    /// - Parameter path: 文件路径
    func deleateFile(path:String) {
      try! file_manager.removeItem(atPath: path)
    }
    
    
    
    /// 创建相册
    func createAlbum(authorError: (Bool)->Void) {
        
        
        if isAuthorized() == false {

            authorError(false)
            
            return
        }
        
        
        //        1. 创建属性选择器
        let fetchOptions = PHFetchOptions()
        //        2. 指定相簿名称
        fetchOptions.predicate = NSPredicate(format: "title=%@", "小熊相册")
        //        3. 获取相簿对象
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        //        4. 如果查询出第一个对象存在，那么就说明相簿已经存在了，直接赋值
        if let _ = collection.firstObject {
            assetCollection = collection.firstObject
        } else {
            
            //            新建相簿
            var assetCollectionPlaceholder: PHObjectPlaceholder!
            
            PHPhotoLibrary.shared().performChanges({
                
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "小熊相册")
                assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                
                
            }, completionHandler: { (success, error) in
                
                if success == false {
                    print("Error creating album: \(String(describing: error))")
                } else {
                    
                    //  创建成功，获取PHAssetColleciton
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                    self.assetCollection = collectionFetchResult.firstObject
                    
                }
                
                
            })
            
        }
        
        
    }
    
    
    func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized ||
            PHPhotoLibrary.authorizationStatus() == .notDetermined
    }
    
    func savePhoto(image: UIImage, authorError: (Bool)->Void) {
        
        
        if isAuthorized() == false {
            authorError(false)
            return
        }
        
        //                使用线程同步
        DispatchQueue.global().async {
            
            //                    保存到自定义的相簿中
            PHPhotoLibrary.shared().performChanges({
                
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                //                        找到placeholder
                let assetPlaceholder = assetRequest.placeholderForCreatedAsset
                //                        创建photAsset
                let photoAsset = PHAsset.fetchAssets(in: self.assetCollection!, options: nil)
                
                //                        实例化 保存事件
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection!, assets: photoAsset) {
                    
                    albumChangeRequest.addAssets([assetPlaceholder!] as NSFastEnumeration)
                    
                }
                
                
                
            }, completionHandler: { (success, error) in
                
                if !success {
                    print("保存失败")
                }else{
                    print("保存成功")
                }
                
            })
            
        }
        
    }

    
}
