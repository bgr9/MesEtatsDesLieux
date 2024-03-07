//
//  Compteur.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation
struct Compteur: Codable {
    
    var descriptionTableau = [
        "Paragraphe"            : "Relevé des compteurs",
        "nomCompteur"           : "Equipement",
        "enServicePresent"      : "En service/Présent",
        "indexCompteur"         : "Index",
        "uniteCompteur"         : "Unité",
        "localisationCompteur"  : "Localisation",
        "motifNonReleve"        : "Non relevé(motif)"
        ]
    
    var idCompteur: UUID = UUID()
    var idSnapshot: Int = 0
    
    var idCategorie: UUID
    var nomCompteur: String
    var localisationCompteur: String?
    
    var enServicePresent: Bool?
    var indexCompteur: Int?
    var uniteCompteur: String?
    var motifNonReleve: String?
    
    var enServicePresentSortie: Bool?
    var indexCompteurSortie: Int?
    var uniteCompteurSortie: String?
    var motifNonReleveSortie: String?
    
    
    var images: [ImageEDL]?
    
    init ( idCategorie: UUID , nomCompteur: String, enServicePresent: Bool, indexCompteur: Int, uniteCompteur: String, localisationCompteur: String, motifNonReleve: String ) {
        
        self.idCategorie = idCategorie
        self.nomCompteur = nomCompteur
        self.enServicePresent = enServicePresent
        self.indexCompteur = indexCompteur
        self.uniteCompteur = uniteCompteur
        self.localisationCompteur = localisationCompteur
        self.motifNonReleve = motifNonReleve
        
        
    }

}








extension Compteur: Hashable {
    static func == (lhs:Compteur, rhs: Compteur) -> Bool {
        return lhs.idCompteur == rhs.idCompteur
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idCompteur)
    }
}
