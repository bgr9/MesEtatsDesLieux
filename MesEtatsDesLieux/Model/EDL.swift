//
//  EDL.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 05/12/2022.
//

import Foundation
import UIKit

enum TypeEDL: Codable {
    case entree
    case sortie
    case nondefini
    var libelleTypeEdl: String {
        switch self {
        case .entree: return "Entrée"
        case .sortie: return "Sortie"
        case .nondefini : return "Indéfini"
        }
    }
}

enum EtatEDL: Codable {
    case actif
    case cloture
    case archive
    var libelleEtatEDL: String {
        switch self {
        case .actif:    return "Actif"
        case .cloture:  return "Cloturé"
        case .archive:  return "Archivé"
        }
    }
    
}



struct EDL {
    var idEDL : UUID
    var idSnapshot: Int = 0
    var ordreAffichage: Int?
    var etatEDL: EtatEDL = .actif
    
    var idEDLEntree : UUID?
    var isEDLSortieApresEntree: Bool = false
    var refEDLEntree: String?
    var dateEDLEntree: Date?
    var fichierEntreePDFSigneNomFichier: String?
    var fichierEntreePDFViergeNomFichier: String?
    
    
    var nomBien: String = ""
    var typeBien: String?
    var adresseBien: String = ""
    var villeBien: String = ""
    var codePostalBien: String = ""
    var localisationBien: String = ""
    
    var nomProprietaire: String = ""
    var nomLocataire: String = ""
    var emailLocataire: String = ""
    
    var nomMandataire: String?
    var adresseMandataire: String?
    var villeMandataire: String?
    var codePostalMandataire: String?

    var typeEDL: TypeEDL = .nondefini
    var refEDL: String?
    var dateEDL: Date = Date()
    var nomExecutantEDL: String = ""
    var validationPlanifEDL: Bool
    
    var pictoEDL: UIImage {
        switch typeEDL {
        case .sortie : return .pictoEDLSortie!
        case .entree : return .pictoEDLEntree!
        case .nondefini : return UIImage(systemName: "questionmark")!
        }
    }
    
    var idEmetteur : UUID?
    
    var actionsBien : [ActionBien] = []
    var dateDerniereMajEDL: Date?
    
    
    var signatureBailleurImageEDL: ImageEDL?
    var signatureLocataireImageEDL: ImageEDL?
    
    var parapheBailleurImageEDL: ImageEDL?
    var parapheLocataireImageEDL: ImageEDL?
    
    var dernierFichierSigneNomFichier: String?
    var dateDernierFichierSigne: Date?
   
    var dernierFichierViergeNomFichier: String?
    var dateDernierFichierVierge: Date?
   
    var nCompteurs: Int
    var nClefs: Int
    var nEntretiens: Int
    var nFournitures: Int
    var nPieces: Int
    var nEquipements: Int
    
  
    fileprivate mutating func initActionBien() {
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .decrireBien              , ordreAction: 0))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .identActeurs             , ordreAction: 1))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .planifEDL                , ordreAction: 2))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .realEDL                  , ordreAction: 3))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .miseEnPage               , ordreAction: 4))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .genererDocVierge         , ordreAction: 5))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .genererDocSigne          , ordreAction: 6))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .clotureEDL               , ordreAction: 7))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .visuDocDefinitifVierge   , ordreAction: 8))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .visuDocDefinitifSigne    , ordreAction: 9))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .repriseNouvelEDL         , ordreAction: 10))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .ajoutSortieEDLEntree     , ordreAction: 11))
        self.actionsBien.append(ActionBien(id: UUID() , idBien: self.idEDL, typeAction: .reactivationEDL          , ordreAction: 12))
    }
    
    init (idEDL: UUID) {
        
        self.idEDL = idEDL
        self.validationPlanifEDL = false
        self.nCompteurs = 0
        self.nClefs = 0
        self.nEntretiens = 0
        self.nFournitures = 0
        self.nPieces = 0
        self.nEquipements = 0
        
        initActionBien()
    }
  
    init () {
        self.idEDL = UUID()
        self.validationPlanifEDL = false
        self.nCompteurs = 0
        self.nClefs = 0
        self.nEntretiens = 0
        self.nFournitures = 0
        self.nPieces = 0
        self.nEquipements = 0
        
        initActionBien()
        
    }
    
    
    }
    
    



extension EDL: Codable { }

extension EDL: Hashable {
    static func == (lhs:EDL, rhs: EDL) -> Bool {
        return lhs.idEDL == rhs.idEDL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idEDL)
    }
}


