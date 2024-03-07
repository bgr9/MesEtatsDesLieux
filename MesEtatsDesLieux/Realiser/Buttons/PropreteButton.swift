//
//  PropreteButton.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 12/01/2023.
//

import UIKit

class PropreteButton: UIButton {

    var config: Configuration
    var proprete: Proprete
    
    required init?(coder: NSCoder) {
        self.config = UIButton.Configuration.bordered()
        self.proprete = .nondefini
        super.init(coder: coder)
    }
    
    func updatePropreteButton () {
        if self.proprete == .nondefini {
            self.config.title = "Modifier"
            self.config.subtitle = ""
        } else {
            self.config.title = self.proprete.description
            self.config.subtitle = ""
        }
        config.automaticallyUpdateForSelection = false
        config.imagePadding = 5
        config.imagePlacement = .leading
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoProprete(proprete: self.proprete)
        self.configuration = config
        self.menu = UIMenu(title: "L'élement est proprete ?", children: elementsProprete())
    }
    
    func elementsProprete () -> [UIAction] {
        var elementsProprete: [UIAction] = []
        for proprete in Proprete.allCases {
            if proprete.description == "" { continue }
            if self.configuration?.title == proprete.description {
                
                // On est sur l'item de menu correspondant à l'état
                elementsProprete.append(UIAction(title: proprete.description, image : pictoProprete(proprete: proprete), attributes: [], state: .on, handler: {action in
                    self.configuration?.title = proprete.description
                    self.proprete = proprete
                }))
            } else {
                // On change l'état, il faudra mettre a jour equipement.proprete et recalculer le menu
                
               
                
                
                elementsProprete.append(UIAction(title: proprete.description,  image : pictoProprete(proprete: proprete), state: .off, handler: {action in
                    self.configuration?.title = proprete.description
                    self.configuration?.image = pictoProprete(proprete: proprete)
                    self.configuration?.subtitle = nil
                    self.proprete = proprete
                    
                    
                }))
            }
        }
        
        return elementsProprete
    }
    func displayPropreteButton(_ placement: NSDirectionalRectEdge) {
        // Config pour affichage simple
        if self.proprete == .nondefini {
            self.config.title = "Non renseigné"
            self.config.subtitle = ""
        } else {
            self.config.title = self.proprete.description
            self.config.subtitle = ""
        }
        self.config.automaticallyUpdateForSelection = false
        self.config.imagePadding = 1
        self.config.imagePlacement = placement
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoProprete(proprete: self.proprete)
        
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
