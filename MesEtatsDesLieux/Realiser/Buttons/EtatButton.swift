//
//  EtatButton.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 12/01/2023.
//

import UIKit

class EtatButton: UIButton {
    
    var config: Configuration
    var etat: Etat
    
    required init?(coder: NSCoder) {
        self.config = UIButton.Configuration.bordered()
        self.etat = .nondefini
        super.init(coder: coder)
    }
    
    func updateEtatButton () {
        if self.etat == .nondefini {
            self.config.title = "Modifier"
            self.config.subtitle = ""
        } else {
            self.config.title = self.etat.description
            self.config.subtitle = ""
        }
        config.automaticallyUpdateForSelection = false
        config.imagePadding = 5
        config.imagePlacement = .leading
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoEtat(etat: self.etat)
        self.configuration = config
        // TODO: Bug sur l'affichage des états, voir si on peut marquer l'option retenue
    //    self.changesSelectionAsPrimaryAction = true
        self.menu = UIMenu(title: "Quel est l'état général ?", children: elementsEtat())
        
    }
    
    func elementsEtat () -> [UIAction] {
        var elementsEtat: [UIAction] = []
        for etat in Etat.allCases {
            if etat.description == "" { continue }
            if self.configuration?.title == etat.description {
                
                // On est sur l'item de menu correspondant à l'état
                elementsEtat.append(UIAction(title: etat.description, image : pictoEtat(etat: etat), attributes: [], state: .on, handler: {action in
                    self.configuration?.title = etat.description
                    self.etat = etat
                }))
            } else {
                // On change l'état, il faudra mettre a jour equipement.etat et recalculer le menu
                
               
                
                
                elementsEtat.append(UIAction(title: etat.description,  image : pictoEtat(etat: etat), state: .off, handler: {action in
                    self.configuration?.title = etat.description
                    self.configuration?.image = pictoEtat(etat: etat)
                    self.configuration?.subtitle = nil
                    self.etat = etat
                    
                    
                }))
            }
        }
        
        return elementsEtat
    }
    
    func displayEtatButton(_ placement: NSDirectionalRectEdge) {
        // Config pour affichage simple
        if self.etat == .nondefini {
            self.config.title = "Non renseigné"
            self.config.subtitle = ""
        } else {
            self.config.title = self.etat.description
            self.config.subtitle = ""
        }
        self.config.automaticallyUpdateForSelection = false
        self.config.imagePadding = 1
        self.config.imagePlacement = placement
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoEtat(etat: self.etat)
        
        self.config.titleTextAttributesTransformer =
              UIConfigurationTextAttributesTransformer { incoming in
                // 1
                var outgoing = incoming
                // 2
                  outgoing.font = UIFont.preferredFont(forTextStyle: .body).withSize(12)
                outgoing.foregroundColor = .secondaryLabel
                  
                // 3
                return outgoing
              }
        
        
        self.configuration = config
    }

}
    
    

