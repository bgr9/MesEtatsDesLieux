//
//  EquipementCollectionViewCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit

class EquipementCollectionViewCell: UICollectionViewListCell {
    
    var equipement: Equipement?
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        var nombrePhotos = 0
        if let equipement = self.equipement {
            if let images = equipement.images {
                nombrePhotos = images.count
            }
            let newConfiguration = EquipementContentConfiguration(equipement: equipement.equipement, nExemplaire: equipement.nExemplaire, etat: equipement.etat, proprete: equipement.proprete, fonctionnel: equipement.fonctionnel , observations: equipement.observations, observationsSortie: equipement.observationsSortie,nexemplaireSortie: equipement.nExemplaireSortie, etatSortie: equipement.etatSortie, propreteSortie: equipement.propreteSortie, fonctionnelSortie: equipement.fonctionnelSortie, nombrePhotos: nombrePhotos).updated(for: state)
            
           
            
            contentConfiguration = newConfiguration
            
        }
    }
    
}

