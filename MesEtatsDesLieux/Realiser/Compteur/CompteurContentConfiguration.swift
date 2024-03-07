//
//  CompteurContentConfiguration.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import Foundation
import UIKit

struct CompteurContentConfiguration: UIContentConfiguration, Hashable
{
    static func == (lhs: CompteurContentConfiguration, rhs: CompteurContentConfiguration) -> Bool {
        return (lhs.nomCompteur == rhs.nomCompteur &&
        lhs.motifNonReleve == rhs.motifNonReleve &&
        lhs.localisationCompteur == rhs.localisationCompteur &&
        lhs.enServicePresent == rhs.enServicePresent &&
        lhs.indexCompteur == rhs.indexCompteur &&
        lhs.uniteCompteur == rhs.uniteCompteur &&
        lhs.nombrePhotos == rhs.nombrePhotos &&
        
        lhs.enServicePresentSortie == rhs.enServicePresentSortie &&
        lhs.indexCompteurSortie == rhs.indexCompteurSortie &&
        lhs.uniteCompteurSortie == rhs.uniteCompteurSortie &&
        lhs.motifNonReleveSortie == rhs.motifNonReleveSortie
        )
    }
    
    var nomCompteur: String
    var localisationCompteur: String?
    
    var enServicePresent: Bool?
    var indexCompteur: Int?
    var uniteCompteur: String?
    var motifNonReleve: String?
    
    var nombrePhotos: Int
    
    var enServicePresentSortie: Bool?
    var indexCompteurSortie: Int?
    var uniteCompteurSortie: String?
    var motifNonReleveSortie: String?
    
    
    func makeContentView() -> UIView & UIContentView {
        return CompteurContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
   //     guard let state = state as? UICellConfigurationState else { return self }
     
        return self
    }
    

    
    
    

}
