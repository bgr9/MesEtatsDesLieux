//
//  Entretien.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation
struct Entretien: Codable {
    
    var descriptionTableau = [
        "Paragraphe"            : "Contrats d'entretien",
        "intitule"              : "Objet",
        "realise"               : "Actif",
        "dateEcheanceEntretien" : "Echéance",
        "observationEntretien"  : "Observations"
        ]
    
    
    var idEntretien : UUID = UUID()
    var idSnapshot: Int = 0
    
    var idCategorie: UUID
    var intitule: String
    var realise: Bool
    var dateEcheanceEntretien: String
    
    var observationEntretien: String?
    var observationEntretienSortie: String?
    
    var images: [ImageEDL]?
    
    
}


extension Entretien: Hashable {
    static func == (lhs:Entretien, rhs: Entretien) -> Bool {
        return lhs.idEntretien == rhs.idEntretien
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idEntretien)
    }
}
