//
//  EntretienCollectionViewCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit

class EntretienCollectionViewCell: UICollectionViewListCell {
    
    var entretien: Entretien?
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        var nombrePhotos = 0
        if let entretien = self.entretien {
            if let images = entretien.images {
                nombrePhotos = images.count
            }
            let newConfiguration = EntretienContentConfiguration(intitule: entretien.intitule, realise: entretien.realise, dateEcheanceEntretien: entretien.dateEcheanceEntretien, observation: entretien.observationEntretien, nombrePhotos: nombrePhotos).updated(for: state)
            
           
            
            contentConfiguration = newConfiguration
            
        }
    }
    
}
