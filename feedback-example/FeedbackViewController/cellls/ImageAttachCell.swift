//
//  ImageAttachCell.swift
//  chatGPT2
//
//  Created by nguyen van hoang on 09/03/2023.
//

import UIKit

class ImageAttachCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
}
