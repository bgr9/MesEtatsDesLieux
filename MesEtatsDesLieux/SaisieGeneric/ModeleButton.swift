//
//  EtatButton.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 12/01/2023.
//

import UIKit

class ModeleButton: UIButton {
    
    var config: Configuration
    var typeModele: TypeModele
    var nomModeleType: String
    
    required init?(coder: NSCoder) {
        self.config = UIButton.Configuration.bordered()
        self.typeModele = .vide
        self.nomModeleType = ""
        super.init(coder: coder)
    }
    
    func updateModeleButton () {
        
        self.config.title = self.typeModele.description
        self.config.subtitle = ""
        config.automaticallyUpdateForSelection = false
        config.imagePadding = 5
        config.imagePlacement = .leading
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoModele(typeModel: typeModele)
        self.configuration = config
        self.changesSelectionAsPrimaryAction = true
        self.menu = UIMenu(title: "Ajouter un bien en partant d'un modèle", children: elementsTypeModele())
        
    }
    
    func elementsTypeModele () -> [UIMenuElement] {
        var elementsTypeModele: [UIMenuElement] = []
        let nomModeleType: [String] = ModeleEDLController.shared.modelesEDL.map { $0.nomModele }
        for typeModele in TypeModele.allCases {
            if typeModele.description == "" { continue }
            if let title = self.configuration?.title,
                title == typeModele.description || nomModeleType.contains(title) {
                
                // On est sur l'item de menu correspondant à l'état
                elementsTypeModele.append(UIAction(title: typeModele.description, image : pictoModele(typeModel: typeModele), attributes: [], state: .on, handler: {action in
                    self.configuration?.title = typeModele.description
                    self.typeModele = typeModele
                }))
            } else {
                
                // On change l'état, il faudra mettre a jour equipement.etat et recalculer le menu
                
                switch typeModele {
                case .typeBien:
                    for m in ModeleEDLController.modelesTypes {
                        elementsTypeModele.append(UIAction(title: m.nomModele, image : pictoModele(typeModel: typeModele), handler: {action in
                            self.typeModele = typeModele
                            self.nomModeleType = m.nomModele}))
                    }
                    
                    
                case .reprise, .sortieApresEntree:
                    // On ne fait rien, la reprise passe par une autre action
                    _ = 1
                default:
                    
                    
                    elementsTypeModele.append(UIAction(title: typeModele.description,  image : pictoModele(typeModel: typeModele), state: .off, handler: {action in
                        self.configuration?.title = typeModele.description
                        self.configuration?.image = pictoModele(typeModel: typeModele)
                        self.configuration?.subtitle = nil
                        self.typeModele = typeModele
                        self.nomModeleType = ""
                        
                        
                    }))
                }
            }
        }
        
        return elementsTypeModele
    }
    
 

}
    
    

