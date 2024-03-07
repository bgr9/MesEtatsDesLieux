//
//  ClefContentConfiguration.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import Foundation
import UIKit

struct ClefContentConfiguration: UIContentConfiguration, Hashable
{
    static func == (lhs: ClefContentConfiguration, rhs: ClefContentConfiguration) -> Bool {
        return (lhs.intituleClef == rhs.intituleClef
                && lhs.nombreClefs == rhs.nombreClefs
                && lhs.observationClef == rhs.observationClef
                && lhs.nombrePhotos == rhs.nombrePhotos
                && lhs.observationClefsSortie == rhs.observationClefsSortie
                && lhs.nombreClefsSortie == rhs.nombreClefsSortie)
    }
    
    var intituleClef: String
    
    var nombreClefs: Int?
    var observationClef: String?
    
    var nombreClefsSortie: Int?
    var observationClefsSortie: String?
    
    var nombrePhotos: Int
    
    
    func makeContentView() -> UIView & UIContentView {
        return ClefContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
   //     guard let state = state as? UICellConfigurationState else { return self }
     
        return self
    }
    

    
    
    

}
