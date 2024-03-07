//
//  EDLController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 05/12/2022.
//

import Foundation

class EDLsController {
    
    static let shared = EDLsController(edls: [ ])
    var edls = [EDL]()
    static var horodat: [UUID? : Date] = [ : ] {
        didSet {
            print("---- Statut Trace HO",horodat)
        }
    }
    
    
    var selectedEDLIndex: Int? {
        
        didSet {
            
            print("----> EDL selectionné: ", selectedEDLIndex ?? "pas de valeur")
        }
    }
    
    init (edls: [EDL]) {
        if let edlsCharges = EDLsController.chargeEDLs() {
            self.edls = edlsCharges
        } else {
            self.edls = []
        }
        
    }
    
    static let archiveURL = documentsDirectory.appendingPathComponent("EDLs").appendingPathExtension("plist")
    
    static func chargeEDLs() -> [EDL]? {
        guard let edls = try? Data(contentsOf: archiveURL) else { return nil}
        print("--- ArchiveURL : \( archiveURL)")
        let propertuListDecoder = PropertyListDecoder()
        return try? propertuListDecoder.decode([EDL].self, from: edls)
    }
    
    
    
    static func sauveEDLs (_ edls: [EDL]? = EDLsController.shared.edls ,  _ isHorodatage: Bool = true) {
        if isHorodatage {
            if var newEdls = edls,
               newEdls.count > 0 {
                // Ajout de l'horodatage
                for i in 0...newEdls.count - 1 {
                    if let dateMaj = EDLsController.horodat[newEdls[i].idEDL] {
                        newEdls[i].dateDerniereMajEDL = dateMaj
                    } else {
                        // Pas d'horodatage car on n'a pas encore démarer l'état des lieux
                        let newDateMaj = Date()
                        newEdls[i].dateDerniereMajEDL = newDateMaj
                        EDLsController.horodat[newEdls[i].idEDL] = newDateMaj
                        
                        
                    }
                }
                EDLsController.shared.edls = newEdls
            }
            // Sauvegarde
            let propertyListEncoder = PropertyListEncoder()
            let edlsEncode = try? propertyListEncoder.encode(EDLsController.shared.edls)
            try? edlsEncode?.write(to: archiveURL, options: .noFileProtection)
            
        }
    }
    
    
    static func edlFromNomBien ( nomBien: String ) -> EDL? {
        for edl in EDLsController.shared.edls {
            if edl.nomBien.localizedCapitalized == nomBien.localizedCapitalized { return edl }
        }
        return nil
    }
    
    static func edlFromUUID ( idEDL: UUID ) -> EDL? {
        for edl in EDLsController.shared.edls {
            if edl.idEDL == idEDL { return edl }
        }
        return nil
    }
    
    
    static func majEDL ( edl: EDL , _ isHorodatage: Bool = true) -> Int {
        // On met à jour l'EDL si il existe, sinon on ajoute le nouveau
        var nouvEDL: Bool = true
        var indexEDL: Int = 0
        if EDLsController.shared.edls.count > 0 {
            for index in 0...EDLsController.shared.edls.count - 1 {
                if EDLsController.shared.edls[index] == edl {
                    EDLsController.shared.edls[index] = edl
                    indexEDL = index
                    nouvEDL = false
                    break
                }
            }
        }
        if nouvEDL { EDLsController.shared.edls.append(edl)
            indexEDL = EDLsController.shared.edls.count - 1
        }
        if isHorodatage {
            EDLsController.horodat[EDLsController.shared.edls[indexEDL].idEDL] = Date()
        }
        EDLsController.sauveEDLs(EDLsController.shared.edls, isHorodatage)
        
        return indexEDL
    }
    
    static func supprEDL ( id : UUID ) {
        var indexEDL = -1
        for i in 0...EDLsController.shared.edls.count - 1 {
            if EDLsController.shared.edls[i].idEDL == id {
                indexEDL = i
                break
            }
        }
        if indexEDL == -1 { return }
        
        _ = EDLsController.selectEDLbyUUID(id: id)
        
        // On supprime les données associées
        CategorieController.supprCategorieTout()
        CompteurController.supprCompteurTout()
        EntretienController.supprEntretienTout()
        ClefController.supprClefTout()
        FournitureController.supprFournitureTout()
        EquipementController.supprEquipementTout()
        
        // TODO: Supprimer les fichiers pdfs ?
        
        
        EDLsController.shared.edls.remove(at: indexEDL)
        if EDLsController.shared.edls.count > 0 {
            sauveEDLs(EDLsController.shared.edls)
        } else {
            supprFichier(listeURL: [archiveURL])
        }
        
        // Pour éviter une erreur à l'exécution on met l'EDL selectionné sur le premier ou sur nil si il n'y en a pas
        if EDLsController.shared.edls.count > 0 {
            _ = EDLsController.selectEDLbyUUID(id: EDLsController.shared.edls.first!.idEDL)
            
        }
    }
    
    static func supprEDL ( index: Int) {
        let edlASupprimer = EDLsController.shared.edls[index]
        _ = EDLsController.selectEDLbyUUID(id: edlASupprimer.idEDL)
        
        // On supprime les données associées
        CategorieController.supprCategorieTout()
        CompteurController.supprCompteurTout()
        EntretienController.supprEntretienTout()
        ClefController.supprClefTout()
        FournitureController.supprFournitureTout()
        EquipementController.supprEquipementTout()
        
        // TODO: Supprimer les fichiers pdfs ?
        
        
        
        EDLsController.shared.edls.remove(at: index)
        sauveEDLs(EDLsController.shared.edls)
        
        // Pour éviter une erreur à l'exécution on met l'EDL selectionné sur le premier ou sur nil si il n'y en a pas
        if EDLsController.shared.edls.count > 0 {
            _ = EDLsController.selectEDLbyUUID(id: EDLsController.shared.edls.first!.idEDL)
        }
        
        
    }
    
    /// Retourne l'index de l'EDL selectionné
    static func selectedEDLIndex () -> Int? {
        if let selectedlindex = EDLsController.shared.selectedEDLIndex {
            return selectedlindex
        } else { return nil }
    }
    
    /// Retourne l'uuid String de l'EDL selectionné
    static func selectedEDLUUIDString () -> String {
        guard let index = EDLsController.shared.selectedEDLIndex else { return "" }
        return  EDLsController.shared.edls[index].idEDL.uuidString
    }
    
    /// Retourne l'uuid de l'EDL selectionné
    static func selectedEDLUUID () -> UUID? {
        guard let index = EDLsController.shared.selectedEDLIndex else { return nil }
        return  EDLsController.shared.edls[index].idEDL
    }
    
    /// Retourne l'EDL selectionné
    static func selectedEDLedl () -> EDL? {
        guard let index = EDLsController.shared.selectedEDLIndex else { return nil }
        return  EDLsController.shared.edls[index ]
        
    }
    
    /// Positionne l'EDL selectionné et retourne son nom si il n'y a pas d'erreur
    static func selectEDLIndex ( index: Int ) -> String? {
        if index < EDLsController.shared.edls.count {
            
            EDLsController.shared.selectedEDLIndex = index
            return EDLsController.shared.edls[index].nomBien
            
        } else { return nil }
    }
    
    /// Positionne l'EDL selectionné via UUID et retourne son nom si il n'y a pas d'erreur
    static func selectEDLbyUUID ( id: UUID ) -> String? {
        for i in 0...EDLsController.shared.edls.count - 1 {
            if EDLsController.shared.edls[i].idEDL == id {
                EDLsController.shared.selectedEDLIndex = i
                return EDLsController.shared.edls[i].nomBien
            }
        }
        return nil
    }
    /// Retourne l'id de l'emetteur de l'EDL
    static func emetteurEDL ( edl: EDL ) -> Emetteur? {
        guard edl.idEmetteur != nil else { return nil }
        return EmetteurController.emetteurByUUID(uuidEmetteur: edl.idEmetteur!)
    }
    
    /// Retourne un booleen pour signifier l'existece d'au moins un EDL pour l'emetteur
    static func existeEDLPourEmetteur (idEmetteur : UUID) -> Bool {
        for edl in EDLsController.shared.edls {
            if edl.idEmetteur == idEmetteur {
                if EmetteurController.emetteurByUUID(uuidEmetteur: idEmetteur) != nil {
                    return true
                }
                
            }
        }
        return false
    }
    
    /// Nom complet du fichier stockant la signature
    static func nomFichierSignatureBailleur ( idEDL: UUID ) -> String {
        return "SignatureBailleur-" + idEDL.uuidString
    }
    /// Nom complet du fichier stockant la signature
    static func nomFichierSignatureLocataire ( idEDL: UUID ) -> String {
        return "SignatureLocataire-" + idEDL.uuidString
    }
    /// Nom complet du fichier stockant le paraphe
    static func nomFichierParapheBailleur ( idEDL: UUID ) -> String {
        return "ParapheBailleur-" + idEDL.uuidString
    }
    /// Nom complet du fichier stockant le paraphe
    static func nomFichierParapheLocataire ( idEDL: UUID ) -> String {
        return "ParapheLocataire-" + idEDL.uuidString
    }
    /// Nom de la racine du PDF sans signature
    static func nomFichierRacineEDLPDFSansSignature ( idEDL: UUID) -> String {
        return "EDL-SS-\(idEDL.uuidString)"
    }
    /// Nom de du PDF sans signature inclueant la racine et l'horodatage
    static func nomFichierEDLPDFSansSignature ( idEDL: UUID) -> String {
        return nomFichierRacineEDLPDFSansSignature ( idEDL: idEDL) + "-\(chaineDateOrdonnee())"
    }
    /// Nom de la racine du PDF avec signature
    static func nomFichierRacineEDLPDFAvecSignature ( idEDL: UUID) -> String {
        return "EDL-AS-\(idEDL.uuidString)"
    }
    /// Nom de du PDF avec signature inclueant la racine et l'horodatage
    static func nomFichierEDLPDFAvecSignature ( idEDL: UUID) -> String {
        return nomFichierRacineEDLPDFAvecSignature ( idEDL: idEDL) + "-\(chaineDateOrdonnee())"
    }
    
    /// Mise à jour de l'horodatage de l'EDL faisant périmer les fichiers PDF
    static func touchEDL ( idEDL: UUID) {
        EDLsController.horodat[idEDL] = Date()
    }
}
