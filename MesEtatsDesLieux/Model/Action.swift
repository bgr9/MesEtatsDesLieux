//
//  Action.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 02/02/2023.
//

import Foundation

// MARK: - Temporaire

enum StatutAction: Codable {
    case nonPrevu
    case aFaire
    case enCours
    case termine
    case nonApplicable
    case actif          // Action simple sans changement de statut
    case inactif        // Action desactivée temporairement
    case masque         // Action qui n'apparait pas dans la liste
    
    var description: String {
        switch self {
        case .nonPrevu: return "Non Prevu"
        case .aFaire: return "A faire"
        case .enCours: return "En cours"
        case .termine: return "Complété"
        case .nonApplicable : return "Non applicable"
        case .actif: return ""
        case .inactif: return ""
        case .masque: return ""
        }
    }
}

enum TypeAction: Codable {
    case ajoutEDL
    case decrireBien
    case identActeurs
    case planifEDL
    case realEDL
    case miseEnPage
    case genererDocSigne
    case genererDocVierge
    case visuDocDefinitifSigne   //      - La visualisation du doc definitif signé
    case visuDocDefinitifVierge   //      - La visualisation du doc definitif vierge
    
    case clotureEDL
    
    case repriseNouvelEDL       //      - La reprise du bien sur un état des lieux suivant
    case reactivationEDL        //      - La réactivation de l'état des lieux pour revenir en situation active
    case ajoutSortieEDLEntree   //      - On reprend un EDL d'entrée et on fait l'état des lieux de sortie à partir de la saisie
    
    case nonApplicable
    
    
    var description: String {
        switch self {
        case .ajoutEDL: return ""
        case .decrireBien: return "Decrire le bien"
        case .identActeurs: return "Identifier les acteurs"
        case .planifEDL: return "Planifier l'état des lieux"
        case .realEDL: return "Réaliser l'état des lieux"
        case .miseEnPage: return "Mettre en page le document"
        case .genererDocSigne: return "Document avec signature scannée"
        case .genererDocVierge: return "Document pour signature manuscrite"
        case .visuDocDefinitifSigne : return "Document définitif avec signature"
        case .visuDocDefinitifVierge : return "Document définitif pour signature manuscrite"
        case .clotureEDL: return "Fin de l'état des lieux"
        
        case .repriseNouvelEDL     : return "Initier un nouvel état des lieux pour ce bien"
        case .reactivationEDL      : return "Reactiver cet état des lieux"
        case .ajoutSortieEDLEntree           : return "Faire l'état des lieux de sortie"
            
        case .nonApplicable: return "Non applicable"
        
        }
    }
    var indicationSaisie: String {
        switch self {
        case .decrireBien:
            return "Complétez les informations de description du bien."
        case .identActeurs:
            return "Identifier propriétaire, éventuel mandataire, locataire."
        case .planifEDL:
            return "Donner le type d'état des lieux, la date de réalisation de l'état des lieux et le nom de la personne exécutant la visite."
        case .ajoutEDL: return """
Ajout d'un bien locatif : commencer par définir le nom de ce bien.
Exemples :
Appartement T2 rue Alsace
Garage n° 10 - Le Segur
Maison impasse des rosiers
"""
        case .ajoutSortieEDLEntree: return """
Préparer l'état des lieux de sortie à partir d'un état des lieux déjà réalisé dans l'application.
"""
        case .repriseNouvelEDL: return """
Faire un nouvel état des lieux à partir des données existantes pour ce bien.
"""
        default: return ""
            
        }
    }
}




struct Bien: Hashable, Identifiable {
    
    
    var id : UUID
    var nomBien: String
    var idSnapshot: Int
    var ordreAffichage: Int?
    
    static func == (lhs: Bien , rhs: Bien )  -> Bool  {
        return (
        lhs.id == rhs.id  &&
        lhs.idSnapshot == rhs.idSnapshot &&
        lhs.nomBien == rhs.nomBien )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString + String(idSnapshot) + nomBien)
    }

}
 
struct ActionBien: Codable, Hashable , Identifiable {
    var id : UUID
    var idSnapshot: Int = 0
    var idBien: UUID
    
    var typeAction: TypeAction
    var ordreAction: Int = 0
        
    var statutAction: StatutAction { return statutCalc( actionBien: self ) }
    
    var descStatutAction: String { return descStatutActionCalc() }
    
    func descStatutActionCalc () -> String {
        
        switch (typeAction, statutAction ) {
        case ( TypeAction.realEDL , StatutAction.enCours ):
            // On restitue le nombre d'item par type
            var resultat: String = ""
            guard let edl = EDLsController.edlFromUUID(idEDL: self.idBien) else { return "" }
            
            /*
            if edl.nCompteurs > 0 { resultat += "C: \(edl.nCompteurs) "}
                if edl.nClefs > 0 { resultat += "Cl: \(edl.nClefs) "}
                if edl.nEntretiens > 0 { resultat += "E: \(edl.nEntretiens) "}
                if edl.nFournitures > 0 { resultat += "F: \(edl.nFournitures) "}
                if edl.nPieces > 0 {
                    resultat += "P: \(edl.nPieces)"
                    if edl.nEquipements > 0 { resultat += "(\(edl.nEquipements ))"}
                }
             */
            if let dateHoro = EDLsController.horodat[edl.idEDL] {
                resultat += " Dernière mise à jour: " + dateFormatter.string(from: dateHoro )
            } else if let dateHoro = edl.dateDerniereMajEDL {
                resultat += " Dernière mise à jour: " + dateFormatter.string(from: dateHoro )
            }
            return resultat
        default:
            return ""
        }
    
    }
    

    
    func statutCalc (actionBien : ActionBien, _ autreTypeAction: TypeAction? = nil) -> StatutAction {
        
        func statutCalcInterne (actionBien : ActionBien, _ autreTypeAction: TypeAction? = nil) -> StatutAction {
            
            guard let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) else { return .nonApplicable }
            
            var actionATraiter: TypeAction = actionBien.typeAction
            if let autreTypeAction = autreTypeAction {
                actionATraiter = autreTypeAction
            }
            
            switch actionATraiter {
                
            case .ajoutEDL:
                return .nonApplicable
                
            case .decrireBien :
                if edl.etatEDL == .cloture { return .masque }
                // Le type de bien est optionnel donc non significatif
                // Le reste est basé sur la saisie de tous les autres champs, hormis le nom du bien qui existe forcément
                return rempli([edl.nomBien, edl.adresseBien, edl.villeBien, edl.codePostalBien, edl.localisationBien])
                
            case .identActeurs :
                if edl.etatEDL == .cloture { return .masque }
                // A faire : aucun champ
                // Termine :
                // Si pas de mandataire : Nom Proprietaire, Nom Locataire et email Locataire sont remplis
                // SI mandataire : adresse code postal et ville mandataire remplies
                
                if let mandataire = edl.nomMandataire,
                   mandataire != "" {
                    if let adresse = edl.adresseMandataire,
                       adresse != "",
                       let cp = edl.codePostalMandataire,
                       cp != "",
                       let ville = edl.villeMandataire,
                       ville != "",
                       rempli ([edl.nomProprietaire , edl.nomLocataire, edl.emailLocataire]) == .termine {
                        return .termine
                    }
                } else {
                    // Pas de mandataire, on se base sur les trois valeurs remplies
                    return rempli ([edl.nomProprietaire , edl.nomLocataire, edl.emailLocataire])
                }
                return .enCours
                
            case .planifEDL:
                if edl.etatEDL == .cloture { return .masque }
                // Le booleen de modif à false -> A faire
                // Tous les champs non vide et booleen de modif à true -> Termine
                // Sinon en cours
                if !edl.validationPlanifEDL { return .aFaire }
                if let refEDL = edl.refEDL,
                   refEDL != "",
                   edl.nomExecutantEDL != ""
                { return .termine }
                return .enCours
                
            case .realEDL:
                if edl.etatEDL == .cloture { return .masque }
                //
                // Tous les champs à vide et le booleen de modif à false -> A faire
                // Au moins un champ non vide et booleen de modif a true -> En cours
                // Tous les champs non vide et booleen de modif à true -> Termine
                
                if edl.nClefs + edl.nFournitures + edl.nEntretiens + edl.nCompteurs + edl.nEquipements > 0 {
                    return .enCours
                } else {
                    return .aFaire }
                
                
            case .miseEnPage:
                if edl.etatEDL == .cloture { return .masque }
                // Pas de struct Emetteur ou rien de renseigné -> A faire
                // Au moins un champ non vide -> En cours
                // TRous les champs non vide et tous les booleens de modif à true et le booleen de Logo à true -> Termine
                
                guard let emetteur = EDLsController.emetteurEDL(edl: edl) else { return .aFaire }
                if  let adresse = emetteur.adresseEmetteur,
                    adresse == "",
                    let cp = emetteur.codePostalEmetteur,
                    cp == "",
                    let ville = emetteur.villeEmetteur,
                    ville == "",
                    !emetteur.validationSignature,
                    !emetteur.validationBlocPiedPage,
                    !( emetteur.validationClauseContractuelleEntree && edl.typeEDL == .entree ||
                       emetteur.validationClauseContractuelleSortie && edl.typeEDL == .sortie ) ,
                    !emetteur.logoPresent
                { return .aFaire }
                
                if  let adresse = emetteur.adresseEmetteur,
                    adresse != "",
                    let cp = emetteur.codePostalEmetteur,
                    cp != "",
                    let ville = emetteur.villeEmetteur,
                    ville != "",
                    emetteur.validationSignature,
                    emetteur.libelleSignatureLocataire != "",
                    emetteur.libelleSignatureBailleur != "",
                    
                    ( edl.typeEDL == .entree && emetteur.clauseContractuelleEntree != "" && emetteur.validationClauseContractuelleEntree || edl.typeEDL == .sortie && emetteur.clauseContractuelleSortie != "" && emetteur.validationClauseContractuelleSortie),
                    
                    let piedPage = emetteur.blocPiedPage,
                    piedPage != "",
                    emetteur.validationBlocPiedPage,
                    
                    emetteur.logoPresent
                { return .termine }
                return .enCours
            case .genererDocSigne:
                if edl.etatEDL == .cloture { return .masque }
                
                guard let emetteur = EDLsController.emetteurEDL(edl: edl), emetteur.validationSignature else { return .inactif }
                
                // Pas de mise en page, on ne peut pas générer le PDF
                if  self.statutCalc(actionBien: actionBien, .miseEnPage ) != .termine
                { return.inactif }
                
                var signatureBailleurOk: Bool = false
                var signatureLocataireOk: Bool = false
                var parapheBailleurOk: Bool = false
                var parapheLocataireOk: Bool = false
                
                if let signatureLocataireImage = edl.signatureLocataireImageEDL,
                   existeImage(idImage: signatureLocataireImage.nomImage) {
                    signatureLocataireOk = true
                }
                
                if let signatureBailleurImage = edl.signatureBailleurImageEDL,
                   existeImage(idImage: signatureBailleurImage.nomImage) {
                    signatureBailleurOk = true
                }
                
                if let parapheLocataireImage = edl.parapheLocataireImageEDL,
                   existeImage(idImage: parapheLocataireImage.nomImage) {
                    parapheLocataireOk = true
                }
                
                if let parapheBailleurImage = edl.parapheBailleurImageEDL,
                   existeImage(idImage: parapheBailleurImage.nomImage) {
                    parapheBailleurOk = true
                }
                let  paraphSignRecueilli: Bool = signatureBailleurOk && signatureLocataireOk && parapheBailleurOk && parapheLocataireOk
                
                
                // Les signatures sont pas toutes recueillies -> A faire
                if !paraphSignRecueilli {
                    print ("---- Statut Trace DS : a faire car pas de suignature ou de Parah")
                    return .aFaire }
                
                if edl.dernierFichierSigneNomFichier != nil,
                   let dateDernierFichier = edl.dateDernierFichierSigne {
                    var dateMajEDL: Date
                    
                    if let dateHoro = EDLsController.horodat[edl.idEDL] {
                        dateMajEDL = dateHoro
                    } else if let dateMajEDLSauv = edl.dateDerniereMajEDL {
                        dateMajEDL = dateMajEDLSauv
                    } else {
                        // pas de date de mise à jour connu de EDL , cas d'exception, on masque
                        print ("---- Statut Trace DS : masque car non prévu sur l'horodatage")
                        return .masque
                    }
                    
                    if dateDernierFichier < dateMajEDL {
                        // Mise à jour EDL plus récente que fichier donc doc à regénérer
                        print ("---- Statut Trace DS : a faire car date du fichier est antérieur à la modif ", dateDernierFichier, dateMajEDL)
                        return .aFaire
                    } else {
                        print ("---- Statut Trace DS : termine car date du fichier est après à la modif ", dateDernierFichier, dateMajEDL)
                        return .termine
                    }
                } else {
                    print ("---- Statut Trace DS : a faire nom de fichier a nil, ou pas de date de dernier fichier", edl.dernierFichierSigneNomFichier ?? "Nom de fichier",  edl.dateDernierFichierSigne ?? "Date di fichier ")
                    return .aFaire
                }
                
            case .genererDocVierge:
                if edl.etatEDL == .cloture { return .masque }
                
                guard let emetteur = EDLsController.emetteurEDL(edl: edl), emetteur.validationSignature else { return .inactif }
                
                // Pas de mise en page, on ne peut pas générer le PDF
                if  self.statutCalc(actionBien: actionBien, .miseEnPage ) != .termine
                { return.inactif }
                
                if edl.dernierFichierViergeNomFichier != nil,
                   let dateDernierFichier = edl.dateDernierFichierVierge {
                    var dateMajEDL: Date
                    
                    if let dateHoro = EDLsController.horodat[edl.idEDL] {
                        dateMajEDL = dateHoro
                    } else if let dateMajEDLSauv = edl.dateDerniereMajEDL {
                        dateMajEDL = dateMajEDLSauv
                    } else {
                        // pas de date de mise à jour connu de EDL , cas d'exception, on masque
                        print ("---- Statut Trace DV : masque car non prévu sur l'horodatage")
                        return .masque
                    }
                    
                    if dateDernierFichier < dateMajEDL {
                        // Mise à jour EDL plus récente que fichier donc doc à regénérer
                        print ("---- Statut Trace DV : a faire car date du fichier est antérieur à la modif ", dateDernierFichier, dateMajEDL)
                        return .aFaire
                    } else {
                        print ("---- Statut Trace DV : termine car date du fichier est après à la modif ", dateDernierFichier, dateMajEDL)
                        return .termine
                    }
                } else {
                    print ("---- Statut Trace DV : a faire nom de fichier a nil, ou pas de date de dernier fichier", edl.dernierFichierViergeNomFichier ?? "Nom de fichier",  edl.dateDernierFichierVierge ?? "Date du fichier ")
                    return .aFaire
                }
                
            case .nonApplicable: return .nonApplicable
                
                
                
            case .clotureEDL:
                // Si l'EDL n'est pas cloture et que les signatures sont disponibles, et que l'on a un fichier PDF déjà généra on peut afficher l'action
                if edl.etatEDL != .cloture {
                    let statutGenereDocSigne = actionBien.statutCalc(actionBien: actionBien, .genererDocSigne)
                    let statutGenereDocVierge = actionBien.statutCalc(actionBien: actionBien, .genererDocVierge)
                    
                    // Si pas encore de PDF généré parmi les deux posibles (vierge ou signé), on garde l'action masquée
                    if statutGenereDocSigne == .termine || statutGenereDocVierge == .termine {
                        return .actif
                    } else {
                        return .masque
                    }
                }
                return .masque
                
            case .visuDocDefinitifSigne:
                if edl.etatEDL == .cloture {
                    if edl.dernierFichierSigneNomFichier == nil {
                        return .masque
                    } else {
                        return .actif
                    }
                }
                return .masque
                
            case .visuDocDefinitifVierge:
                if edl.etatEDL == .cloture {
                    if edl.dernierFichierViergeNomFichier == nil {
                        return .masque
                    } else {
                        return .actif
                    }
                }
                return .masque
                
            case  .repriseNouvelEDL , .reactivationEDL :
                if edl.etatEDL == .cloture {
                    return .actif
                } else {
                    return .masque
                }
            case .ajoutSortieEDLEntree:
                if edl.etatEDL == .cloture && edl.typeEDL == .entree {
                    return .actif
                } else {
                    return .masque
                }
            }
        }
        let statutCalc =  statutCalcInterne (actionBien : actionBien, autreTypeAction)
        print ("--- Statut : ", EDLsController.edlFromUUID(idEDL: actionBien.idBien)?.nomBien ?? "", "->", actionBien.typeAction.description, " = ", statutCalc.description, " autre :", autreTypeAction?.description ?? "non" )
        return statutCalc
    }
    
    
    static func == (lhs: ActionBien , rhs: ActionBien ) -> Bool {
        return (
        lhs.id == rhs.id &&
        lhs.idSnapshot == rhs.idSnapshot &&
        lhs.idBien == rhs.idBien &&
        lhs.typeAction == rhs.typeAction &&
        lhs.ordreAction == rhs.ordreAction &&
        lhs.statutAction == rhs.statutAction
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString + String(idSnapshot) + idBien.uuidString + String(typeAction.hashValue) + String(ordreAction) + String(statutAction.hashValue))
    }
}





func rempli (_ listeChamps: [String]) -> StatutAction {
    var n = 0
    for s in listeChamps {
        if s != "" { n += 1 }
    }
    if n == 0 {
        return .aFaire
    } else if n == listeChamps.count {
        return .termine
    } else {
        return .enCours
    }
}



