//
//  FournitureController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

class FournitureController {
    static let shared = FournitureController(fournitures: [])
    var fournitures = [Fourniture]()
    
    init(fournitures: [Fourniture] = [Fourniture]()) {
        
        if let fournitures = FournitureController.chargeFournitures() {
            self.fournitures = fournitures
        } else {
            self.fournitures = [ ]
        }
    }
    
    
    
    
  
    
    static func chargeFournitures() -> [Fourniture]? {
        let archiveURL = documentsDirectory.appendingPathComponent("Fournitures-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let fournitures = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Fourniture].self, from: fournitures)
    }
    
    static func sauveFournitures (_ fournitures: [Fourniture]? = FournitureController.shared.fournitures) {
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("Fournitures-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let fournitures = try? propertyListEncoder.encode(fournitures)
            try? fournitures?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func reChargeFourniture () {
        FournitureController.shared.fournitures = [ ]
        if let fournitures = FournitureController.chargeFournitures() {
            FournitureController.shared.fournitures = fournitures
        } 
        
    }
    
    static func majFourniture ( fourniture: Fourniture ) {
        // On met à jour l'EDL si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if FournitureController.shared.fournitures.count > 0 {
            for index in 0...FournitureController.shared.fournitures.count - 1 {
                if FournitureController.shared.fournitures[index].idEquipement == fourniture.idEquipement {
                    FournitureController.shared.fournitures[index] = fourniture
                    nouv = false
                    break
                }
            }
        }
        if nouv {
            FournitureController.shared.fournitures.append(fourniture)
        }
        FournitureController.sauveFournitures(FournitureController.shared.fournitures)
        EDLsController.horodat[EDLsController.selectedEDLUUID()] = Date()
    }
    
    static func supprFourniture (fourniture: Fourniture) {
        for index in 0...FournitureController.shared.fournitures.count - 1 {
            if FournitureController.shared.fournitures[index] == fourniture {
                if let images = fourniture.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                FournitureController.shared.fournitures.remove(at: index)
                FournitureController.sauveFournitures(FournitureController.shared.fournitures)
                break
            }
            
        }
        
    }
    
    static func supprFournitureTout () {
        FournitureController.shared.fournitures = [ ]
        supprFichier(nomFichier: "Fournitures-\(EDLsController.selectedEDLUUIDString())", extensionFichier: "plist")
    }
    
    static func existeFourniture ( fourniture: Fourniture) -> Bool {
        for compt in FournitureController.shared.fournitures {
            if compt.idEquipement == fourniture.idEquipement {
                return true
            }
        }
        return false
    }
    
    static func fournitureByUUID ( idEquipement: UUID ) -> Fourniture? {
        for compt in FournitureController.shared.fournitures {
            if compt.idEquipement == idEquipement {
                return compt
            }
        }
        return nil
    }
    
    

    
}
