//
//  HeaderCollectionReusableView.swift
//  AlbumDemo
//
//  Created by Weshare on 2018/3/29.
//  Copyright © 2018年 Weshare. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
