//
//  Equipement.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation
import UIKit
enum Etat: Codable, CustomStringConvertible, CaseIterable {
        case neuf , bonetat, mauvaisetat, horsservice,  horsnorme, etatdusage, anciennenorme, noncontrole, troudecheville, absent, connexionluminaire, nonapplicable, nondefini
        enum CodingKeys: CodingKey {
            case neuf
            case bonetat
            case mauvaisetat
            case horsservice
            case anciennenorme
            case horsnorme
            case etatdusage
            case noncontrole
            case troudecheville
            case absent
            case connexionluminaire
            case nonapplicable
            case nondefini
        }
        var description: String {
            switch self {
            case .neuf: return "Neuf"
            case .bonetat: return "Bon état"
            case .mauvaisetat:return  "Mauvais état"
            case .horsservice: return "Hors service"
            case .anciennenorme: return "Ancienne norme"
            case .horsnorme: return "Hors norme"
            case .etatdusage: return "Etat d'usage"
            case .noncontrole: return "Non contrôlé"
            case .troudecheville: return "Trou cheville"
            case .absent: return "Absent"
            case .connexionluminaire: return "Connexion luminaire"
            case .nonapplicable: return "Non applicable"
            case .nondefini: return ""
                }
            }
        
}

enum Proprete: Codable, CustomStringConvertible, CaseIterable {
        case tresbonne, correcte , moyenne,  sale, nonapplicable, nondefini
        enum CodingKeys: CodingKey {
            case tresbonne, correcte , sale, moyenne,  nonapplicable, nondefini
        }
        var description: String {
            switch self {
            case .tresbonne: return "Très propre"
            case .correcte: return "Propreté correcte"
            case .sale: return  "Sale"
            case .moyenne: return "Propreté moyenne"
            case .nonapplicable: return "Non applicable"
            case .nondefini: return ""
                }
            }
        
}

enum Fonctionnel: Codable, CustomStringConvertible, CaseIterable {
        case marche, nonverifie, nemarchepas , nonapplicable, nondefini
        enum CodingKeys: CodingKey {
            case marche,  nonverifie, nemarchepas , nonapplicable, nondefini
        }
        var description: String {
            switch self {
            case .marche: return "Fonctionnel"
            case .nonverifie: return "Non vérifié"
            case .nemarchepas: return "Ne marche pas"
            case .nonapplicable: return "Non applicable"
            case .nondefini: return ""
                }
            }
        
}

struct Equipement: Equatable, Codable {
    
    
    var descriptionTableau = [
        "equipement"        : "Description",
        "etat"              : "Usage",
        "fonctionnel"       : "Fonctionne",
        "proprete"          : "Propreté",
        "observations"      : "Observations"
        ]
  
    
    var idEquipement: UUID = UUID()
    var idCategorie: UUID
    var idSnapshot: Int = 0
    
    var equipement: String = ""
    var nExemplaire: Int?
    var etat: Etat = .nondefini
    var fonctionnel: Fonctionnel = .nondefini
    var proprete: Proprete = .nondefini
    var observations: String?
    var images: [ImageEDL]?
    
    // Pour un EDL de Sortie
    var observationsSortie: String?
    var nExemplaireSortie: Int?
    var etatSortie: Etat?
    var fonctionnelSortie: Fonctionnel?
    var propreteSortie: Proprete?
    
    static func == (lhs: Equipement, rhs: Equipement) -> Bool {
        return (
        lhs.idEquipement == rhs.idEquipement &&
        lhs.equipement == rhs.equipement &&
        lhs.idSnapshot == rhs.idSnapshot &&
        lhs.equipement == rhs.equipement &&
        lhs.nExemplaire == rhs.nExemplaire &&
        lhs.etat == rhs.etat &&
        lhs.fonctionnel == rhs.fonctionnel &&
        lhs.proprete == rhs.proprete &&
        lhs.observations == rhs.observations &&
        lhs.observationsSortie == rhs.observationsSortie &&
        lhs.nExemplaireSortie == rhs.nExemplaireSortie &&
        lhs.etatSortie == rhs.etatSortie &&
        lhs.fonctionnelSortie == rhs.fonctionnelSortie &&
        lhs.propreteSortie == rhs.propreteSortie )
       
        
    }
}


let paragraphStyle = NSMutableParagraphStyle()

let backgroundSectionColor = UIColor.colorFromHex("#a6d14b")
let backgroundTextColor = UIColor.colorFromHex ("#C5F85A")
let textTextColor = UIColor.gray
let vertEtatColor = UIColor.colorFromHex ("#00b504")
let jauneEtatColor = UIColor.colorFromHex ("#eb7f00")
let rougeEtatColor = UIColor.red
let grisEtatColor = UIColor.gray

let vertEtatColorHTML  = "etatVert" // #00b504"
let jauneEtatColorHTML = "etatJaune" // #eb7f00"
let rougeEtatColorHTML = "etatRouge" // "red"
let grisEtatColorHTML  = "etatGris" // "gray"


let placeHolderObservations = "Enregistrer ici des observations particulières : actions prévues, remarques..."


let vertEtat = UIColor.colorFromHex ("#a6d14b")
let vertProprete = UIColor.colorFromHex ("#eb7f00")
let vertFonctionnel = UIColor.colorFromHex ("#D8EDB6")



let attributVert = [ NSAttributedString.Key.foregroundColor: vertEtatColor,
                   //  NSAttributedString.Key.backgroundColor: UIColor.gray,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
let attributRouge = [NSAttributedString.Key.foregroundColor: rougeEtatColor,
                   //  NSAttributedString.Key.backgroundColor: UIColor.gray,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
let attributJaune = [NSAttributedString.Key.foregroundColor: jauneEtatColor,
                   //  NSAttributedString.Key.backgroundColor: UIColor.gray,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]


func attributesEtat (etat: Etat) -> NSAttributedString {
    
    paragraphStyle.alignment = .center
    
    switch etat {
    case .neuf, .bonetat:
        return NSAttributedString(string: etat.description, attributes: attributVert)
    case .mauvaisetat, .horsservice, .anciennenorme, .horsnorme:
        return NSAttributedString(string: etat.description, attributes: attributRouge)
    default:
        return NSAttributedString(string: etat.description, attributes: attributJaune)
    }
}


let nomPictoEtat = "eye"
let pictoEtatVert = UIImage(systemName: nomPictoEtat)?.withTintColor(vertEtatColor, renderingMode: .alwaysOriginal)
let pictoEtatRouge = UIImage(systemName: nomPictoEtat)?.withTintColor(rougeEtatColor, renderingMode: .alwaysOriginal)
let pictoEtatOrange = UIImage(systemName: nomPictoEtat)?.withTintColor(jauneEtatColor, renderingMode: .alwaysOriginal)
let pictoEtatGris = UIImage(systemName: nomPictoEtat)?.withTintColor(grisEtatColor, renderingMode: .alwaysOriginal)


func pictoEtat (etat: Etat) -> UIImage {
    switch etat {
    case .neuf, .bonetat:
        return pictoEtatVert!
    case .mauvaisetat, .horsservice, .horsnorme:
        return pictoEtatRouge!
    case .nondefini, .nonapplicable:
        return pictoEtatGris!
    default:
        return pictoEtatOrange!
    }
    
}

func attributesProprete (proprete: Proprete) -> NSAttributedString {
    
    paragraphStyle.alignment = .center
    
    switch proprete {
    case .tresbonne, .correcte:
        return NSAttributedString(string: proprete.description, attributes: attributVert)
    case .sale:
        return NSAttributedString(string: proprete.description, attributes: attributRouge)
    default:
        return NSAttributedString(string: proprete.description, attributes: attributJaune)
    }
}
/*
var nomPictoProprete: String  {
    if #available(iOS 16.0, *) {
        return "shower.handheld.fill"
    } else {
        return "photo"
    }
    
}
 */
// Import manuel du picto pour compenser son abscence en iOS 14
let pictoPropreteVert = UIImage(named: "shower.handheld.fill")?.withTintColor(vertEtatColor, renderingMode: .alwaysOriginal)
// let pictoPropreteVert = UIImage(systemName:nomPictoProprete)?.withTintColor(vertEtatColor, renderingMode: .alwaysOriginal)
let pictoPropreteRouge = UIImage(named: "shower.handheld.fill")?.withTintColor(rougeEtatColor, renderingMode: .alwaysOriginal)
let pictoPropreteOrange = UIImage(named: "shower.handheld.fill")?.withTintColor(jauneEtatColor, renderingMode: .alwaysOriginal)
let pictoPropreteGris = UIImage(named: "shower.handheld.fill")?.withTintColor(grisEtatColor, renderingMode: .alwaysOriginal)



func pictoProprete (proprete: Proprete) -> UIImage {
    switch proprete {
    case .tresbonne, .correcte:
        return pictoPropreteVert!
    case .sale:
        return pictoPropreteRouge!
    case .nondefini, .nonapplicable:
        return pictoPropreteGris!
    default:
        return pictoPropreteOrange!
        
    }
}


 
    

func attributesFonctionnel (fonctionnel: Fonctionnel) -> NSAttributedString {
   
    paragraphStyle.alignment = .center
    
    
    switch fonctionnel {
    case .marche:
        return NSAttributedString(string: fonctionnel.description, attributes: attributVert)
    case .nemarchepas:
        return NSAttributedString(string: fonctionnel.description, attributes: attributRouge)
    case .nonverifie:
        return NSAttributedString(string: fonctionnel.description, attributes: attributJaune)
        
    default:
        return NSAttributedString(string: fonctionnel.description, attributes: attributJaune)
    }
}

let nomPictoFonctionnel = "powerplug.fill"
let pictoFonctionnelVert = UIImage(systemName: nomPictoFonctionnel)?.withTintColor(vertEtatColor, renderingMode: .alwaysOriginal)
let pictoFonctionnelRouge = UIImage(systemName: nomPictoFonctionnel)?.withTintColor(rougeEtatColor, renderingMode: .alwaysOriginal)
let pictoFonctionnelOrange = UIImage(systemName: nomPictoFonctionnel)?.withTintColor(jauneEtatColor, renderingMode: .alwaysOriginal)
let pictoFonctionnelGris = UIImage(systemName: nomPictoFonctionnel)?.withTintColor(grisEtatColor, renderingMode: .alwaysOriginal)

   
func pictoFonctionnel (fonctionnel: Fonctionnel) -> UIImage {
    switch fonctionnel {
    case .marche:
        return pictoFonctionnelVert!
    case .nemarchepas:
        return pictoFonctionnelRouge!
    case .nondefini, .nonapplicable:
        return pictoFonctionnelGris!
    case .nonverifie:
        return pictoFonctionnelOrange!
    }
        
    }

enum Abreviation {
    case etat (etat: Etat)
    case proprete (proprete: Proprete)
    case fonctionnel (fonctionnel: Fonctionnel)
    func abreviation () -> [String : String] {
        switch self {
        case .etat(let etat):
            switch etat {
            case .absent: return ["AB":jauneEtatColorHTML]
            case .anciennenorme: return ["ANO":jauneEtatColorHTML]
            case .bonetat: return ["BE":vertEtatColorHTML]
            case .connexionluminaire : return ["CLU":jauneEtatColorHTML]
            case .etatdusage: return ["EU":jauneEtatColorHTML]
            case .horsnorme : return ["HN":rougeEtatColorHTML]
            case .horsservice: return ["HS":rougeEtatColorHTML]
            case .mauvaisetat: return ["ME":jauneEtatColorHTML]
            case .neuf : return ["NE":vertEtatColorHTML]
            case .nonapplicable: return ["":""]
       //     case .nonapplicable: return ["NA":grisEtatColorHTML]
            case .noncontrole: return ["NC":grisEtatColorHTML]
            case .nondefini : return ["":grisEtatColorHTML]
            case .troudecheville: return ["TDC":jauneEtatColorHTML]
            }
        case .fonctionnel(let fonctionnel):
            switch fonctionnel {
            case .nondefini: return ["":grisEtatColorHTML]
            case .nonapplicable: return ["":""]
   //         case .nonapplicable: return ["NA":grisEtatColorHTML]
            case .marche: return ["MAR":vertEtatColorHTML]
            case .nemarchepas: return ["NMAR":rougeEtatColorHTML]
            case .nonverifie: return ["NVER":jauneEtatColorHTML]
            }
        case .proprete(let proprete):
            switch proprete {
  //          case .nonapplicable: return ["NA":grisEtatColorHTML]
            case .nonapplicable: return ["":""]
            case .nondefini: return ["":grisEtatColorHTML]
            case .correcte: return ["COR":vertEtatColorHTML]
            case .moyenne: return ["MOY":jauneEtatColorHTML]
            case .sale: return ["SAL":rougeEtatColorHTML]
            case .tresbonne: return ["TB":vertEtatColorHTML]
            }
            }
    }
    
    
}

let dicoLegende = [
    // Vert
    Abreviation.etat(etat: .neuf) ,
    Abreviation.etat(etat: .bonetat),
    Abreviation.proprete(proprete: .tresbonne),
    Abreviation.proprete(proprete: .correcte),
    Abreviation.fonctionnel(fonctionnel: .marche),

    // Jaune
    Abreviation.etat(etat: .etatdusage),
    Abreviation.etat(etat: .absent),
    Abreviation.etat(etat: .troudecheville),
    Abreviation.etat(etat: .connexionluminaire),
    Abreviation.proprete(proprete: .moyenne),
    Abreviation.etat(etat: .anciennenorme),
    Abreviation.etat(etat: .mauvaisetat),
    Abreviation.fonctionnel(fonctionnel: .nonverifie),
    // Rouge
    Abreviation.etat(etat: .horsservice),
    Abreviation.etat(etat: .horsnorme),
    Abreviation.proprete(proprete: .sale),
    Abreviation.fonctionnel(fonctionnel: .nemarchepas),
    // Gris
    Abreviation.etat(etat: .noncontrole)
 //   Abreviation.etat(etat: .nonapplicable)
 
 ]
 
 
