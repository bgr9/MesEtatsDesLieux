//
//  CategorieController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

class CategorieController {
    static let shared = CategorieController(categories: [])
    
    var categories = [Categorie]()

    init(categories: [Categorie] = [Categorie]()) {
       
        if let categories = CategorieController.chargeCategories() {
            self.categories = categories
        } else {
            self.categories = [ ]
        }
    }
    
    
    
    static func chargeCategories() -> [Categorie]? {
        
        
        let archiveURL = documentsDirectory.appendingPathComponent("Categories-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
        print("--- ArchiveURL : \(archiveURL)")
        guard let categories = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([Categorie].self, from: categories)
    }
    
    static func sauveCategories (_ categories: [Categorie]? = CategorieController.shared.categories) {
        
        
        
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("Categories-\(EDLsController.selectedEDLUUIDString())").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let categories = try? propertyListEncoder.encode(categories)
            try? categories?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func categorieUUID (nomCategorie: String) -> UUID {
        for categorie in self.shared.categories {
            if categorie.nomCategorie == nomCategorie {
                return categorie.idCategorie
            }
        }
        fatalError("Categorie non trouvée")
    }
    
    static func categorieByNom (nomCategorie: String) -> Categorie {
        for categorie in self.shared.categories {
            if categorie.nomCategorie == nomCategorie {
                return categorie
            }
        }
        fatalError("Categorie non trouvée par nom")
        
    }
    static func categorieByUUID (uuidCategorie: UUID) -> Categorie {
        for categorie in self.shared.categories {
            if categorie.idCategorie == uuidCategorie {
                return categorie
            }
        }
        fatalError("Categorie non trouvée par UUID")
        
    }
    
    static func majCategorie ( categorie: Categorie )  {
        // On met à jour la Categorie si il existe, sinon on ajoute le nouveau
        var nouv: Bool = true
        if CategorieController.shared.categories.count > 0 {
            for index in 0...CategorieController.shared.categories.count - 1 {
                if CategorieController.shared.categories[index] == categorie {
                    CategorieController.shared.categories[index] = categorie
                    nouv = false
                    break
                }
            }
        }
        if nouv {
            CategorieController.shared.categories.append(categorie)
        }
        CategorieController.sauveCategories(CategorieController.shared.categories)
        EDLsController.horodat[EDLsController.selectedEDLUUID()] = Date()
    }
    
    static func supprCategorie (categorie: Categorie) {
        
        // On ne peut supprimer que des categorie de type Equipement qui n'ont pas d'equipement rattachées
        for index in 0...CategorieController.shared.categories.count - 1 {
            if CategorieController.shared.categories[index] == categorie  &&
                CategorieController.shared.categories[index].typeElement == .equipement &&
                EquipementController.nombreEquipements(idCategorie: CategorieController.shared.categories[index].idCategorie) == 0 {
                CategorieController.shared.categories.remove(at: index)
                CategorieController.sauveCategories(CategorieController.shared.categories)
                break
            }
            
        }
        
    }
    
    static func supprCategorieTout () {
        CategorieController.shared.categories = [ ]
        supprFichier(nomFichier: "Categories-\(EDLsController.selectedEDLUUIDString())", extensionFichier: "plist")
    }
    
    // Renomme des categories dynamiques pour les pieces (type equipement)
    static func renommeCategorie (idActuelleCategorie: UUID,  idNouvellecategorie: UUID, nouvNom: String) {
        var categoriesActuelles = CategorieController.shared.categories
        for index in 0...categoriesActuelles.count - 1 {
            if categoriesActuelles[index].idCategorie == idActuelleCategorie {
                categoriesActuelles[index].nomCategorie = nouvNom
                categoriesActuelles[index].idCategorie = idNouvellecategorie
                CategorieController.shared.categories[index] = categoriesActuelles[index]
                break
            }
        }
        CategorieController.sauveCategories(CategorieController.shared.categories)
    }
    
    
    static func reChargeCategorie () {
        CategorieController.shared.categories = [ ]
        if let categories = CategorieController.chargeCategories() {
            CategorieController.shared.categories = categories
        }
        
    }
    
    
}
