//
//  ImageCell.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/24.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var imageView: UIImageView
    var deleteBtn: UIButton
    
    typealias DeleteBlock = (UICollectionViewCell)->Void
    var deleteBlock: DeleteBlock?
    
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        deleteBtn = UIButton(frame: CGRect(x: frame.width - 35, y: 0, width: 35, height: 35))
         super.init(frame: frame)
         contentView.addSubview(imageView)
         contentView.addSubview(deleteBtn)
        deleteBtn.setImage(#imageLiteral(resourceName: "deleteIcon"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        deleteBtn.isHidden = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tapDelete() {
        
        if (deleteBlock != nil) {
            deleteBlock!(self)
        }
        
    }
    
}
