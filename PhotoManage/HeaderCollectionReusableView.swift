//
//  HeaderCollectionReusableView.swift
//  PhotoManage
//
//  Created by Sujata Tayade on 22/06/20.
//  Copyright © 2020 Sujata Tayade. All rights reserved.
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
