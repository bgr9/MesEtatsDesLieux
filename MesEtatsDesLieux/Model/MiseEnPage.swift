//
//  Action.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 02/02/2023.
//

import Foundation

// MARK: - Temporaire

enum ItemMiseEnPage: Codable {
  case
        logo,
        adresse,
        clauseContractuelleEntree,
        clauseContractuelleSortie,
        signatures,
        piedPage,
        indefini
    
    
    
    var messageInvite: String {
        switch self {
        case .logo: return "Choisissez un logo"
        case .adresse: return "Definissez une adresse"
        case .clauseContractuelleEntree: return "Définissez la clause contractuelle pour les Etats des Lieux d'entrée"
        case .clauseContractuelleSortie: return "Définissez la clause contractuelle pour les Etats des Lieux de sortie"
        case .signatures: return "Renseigner la mention de signature"
        case .piedPage: return "Définissez un pied de page"
        case .indefini: return ""
            
        }
    }
    var messageIncomplet: String {
        switch self {
        case .logo: return ""
        case .adresse: return "Completer l'adresse"
        case .clauseContractuelleEntree: return "Vérifier et valider la clause contractuelle d'entrée"
        case .clauseContractuelleSortie: return "Vérifier et valider la clause contractuelle de sortie"
        case .signatures: return "Signature Bailleur et Locataire"
        case .piedPage: return "Pied de page saisie mais "
        case .indefini: return ""
        }
    }
    
    var indicationSaisie: String {
        switch self {
        case .logo:
          return ""
        case .adresse:
          return "Saisissez l'adresse qui apparaitra eu haut à droite du constat. Elle représente l'adresse postale de l'émetteur du constat."
        case .clauseContractuelleEntree:
          return "La clause contractuelle pour les états des lieux d'ENTREE est présentée juste avant les mentions de signature du constat. Vous pouvez modifier l'exemple qui est présenté ou le changer comme vous le souhaitez. Vous devez valider la définition de cette clause pour qu'elle soit intégrée au constat."
        case .clauseContractuelleSortie:
          return "La clause contractuelle pour les états des lieux de SORTIE est présentée juste avant les mentions de signature du constat. Vous pouvez modifier l'exemple qui est présenté ou le changer comme vous le souhaitez. Vous devez valider la définition de cette clause pour qu'elle soit intégrée au constat."
        case .signatures:
          return "Ajustez les mentions présentant la signature du BAILLEUR ou de son représentant et la signature du LOCATAIRE comme vous le souhaitez."
        
        case .piedPage:
          return "Renseignez la mention du pied de page du constat. Vous pouvez l'ajuster comme vous le souhaitez ou le laisser vide."
        case .indefini:
            return ""
        }
    }
}

let messageInviteNouvelEmetteur = "Personnalisez la mise en page du constat en précisant les zones indiquées ci-dessous"
let messageInviteModificationEmetteur = "Complétez les informations de mise en page du constat d'état des lieux"
let messageInviteCorpsConstat = "Texte du constat qui sera établi à partir de l'ensemble des données recueillies lors de l'état des lieux"

let adresseACompleter = "Adresse à compléter"
let logoACompleter = "Personnaliser le logo"

let clauseContractuelleEntreeLibelle = "Clause contractuelle pour les états des lieux d'entrée"
let clauseContractuelleEntreeValidee = "Clause contractuelle pour les entrées validée"
let clauseContractuelleEntreeAValider = "Clause contractuelle pour les entrées à completer/valider"

let clauseContractuelleSortieLibelle = "Clause contractuelle pour les états des lieux de sortie"
let clauseContractuelleSortieValidee = "Clause contractuelle pour les sorties validée"
let clauseContractuelleSortieAValider = "Clause contractuelle pour les sorties à completer/valider"
