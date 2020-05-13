//
//  MyCollectionViewCell.swift
//  carouselPOC
//
//  Created by Omar AlQasmi on 5/13/20.
//  Copyright © 2020 testting.com. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowOffset = .init(width: 8, height: 8)
        layer.shadowOpacity = 0.8
        clipsToBounds = false
        
    }
}
