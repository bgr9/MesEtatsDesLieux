//
//  FonctionnelButton.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 12/01/2023.
//

import UIKit

class FonctionnelButton: UIButton {

    var config: Configuration
    var fonctionnel: Fonctionnel
    
    required init?(coder: NSCoder) {
        self.config = UIButton.Configuration.bordered()
        self.fonctionnel = .nondefini
        super.init(coder: coder)
    }
    
    func updateFonctionnelButton () {
        if self.fonctionnel == .nondefini {
            self.config.title = "Modifier"
            self.config.subtitle = ""
        } else {
            self.config.title = self.fonctionnel.description
            self.config.subtitle = ""
        }
        config.automaticallyUpdateForSelection = false
        config.imagePadding = 5
        config.imagePlacement = .leading
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoFonctionnel(fonctionnel: self.fonctionnel)
        self.configuration = config
        self.menu = UIMenu(title: "L'élement est fonctionnel ?", children: elementsFonctionnel())
    }
    
    func elementsFonctionnel () -> [UIAction] {
        var elementsFonctionnel: [UIAction] = []
        for fonctionnel in Fonctionnel.allCases {
            if fonctionnel.description == "" { continue }
            if self.configuration?.title == fonctionnel.description {
                
                // On est sur l'item de menu correspondant à l'état
                elementsFonctionnel.append(UIAction(title: fonctionnel.description, image : pictoFonctionnel(fonctionnel: fonctionnel), attributes: [], state: .on, handler: {action in
                    self.configuration?.title = fonctionnel.description
                    self.fonctionnel = fonctionnel
                }))
            } else {
                // On change l'état, il faudra mettre a jour equipement.fonctionnel et recalculer le menu
                
               
                
                
                elementsFonctionnel.append(UIAction(title: fonctionnel.description,  image : pictoFonctionnel(fonctionnel: fonctionnel), state: .off, handler: {action in
                    self.configuration?.title = fonctionnel.description
                    self.configuration?.image = pictoFonctionnel(fonctionnel: fonctionnel)
                    self.configuration?.subtitle = nil
                    self.fonctionnel = fonctionnel
                    
                    
                }))
            }
        }
        
        return elementsFonctionnel
    }

    func displayFonctionnelButton(_ placement: NSDirectionalRectEdge) {
        // Config pour affichage simple
        if self.fonctionnel == .nondefini {
            self.config.title = "Non renseigné"
            self.config.subtitle = ""
        } else {
            self.config.title = self.fonctionnel.description
            self.config.subtitle = ""
        }
        self.config.automaticallyUpdateForSelection = false
        self.config.imagePadding = 1
        self.config.imagePlacement = placement
        self.config.buttonSize = .small
        self.config.cornerStyle = .small
        self.config.image = pictoFonctionnel(fonctionnel: self.fonctionnel)
        
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
