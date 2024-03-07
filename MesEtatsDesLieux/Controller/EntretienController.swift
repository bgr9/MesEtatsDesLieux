//
//  EntretienController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

class EntretienController {
    static let shared = EntretienController(entretiens: [])
    var entretiens = [Entretien]()
    
    init(entretiens: [Entretien] = [Entretien]()) {
        
        
            if let entretiens = EntretienController.chargeEntretiens() {
                self.entretiens = entretiens
            } else {
                self.entretiens = []
            }
    }
        
    
    static func chargeEntretiens() -> [Entretien]? {
        let archiveURL = documentsDirectory.appendingPathComponent("Entretiens-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let entretiens = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Entretien].self, from: entretiens)
    }
    
    static func sauveEntretiens (_ entretiens: [Entretien]? = EntretienController.shared.entretiens) {
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("Entretiens-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let entretiens = try? propertyListEncoder.encode(entretiens)
            try? entretiens?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func reChargeEntretien () {
        EntretienController.shared.entretiens = [ ]
        if let entretiens = EntretienController.chargeEntretiens() {
            EntretienController.shared.entretiens = entretiens
        }
        
    }
    
    
    static func majEntretien ( entretien: Entretien ) {
        // On met à jour l'EDL si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if EntretienController.shared.entretiens.count > 0 {
            for index in 0...EntretienController.shared.entretiens.count - 1 {
                if EntretienController.shared.entretiens[index].idEntretien == entretien.idEntretien {
                    EntretienController.shared.entretiens[index] = entretien
                    nouv = false
                    break
                }
            }
        }
        if nouv {
            EntretienController.shared.entretiens.append(entretien)
        }
        EntretienController.sauveEntretiens(EntretienController.shared.entretiens)
        EDLsController.horodat[EDLsController.selectedEDLUUID()] = Date()
    }
    
    static func supprEntretien (entretien: Entretien) {
        for index in 0...EntretienController.shared.entretiens.count - 1 {
            if EntretienController.shared.entretiens[index] == entretien {
                if let images = entretien.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                EntretienController.shared.entretiens.remove(at: index)
                EntretienController.sauveEntretiens(EntretienController.shared.entretiens)
                break
            }
            
        }
        
    }
    
    static func supprEntretienTout () {
        EntretienController.shared.entretiens = [ ]
        supprFichier(nomFichier: "Entretiens-\(EDLsController.selectedEDLUUIDString())", extensionFichier: "plist")
    }
    
    static func existeEntretien ( entretien: Entretien) -> Bool {
        for compt in EntretienController.shared.entretiens {
            if compt.idEntretien == entretien.idEntretien {
                return true
            }
        }
        return false
    }
    
    static func entretienByUUID ( idEntretien: UUID ) -> Entretien? {
        for compt in EntretienController.shared.entretiens {
            if compt.idEntretien == idEntretien {
                return compt
            }
        }
        return nil
    }
    
    
    
    
    
}
