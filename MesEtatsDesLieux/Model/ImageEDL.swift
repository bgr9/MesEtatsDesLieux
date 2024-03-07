//
//  ImageEDL.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation
import UIKit

struct ImageEDL: Codable {
    var legendText: String?
    var nomImage: String = ""
    var isImageEDLSortie: Bool?
    
    func sauveImage (image: UIImage) -> String {
        return ""
    }
    func chargeImage (nomImage: String) -> UIImage {
        return UIImage(systemName: "photo")!
    }
}

struct ImageEDLImage {
    var legende: String
    var image: UIImage
    var isImageEDLSortie: Bool?
    
}
