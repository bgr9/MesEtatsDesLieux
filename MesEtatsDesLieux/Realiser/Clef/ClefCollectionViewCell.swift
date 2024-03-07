//
//  ClefCollectionViewCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit

class ClefCollectionViewCell: UICollectionViewListCell {
    
    var clef: Clef?
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        var nombrePhotos = 0
        if let clef = self.clef {
            if let images = clef.images {
                nombrePhotos = images.count
            }
            let newConfiguration = ClefContentConfiguration(intituleClef: clef.intituleClef, nombreClefs: clef.nombreClefs, observationClef: clef.observationClef, nombreClefsSortie: clef.nombreClefsSortie, observationClefsSortie: clef.observationClefSortie, nombrePhotos: nombrePhotos).updated(for: state)
            
           
            
            contentConfiguration = newConfiguration
            
        }
    }
    
}
