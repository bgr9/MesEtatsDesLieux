//
//  FournitureCollectionViewCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit

class FournitureCollectionViewCell: UICollectionViewListCell {
    
    var fourniture: Fourniture?
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        var nombrePhotos = 0
        if let fourniture = self.fourniture {
            if let images = fourniture.images {
                nombrePhotos = images.count
            }
            let newConfiguration = FournitureContentConfiguration(equipement: fourniture.equipement, nExemplaire: fourniture.nExemplaire, etat: fourniture.etat, proprete: fourniture.proprete, fonctionnel: fourniture.fonctionnel , observations: fourniture.observations, observationsSortie: fourniture.observationsSortie,nexemplaireSortie: fourniture.nExemplaireSortie, etatSortie: fourniture.etatSortie, propreteSortie: fourniture.propreteSortie, fonctionnelSortie: fourniture.fonctionnelSortie, nombrePhotos: nombrePhotos).updated(for: state)
            
           
            
            contentConfiguration = newConfiguration
            
        }
    }
    
}

