//
//  MarkView.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/24.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import SnapKit

class MarkView: UIView {
    
    var bigImageView: UIImageView!
    var leftBtn: UIButton!
    var rightBtn: UIButton!
    
    
    override init(frame: CGRect) {
        
        bigImageView = UIImageView()
        leftBtn = UIButton(type: .custom)
        rightBtn = UIButton(type: .custom)
        
        leftBtn.setTitle("向左", for: .normal)
        rightBtn.setTitle("向右", for: .normal)
        
        super.init(frame: frame)
        addSubview(bigImageView)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        bigImageView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        leftBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(bigImageView)
            make.left.equalTo(10)
            make.size.equalTo(CGSize(width: 50, height: 30))
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.size.equalTo(leftBtn)
            make.centerY.equalTo(leftBtn)
            make.right.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
