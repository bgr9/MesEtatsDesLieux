//
//  EmetteurController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation
import UIKit

class EmetteurController {
    static let shared = EmetteurController(emetteurs: [])
    
    var emetteurs = [Emetteur]()

    init(emetteurs: [Emetteur] = [Emetteur]()) {
        self.emetteurs = EmetteurController.chargeEmetteurs() ?? []
    }
 
    static func nouvEmetteur () -> Emetteur {
        return ModeleEDLController.ModeleEmetteurDefaut
    }
    
    static func chargeEmetteurs() -> [Emetteur]? {
        let archiveURL = documentsDirectory.appendingPathComponent("Emetteurs-").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let emetteurs = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Emetteur].self, from: emetteurs)
    }
    
    static func sauveEmetteurs (_ emetteurs: [Emetteur]? = EmetteurController.shared.emetteurs) {
        
        
            let archiveURL = documentsDirectory.appendingPathComponent("Emetteurs-").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let emetteurs = try? propertyListEncoder.encode(emetteurs)
            try? emetteurs?.write(to: archiveURL, options: .noFileProtection)
    
    }
    
    static func emetteurUUID (nomEmetteur: String) -> UUID {
        for emetteur in self.shared.emetteurs {
            if emetteur.nomEmetteur == nomEmetteur {
                return emetteur.idEmetteur
            }
        }
        fatalError("Emetteur non trouvée")
    }
    
    static func emetteurByNom (nomEmetteur: String) -> Emetteur? {
        for emetteur in self.shared.emetteurs {
            if emetteur.nomEmetteur == nomEmetteur {
                return emetteur
            }
        }
       return nil
        
    }
    
    static func emetteurByIndex (indexEmetteur: Int) -> Emetteur {
        if indexEmetteur < EmetteurController.shared.emetteurs.count - 1 {
            return EmetteurController.shared.emetteurs[indexEmetteur]
        }
        fatalError("Emetteur non trouvée par index")
    }
    
    static func emetteurByUUID (uuidEmetteur: UUID) -> Emetteur? {
        for emetteur in self.shared.emetteurs {
            if emetteur.idEmetteur == uuidEmetteur {
                return emetteur
            }
        }
        return nil
        
    }
    
    static func majEmetteur ( emetteur: Emetteur ) -> Int?  {
        // On met à jour la Emetteur si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if EmetteurController.shared.emetteurs.count > 0 {
            for index in 0...EmetteurController.shared.emetteurs.count - 1 {
                if EmetteurController.shared.emetteurs[index] == emetteur {
                    EmetteurController.shared.emetteurs[index] = emetteur
                    nouv = false
                    EmetteurController.sauveEmetteurs(EmetteurController.shared.emetteurs)
                    return index
                }
            }
        }
        if nouv {
            EmetteurController.shared.emetteurs.append(emetteur)
            EmetteurController.sauveEmetteurs(EmetteurController.shared.emetteurs)
            return EmetteurController.shared.emetteurs.count - 1
        }
       
    }
    
    static func supprEmetteur (emetteur: Emetteur) {
        
        if EDLsController.existeEDLPourEmetteur(idEmetteur: emetteur.idEmetteur) {
            // On ne supprime pas l'emetteur car on a un EDL qui pointe dessus
            return
        } else {
            for index in 0...EmetteurController.shared.emetteurs.count - 1 {
                if EmetteurController.shared.emetteurs[index].idEmetteur == emetteur.idEmetteur {
                    EmetteurController.shared.emetteurs.remove(at: index)
                    EmetteurController.sauveEmetteurs()
                    return
                }
            }
        }
        
        
    }
    
    static func supprEmetteur (index: Int) {
        
        if index <= EmetteurController.shared.emetteurs.count - 1 {
            
            // Suppression de l'image
            supprImage(idImage: nomFichierLogo(idEmetteur:  EmetteurController.shared.emetteurs[index].idEmetteur ))
            EmetteurController.shared.emetteurs.remove(at: index)
            EmetteurController.sauveEmetteurs()
            return
        }
        fatalError("Emetteur non trouvée par index dans la suppression")
                    
        
    }
    
    // Renomme des emetteurs dynamiques pour les pieces (type equipement)
    static func renommeEmetteur (idActuelleEmetteur: UUID,  idNouvelleemetteur: UUID, nouvNom: String) {
        var emetteursActuelles = EmetteurController.shared.emetteurs
        for index in 0...emetteursActuelles.count - 1 {
            if emetteursActuelles[index].idEmetteur == idActuelleEmetteur {
                emetteursActuelles[index].nomEmetteur = nouvNom
                emetteursActuelles[index].idEmetteur = idNouvelleemetteur
                EmetteurController.shared.emetteurs[index] = emetteursActuelles[index]
                break
            }
        }
        EmetteurController.sauveEmetteurs(EmetteurController.shared.emetteurs)
    }
    
    
    static func reChargeEmetteur () {
        EmetteurController.shared.emetteurs = [ ]
        if let emetteurs = EmetteurController.chargeEmetteurs() {
            EmetteurController.shared.emetteurs = emetteurs
        }
        
    }
    
    static func chargeLogoEmetteur ( idEmetteur: UUID ) -> UIImage {
        for emetteur in EmetteurController.shared.emetteurs {
            if emetteur.idEmetteur == idEmetteur {
                return chargeImage(idImage: nomFichierLogo(idEmetteur: idEmetteur))
            }
        }
        return logoDefaut!
    }
    
    static func sauveLogoEmetteur ( idEmetteur: UUID , logoEmetteur : UIImage) {
        sauveImage(inImage: logoEmetteur, nomImage: nomFichierLogo(idEmetteur: idEmetteur))
        
    }
    
    static let logoDefaut = UIImage(named: "filigrane")?.resizeImageTo(size: CGSize(width: 80, height: 80))
    
    static func nomFichierLogo ( idEmetteur: UUID ) -> String {
        return "Logo-" + idEmetteur.uuidString
    }
    
    
}
