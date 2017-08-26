//
//  RealmManager.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/25.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager: NSObject {
    
    
    /// realm 数据库的名称
    
    var username = "default"
    var realm: Realm!
    
    static let realmManager = RealmManager()
    
    private override init() {
        super.init()
 }
    
    
    
    func setDefaultRealmForUser(username: String) {
            var config = Realm.Configuration()

            // 使用默认的目录，但是使用用户名来替换默认的文件名
            config.fileURL = config.fileURL!.deletingLastPathComponent()
                .appendingPathComponent("\(username).realm")

            // 将这个配置应用到默认的 Realm 数据库当中
            Realm.Configuration.defaultConfiguration = config
        
        
          realm =  try! Realm(configuration: config)
        
         print("数据库地址：\(realm.configuration.fileURL!)")
        
    }

    
    
    //--- MARK: 操作 Realm
    /// 做写入操作
    func doWriteHandler(_ clouse: @escaping ()->()) { // 这里用到了 Trailing 闭包
        try! realm.write {
            clouse()
        }
    }
    
    ///后台做写入操作
    
    static func BGDoWriteHandler(_ clouse: @escaping ()->()) {
        try! Realm().write {
            clouse()
        }
    }
    
    /// 添加一条数据
     func addCanUpdate<T: Object>(_ object: T) {
        try! realm.write {
            realm.add(object, update: true)
        }
    }
     func add<T: Object>(_ object: T) {
        try! realm.write {
            realm.add(object)
        }
    }
    /// 后台单独进程写入一组数据
     func addListDataAsync<T: Object>(_ objects: [T]) {
        
        let queue = DispatchQueue.global(qos: .default)
        // Import many items in a background thread
        queue.async {
            // 为什么添加下面的关键字，参见 Realm 文件删除的的注释
            autoreleasepool {
                // 在这个线程中获取 Realm 和表实例
                let realm = try! Realm()
                // 批量写入操作
                realm.beginWrite()
                // add 方法支持 update ，item 的对象必须有主键
                for item in objects {
                    realm.add(item, update: true)
                }
                // 提交写入事务以确保数据在其他线程可用
                try! realm.commitWrite()
            }
        }
    }
    
     func addListData<T: Object>(_ objects: [T]) {
        autoreleasepool {
            // 在这个线程中获取 Realm 和表实例
            let realm = try! Realm()
            // 批量写入操作
            realm.beginWrite()
            // add 方法支持 update ，item 的对象必须有主键
            for item in objects {
                realm.add(item, update: true)
            }
            // 提交写入事务以确保数据在其他线程可用
            try! realm.commitWrite()
        }
    }
    
    /// 删除某个数据
     func delete<T: Object>(_ object: T) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    /// 批量删除数据
     func delete<T: Object>(_ objects: [T]) {
        try! realm.write {
            realm.delete(objects)
        }
    }
    /// 批量删除数据
     func delete<T: Object>(_ objects: List<T>) {
        try! realm.write {
            realm.delete(objects)
        }
    }
    /// 批量删除数据
     func delete<T: Object>(_ objects: Results<T>) {
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    /// 批量删除数据
     func delete<T: Object>(_ objects: LinkingObjects<T>) {
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    
    /// 删除所有数据。注意，Realm 文件的大小不会被改变，因为它会保留空间以供日后快速存储数据
     func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    /// 根据条件查询数据
     func selectByNSPredicate<T: Object>(_: T.Type , predicate: NSPredicate) -> Results<T>{
        return realm.objects(T.self).filter(predicate)
    }
    
    /// 后台根据条件查询数据
     func BGselectByNSPredicate<T: Object>(_: T.Type , predicate: NSPredicate) -> Results<T>{
        return try! Realm().objects(T.self).filter(predicate)
    }
    
    
    /// 查询所有数据
     func selectByAll<T: Object>(_: T.Type) -> Results<T>{
        return realm.objects(T.self)
    }
    //--- MARK: 删除 Realm
    /*
     参考官方文档，所有 fileURL 指向想要删除的 Realm 文件的 Realm 实例，都必须要在删除操作执行前被释放掉。
     故在操作 Realm实例的时候需要加上 autoleasepool 。如下:
     autoreleasepool {
     //所有 Realm 的使用操作
     }
     */
    /// Realm 文件删除操作
    static func deleteRealmFile() {
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("log_a"),
            realmURL.appendingPathExtension("log_b"),
            realmURL.appendingPathExtension("note")
        ]
        let manager = FileManager.default
        for URL in realmURLs {
            do {
                try manager.removeItem(at: URL)
            } catch {
                // 处理错误
            }
        }
        
    }
}

