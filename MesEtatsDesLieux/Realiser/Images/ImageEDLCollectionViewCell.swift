//
//  ImageEDLCollectionViewCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 26/12/2022.
//

import UIKit

class ImageEDLCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var legendLabel: UILabel!
    @IBOutlet var imageEDL: UIImageView!
    { didSet {
        imageEDL.isUserInteractionEnabled = true
    } }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
