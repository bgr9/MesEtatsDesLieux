//
//  Categorie.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

struct Categorie: Codable , Comparable {
    
    static func < (lhs: Categorie, rhs: Categorie) -> Bool {
        return lhs.nomCategorie.uppercased() < rhs.nomCategorie.uppercased()
    }
    
    var nomCategorie: String
    var idCategorie = UUID()
    var idBien: UUID
    var idSnapshot: Int = 0
    var ordreAffichage: Int?
    
    enum TypeElement: Codable {
        case compteur
        case entretien
        case clef
        case equipement
        case categorie
        case fourniture
    }
    var typeElement: TypeElement
    
}

extension Categorie: Hashable {
    static func == (lhs:Categorie, rhs: Categorie) -> Bool {
        return lhs.idCategorie == rhs.idCategorie && lhs.nomCategorie == rhs.nomCategorie
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idCategorie.uuidString + nomCategorie)
    }
}
