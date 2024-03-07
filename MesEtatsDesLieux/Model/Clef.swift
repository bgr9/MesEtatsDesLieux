//
//  Clef.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation
struct Clef: Codable {
    
    var descriptionTableau = [
        "intituleClef"             : "Description",
        "nombreClefs"              : "Nombre",
        "observationClef"          : "Observations"
        ]
    
    
    var idClef: UUID = UUID()
    var idCategorie: UUID
    var idSnapshot: Int = 0
    
    
    var intituleClef: String
    var nombreClefs: Int?
    var observationClef: String?
    var images: [ImageEDL]?
    
    var nombreClefsSortie: Int?
    var observationClefSortie: String?
    
}

extension Clef: Hashable {
    static func == (lhs:Clef, rhs: Clef) -> Bool {
        return lhs.idClef  == rhs.idClef
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idClef)
    }
}

