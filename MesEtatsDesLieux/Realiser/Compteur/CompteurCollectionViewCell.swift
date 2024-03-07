//
//  CompteurCollectionViewCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit

class CompteurCollectionViewCell: UICollectionViewListCell {
    
    var compteur: Compteur?
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        var nombrePhotos = 0
        if let compteur = self.compteur {
            if let images = compteur.images {
                nombrePhotos = images.count
            }
            let newConfiguration = CompteurContentConfiguration(nomCompteur: compteur.nomCompteur, localisationCompteur: compteur.localisationCompteur, enServicePresent: compteur.enServicePresent, indexCompteur: compteur.indexCompteur, uniteCompteur: compteur.uniteCompteur, motifNonReleve: compteur.motifNonReleve, nombrePhotos: nombrePhotos, enServicePresentSortie: compteur.enServicePresentSortie, indexCompteurSortie: compteur.indexCompteurSortie, uniteCompteurSortie: compteur.uniteCompteurSortie, motifNonReleveSortie: compteur.motifNonReleveSortie).updated(for: state)
            
            
            contentConfiguration = newConfiguration
            
        }
    }
    
}
