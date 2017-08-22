//
//  ViewController.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/22.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        添加控制视图
        self.configContrlView()

        
        
 
    }

    
    
    /// 添加并配置控制视图
    func configContrlView() -> Void {
        
        let applicationframe = UIScreen.main.applicationFrame.size
        let controlView = UIView(frame: CGRect(x: 0, y: 64, width: applicationframe.width, height: applicationframe.height - 44))
        controlView.backgroundColor = UIColor.cyan
        self.view.addSubview(controlView)
        
        
//      图片存放位置
        
        let albumEntryBtn = UIButton(type: .custom)
        controlView.addSubview(albumEntryBtn)
        
        albumEntryBtn.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(10)
        }
        
        albumEntryBtn.setImage(#imageLiteral(resourceName: "imgEntry"), for: .normal)
        
        
//      手动开关
        let tagSwitch = UISwitch()
        tagSwitch.isOn = true
        controlView.addSubview(tagSwitch)
    
        tagSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(albumEntryBtn)
        }
        
        
//      拍照按钮
        let takePhotoBtn = UIButton(type: .custom)
        controlView.addSubview(takePhotoBtn)
        takePhotoBtn.setImage(#imageLiteral(resourceName: "carama"), for: .normal)
        
        takePhotoBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-20)
            make.centerX.equalTo(view)
            make.width.height.equalTo(50)
        }
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

