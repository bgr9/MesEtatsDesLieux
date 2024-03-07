//
//  Emetteur.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 24/01/2023.
//

import Foundation
import UIKit



struct Emetteur {
    
    var nomEmetteur: String
    var idEmetteur: UUID = UUID()
    var idSnapshot: Int = 0
    
    var adresseEmetteur: String?
    var villeEmetteur: String?
    var codePostalEmetteur: String?
    
    var logoPresent: Bool = false
    // Le logo est un fichier avec un nom élabore avec idEmetteur -> voir le controlleur
    
    var clauseContractuelleEntree:  String
    var validationClauseContractuelleEntree: Bool = false
    
    var clauseContractuelleSortie:  String
    var validationClauseContractuelleSortie: Bool = false
    
    var libelleSignatureLocataire: String
    var libelleSignatureBailleur: String
    var validationSignature: Bool = false
    
    var blocPiedPage: String?
    var validationBlocPiedPage: Bool = false
    
    }


extension Emetteur: Codable { }

extension Emetteur: Hashable {
    static func == (lhs:Emetteur, rhs: Emetteur) -> Bool {
        return lhs.idEmetteur == rhs.idEmetteur
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idEmetteur)
    }
}

