//
//  EntretienContentConfiguration.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import Foundation
import UIKit

struct EntretienContentConfiguration: UIContentConfiguration, Hashable
{
    static func == (lhs: EntretienContentConfiguration, rhs: EntretienContentConfiguration) -> Bool {
        return (lhs.intitule == rhs.intitule &&
        lhs.realise == rhs.realise &&
        lhs.dateEcheanceEntretien == rhs.dateEcheanceEntretien &&
                lhs.observation == rhs.observation  && lhs.nombrePhotos == rhs.nombrePhotos)
    }
    
    var intitule: String
    var realise: Bool
    var dateEcheanceEntretien: String
    var observation: String
    
    var nombrePhotos: Int
    
    
    func makeContentView() -> UIView & UIContentView {
        return EntretienContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
   //     guard let state = state as? UICellConfigurationState else { return self }
     
        return self
    }
    

    
    
    

}
