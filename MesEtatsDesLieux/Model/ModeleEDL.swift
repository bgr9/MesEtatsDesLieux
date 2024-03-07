//
//  ModeleEDL.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 14/02/2023.
//

import Foundation
import UIKit

enum TypeModele: Codable, CustomStringConvertible, CaseIterable, Equatable {
    
    
    case vide       // Données minimales
    case typeBien   // Données de reprise d'un modele type (T1, Garage, ...)
    case demo                               // Données de demo
    case sortieApresEntree    //
    case reprise                          // Données reprises à partir d'un EDL existant

        
    var description: String {
        switch self {
        case .demo              : return "Modele de demonstration"
        case .typeBien          : return "Modele type selon la description du Bien"
        case .reprise           : return "Modele issu d'un état des lieux déjà réalisé"
        case .vide              : return "Sans Modèle"
        case .sortieApresEntree : return ""
        }
    }
    
    
}


struct ModeleEDL: Codable {
    var id: UUID
    var nomModele: String
    var typeModele: TypeModele
    var edl: EDL
    var categories: [Categorie] = [ ]
    var compteurs: [Compteur] = [ ]
    var entretiens: [Entretien] = [ ]
    var clefs: [Clef] = [ ]
    var fournitures: [Fourniture] = [ ]
    var equipements: [Equipement] = [ ]
    var emetteur: Emetteur?
}



func pictoModele (typeModel: TypeModele) -> UIImage {
    switch typeModel {
        
    case .demo: return UIImage(systemName: "doc.badge.gearshape")!
    case .vide: return UIImage(systemName: "doc")!
    case .typeBien : return UIImage(systemName: "doc.fill.badge.plus")!
    case .reprise: return #imageLiteral(resourceName: "filigrane")
    default:
        return UIImage(systemName: "questionmark")!
    }
    
}
