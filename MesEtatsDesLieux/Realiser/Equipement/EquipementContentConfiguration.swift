//
//  EquipementContentConfiguration.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import Foundation
import UIKit

struct EquipementContentConfiguration: UIContentConfiguration, Hashable
{
    static func == (lhs: EquipementContentConfiguration, rhs: EquipementContentConfiguration) -> Bool {
        return (lhs.equipement == rhs.equipement &&
        lhs.etat == rhs.etat &&
        lhs.proprete == rhs.proprete &&
        lhs.fonctionnel == rhs.fonctionnel &&
        lhs.observations == rhs.observations  &&
        lhs.nombrePhotos == rhs.nombrePhotos)
    }
    
    var equipement: String
    var nExemplaire: Int?
    var etat: Etat
    var proprete: Proprete
    var fonctionnel: Fonctionnel
    var observations: String?
    
    var observationsSortie: String?
    var nexemplaireSortie:  Int?
    var etatSortie:         Etat?
    var propreteSortie:     Proprete?
    var fonctionnelSortie:  Fonctionnel?
    
    
    var nombrePhotos: Int
    
    
    func makeContentView() -> UIView & UIContentView {
        return EquipementContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
   //     guard let state = state as? UICellConfigurationState else { return self }
     
        return self
    }
    

    
    
    

}
