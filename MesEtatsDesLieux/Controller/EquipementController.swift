//
//  EquipementController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

class EquipementController {
    static let shared = EquipementController(equipements: [])
    var equipements = [Equipement]()
    
    init(equipements: [Equipement] = [Equipement]()) {
        
        if let equipements = EquipementController.chargeEquipements() {
            self.equipements = equipements
        } else {
            self.equipements = [ ]
        }
    }
    
    
    
    static func chargeEquipements() -> [Equipement]? {
        let archiveURL = documentsDirectory.appendingPathComponent("Equipements-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let equipements = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Equipement].self, from: equipements)
    }
    
    static func sauveEquipements (_ equipements: [Equipement]? = EquipementController.shared.equipements) {
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("Equipements-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let equipements = try? propertyListEncoder.encode(equipements)
            try? equipements?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func reChargeEquipement () {
        EquipementController.shared.equipements = [ ]
        if let equipements = EquipementController.chargeEquipements() {
            EquipementController.shared.equipements = equipements
        }
        
    }
    
    static func nombreEquipements ( idCategorie: UUID ) -> Int {
        
        /* Ancienne syntaxe
        var nombre: Int = 0
        nombre = EquipementController.shared.equipements.map { $0.idCategorie}.filter { $0 == equipement.idEquipement}.count
        
        for equipementPresent in EquipementController.shared.equipements {
            if equipementPresent.idCategorie == equipement.idEquipement{
                nombre += 1
            }
        }
         */
        return EquipementController.shared.equipements.map { $0.idCategorie}.filter { $0 == idCategorie}.count
    }
   
    
    static func majEquipement ( equipement: Equipement ) {
        // On met à jour l'EDL si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if EquipementController.shared.equipements.count > 0 {
            for index in 0...EquipementController.shared.equipements.count - 1 {
                if EquipementController.shared.equipements[index].idEquipement == equipement.idEquipement {
                    EquipementController.shared.equipements[index] = equipement
                    nouv = false
                    break
                }
            }
        }
        if nouv {
            EquipementController.shared.equipements.append(equipement)
        }
        EquipementController.sauveEquipements(EquipementController.shared.equipements)
        EDLsController.horodat[EDLsController.selectedEDLUUID()] = Date()
    }
    
    static func supprEquipement (equipement: Equipement) {
        for index in 0...EquipementController.shared.equipements.count - 1 {
            if EquipementController.shared.equipements[index] == equipement {
                if let images = equipement.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                EquipementController.shared.equipements.remove(at: index)
                EquipementController.sauveEquipements(EquipementController.shared.equipements)
                break
            }
            
        }
        
    }
    
    static func supprEquipementTout () {
        EquipementController.shared.equipements = [ ]
        supprFichier(nomFichier: "Equipements-\(EDLsController.selectedEDLUUIDString())", extensionFichier: "plist")
    }
    
    static func existeEquipement ( equipement: Equipement) -> Bool {
        for compt in EquipementController.shared.equipements {
            if compt.idEquipement == equipement.idEquipement {
                return true
            }
        }
        return false
    }
    
    static func equipementByUUID ( idEquipement: UUID ) -> Equipement? {
        for compt in EquipementController.shared.equipements {
            if compt.idEquipement == idEquipement {
                return compt
            }
        }
        return nil
    }
    
    static func pieceEquipementByUUID ( idEquipement: UUID ) -> Equipement? {
        for compt in EquipementController.shared.equipements {
            if compt.idEquipement == idEquipement {
                return compt
            }
        }
        return nil
    }
    
    
}
