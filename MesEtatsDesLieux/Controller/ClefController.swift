//
//  ClefController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

class ClefController {
    static let shared = ClefController(clefs: [])
    var clefs = [Clef]()
    
    init(clefs: [Clef] = [Clef]()) {
        
        if let clefs = ClefController.chargeClefs() {
            self.clefs = clefs
        } else {
            self.clefs = []
        }
    }
    
    
  
    
    static func chargeClefs() -> [Clef]? {
        let archiveURL = documentsDirectory.appendingPathComponent("Clefs-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let clefs = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Clef].self, from: clefs)
    }
    
    static func sauveClefs (_ Clefs: [Clef]? = ClefController.shared.clefs) {
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("Clefs-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let clefs = try? propertyListEncoder.encode(Clefs)
            try? clefs?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func reChargeClef () {
        ClefController.shared.clefs = [ ]
        if let clefs = ClefController.chargeClefs() {
            ClefController.shared.clefs = clefs
        }
        
    }
    
    
    static func majClef ( clef: Clef ) {
        // On met à jour l'EDL si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if ClefController.shared.clefs.count > 0 {
            for index in 0...ClefController.shared.clefs.count - 1 {
                if ClefController.shared.clefs[index].idClef == clef.idClef {
                    ClefController.shared.clefs[index] = clef
                    nouv = false
                    break
                }
            }
        }
        if nouv {
            ClefController.shared.clefs.append(clef)
        }
        ClefController.sauveClefs(ClefController.shared.clefs)
        EDLsController.horodat[EDLsController.selectedEDLUUID()] = Date()
    }
    
    static func supprClef (clef: Clef) {
        for index in 0...ClefController.shared.clefs.count - 1 {
            if ClefController.shared.clefs[index] == clef {
                if let images = clef.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                ClefController.shared.clefs.remove(at: index)
                ClefController.sauveClefs(ClefController.shared.clefs)
                break
            }
            
        }
        
    }
    static func supprClefTout () {
        ClefController.shared.clefs = [ ]
        supprFichier(nomFichier: "Clefs-\(EDLsController.selectedEDLUUIDString())", extensionFichier: "plist")
    }
    static func existeClef ( clef: Clef) -> Bool {
        for compt in ClefController.shared.clefs {
            if compt.idClef == clef.idClef {
                return true
            }
        }
        return false
    }
    
    static func clefByUUID ( idClef: UUID ) -> Clef? {
        for compt in ClefController.shared.clefs {
            if compt.idClef == idClef {
                return compt
            }
        }
        return nil
    }
    
    
    
    
}
