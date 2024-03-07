//
//  CompteurController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

class CompteurController {
    static let shared = CompteurController(compteurs: [])
    var compteurs = [Compteur]()
    
    init(compteurs: [Compteur] = [Compteur]()) {
            if let compteurs = CompteurController.chargeCompteurs() {
                self.compteurs = compteurs
            } else {
                self.compteurs = [ ]
            }
    }
    
   
    
    static func chargeCompteurs() -> [Compteur]? {
        let archiveURL = documentsDirectory.appendingPathComponent("Compteurs-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let compteurs = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Compteur].self, from: compteurs)
    }
    
    static func sauveCompteurs (_ Compteurs: [Compteur]? = CompteurController.shared.compteurs) {
        
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("Compteurs-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let compteurs = try? propertyListEncoder.encode(Compteurs)
            try? compteurs?.write(to: archiveURL, options: .noFileProtection)
            }
            
        
    }
    
    static func majCompteur ( compteur: Compteur ) {
        // On met à jour l'EDL si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if CompteurController.shared.compteurs.count > 0 {
            for index in 0...CompteurController.shared.compteurs.count - 1 {
                if CompteurController.shared.compteurs[index].idCompteur == compteur.idCompteur {
                    CompteurController.shared.compteurs[index] = compteur
                    nouv = false
                    break
                }
            }
        }
        if nouv {
            CompteurController.shared.compteurs.append(compteur)
        }
        CompteurController.sauveCompteurs(CompteurController.shared.compteurs)
        EDLsController.horodat[EDLsController.selectedEDLUUID()] = Date()
    }
    
    static func supprCompteur (compteur: Compteur) {
        for index in 0...CompteurController.shared.compteurs.count - 1 {
            if CompteurController.shared.compteurs[index] == compteur {
                if let images = compteur.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                CompteurController.shared.compteurs.remove(at: index)
                CompteurController.sauveCompteurs(CompteurController.shared.compteurs)
                break
            }
            
        }
        
    }
    
    static func supprCompteurTout () {
        CompteurController.shared.compteurs = [ ]
        supprFichier(nomFichier: "Compteurs-\(EDLsController.selectedEDLUUIDString())", extensionFichier: "plist")
    }
    
    
    static func existeCompteur ( compteur: Compteur) -> Bool {
        for compt in CompteurController.shared.compteurs {
            if compt.idCompteur == compteur.idCompteur {
                return true
            }
        }
        return false
    }
    
    static func compteurByUUID ( idCompteur: UUID ) -> Compteur? {
        for compt in CompteurController.shared.compteurs {
            if compt.idCompteur == idCompteur {
                return compt
            }
        }
        return nil
    }
    
    static func reChargeCompteur () {
        CompteurController.shared.compteurs = [ ]
        if let compteurs = CompteurController.chargeCompteurs() {
            CompteurController.shared.compteurs = compteurs
        }
        
    }
    
}
