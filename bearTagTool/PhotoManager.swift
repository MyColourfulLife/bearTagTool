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
    
    
    static let defaultManager = PhotoManager()
    
    private override init() {
        super.init()
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
