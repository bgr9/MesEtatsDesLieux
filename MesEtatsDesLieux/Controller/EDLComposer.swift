//
//  edlComposer.swift
//  MesEtatsDesLieux
//
//  Created by BD2B on 15/01/2023.
//

import Foundation

import UIKit


    
class EDLComposer: NSObject, EntetePiedPageCustomPrintPageRendererDelegate {
    
    
    // Répertoire de stockage des fichiers utilisés pour le rendu HTML
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let nomDocumentMaitre = "documentEDL"
    
    var edl: EDL
    
    var isAvecSignature: Bool
    var isEDLSortie: Bool
    
    
    var documentEDLpdfURL: URL?
    var documentEDLHTMLFusion: URL?
    var indexRenvoi = 1
    
    var delegate: CustomPrintPageRenderer?
    
    
    init(edl: EDL, isAvecSignature: Bool) {
        
        self.edl = edl
        self.isAvecSignature = isAvecSignature
        self.isEDLSortie = edl.isEDLSortieApresEntree
        super.init()
        
    }
    
    
    var debImageHTML = ""
    var ligneImageHTML = ""
    var finImageHTML = ""
    var imageHTML = ""
    
    var debHTMLCompteur = ""
    var ligneHTMLCompteur = ""
    var finHTMLCompteur = ""
    
    var debHTMLCompteurSortie = ""
    var ligneHTMLCompteurSortie = ""
    var finHTMLCompteurSortie = ""
    
    var debHTMLClef = ""
    var ligneHTMLClef = ""
    var finHTMLClef = ""
    
    var debHTMLClefSortie = ""
    var ligneHTMLClefSortie = ""
    var finHTMLClefSortie = ""
    
    var debHTMLEntretien = ""
    var ligneHTMLEntretien = ""
    var finHTMLEntretien = ""
    
    var debHTMLEntretienSortie = ""
    var ligneHTMLEntretienSortie = ""
    var finHTMLEntretienSortie = ""
    
    var debHTMLFourniture = ""
    var ligneHTMLFourniture = ""
    var finHTMLFourniture = ""
    
    var debHTMLFournitureSortie = ""
    var ligneHTMLFournitureSortie = ""
    var finHTMLFournitureSortie = ""
    
    var debHTMLPiece = ""
    var ligneHTMLPiece = ""
    var finHTMLPiece = ""
    
    var debHTMLPieceSortie = ""
    var ligneHTMLPieceSortie = ""
    var finHTMLPieceSortie = ""
    
    var debHTMLLegende = ""
    var ligneHTMLLegende = ""
    var finHTMLLegende = ""
    
    var piedPageCouranteHTML = ""
    var piedPageDerniereHTML = ""
    var entetePageHTML = ""
    
    var referenceEDLEntreeHTML = ""
    
    func chargeFichiersTemplateHTML() {
        
        // Fichier template image
        
        let documentTemplateDebImage   = documentsDirectory.appendingPathComponent("imagesEDL_deb").appendingPathExtension("html")
        let documentTemplateLigneImage = documentsDirectory.appendingPathComponent("imagesEDL_ligne").appendingPathExtension("html")
        let documentTemplateFinImage   = documentsDirectory.appendingPathComponent("imagesEDL_fin").appendingPathExtension("html")
        let documentTemplateImage = documentsDirectory.appendingPathComponent("imagesEDL_cellule").appendingPathExtension("html")
        
        let documentTemplateDebCompteur   = documentsDirectory.appendingPathComponent(  "Compteurs_deb").appendingPathExtension("html")
        let documentTemplateLigneCompteur = documentsDirectory.appendingPathComponent("Compteurs_ligne").appendingPathExtension("html")
        let documentTemplateFinCompteur   = documentsDirectory.appendingPathComponent(  "Compteurs_fin").appendingPathExtension("html")
        
        let documentTemplateDebCompteurSortie   = documentsDirectory.appendingPathComponent(  "Compteurs_deb_sortie").appendingPathExtension("html")
        let documentTemplateLigneCompteurSortie = documentsDirectory.appendingPathComponent("Compteurs_ligne_sortie").appendingPathExtension("html")
        let documentTemplateFinCompteurSortie   = documentsDirectory.appendingPathComponent(  "Compteurs_fin_sortie").appendingPathExtension("html")
        
        let documentTemplateDebClef   = documentsDirectory.appendingPathComponent(  "Clefs_deb").appendingPathExtension("html")
        let documentTemplateLigneClef = documentsDirectory.appendingPathComponent("Clefs_ligne").appendingPathExtension("html")
        let documentTemplateFinClef   = documentsDirectory.appendingPathComponent(  "Clefs_fin").appendingPathExtension("html")
        
        let documentTemplateDebClefSortie   = documentsDirectory.appendingPathComponent(  "Clefs_deb_sortie").appendingPathExtension("html")
        let documentTemplateLigneClefSortie = documentsDirectory.appendingPathComponent("Clefs_ligne_sortie").appendingPathExtension("html")
        let documentTemplateFinClefSortie   = documentsDirectory.appendingPathComponent(  "Clefs_fin_sortie").appendingPathExtension("html")
        
        let documentTemplateDebEntretien   = documentsDirectory.appendingPathComponent(  "Entretiens_deb").appendingPathExtension("html")
        let documentTemplateLigneEntretien = documentsDirectory.appendingPathComponent("Entretiens_ligne").appendingPathExtension("html")
        let documentTemplateFinEntretien   = documentsDirectory.appendingPathComponent(  "Entretiens_fin").appendingPathExtension("html")
        
        let documentTemplateDebEntretienSortie   = documentsDirectory.appendingPathComponent(  "Entretiens_deb_sortie").appendingPathExtension("html")
        let documentTemplateLigneEntretienSortie = documentsDirectory.appendingPathComponent("Entretiens_ligne_sortie").appendingPathExtension("html")
        let documentTemplateFinEntretienSortie   = documentsDirectory.appendingPathComponent(  "Entretiens_fin_sortie").appendingPathExtension("html")
        
        let documentTemplateDebFourniture   = documentsDirectory.appendingPathComponent(  "Fournitures_deb").appendingPathExtension("html")
        let documentTemplateLigneFourniture = documentsDirectory.appendingPathComponent("Fournitures_ligne").appendingPathExtension("html")
        let documentTemplateFinFourniture   = documentsDirectory.appendingPathComponent(  "Fournitures_fin").appendingPathExtension("html")

        let documentTemplateDebFournitureSortie   = documentsDirectory.appendingPathComponent(  "Fournitures_deb_sortie").appendingPathExtension("html")
        let documentTemplateLigneFournitureSortie = documentsDirectory.appendingPathComponent("Fournitures_ligne_sortie").appendingPathExtension("html")
        let documentTemplateFinFournitureSortie   = documentsDirectory.appendingPathComponent(  "Fournitures_fin_sortie").appendingPathExtension("html")
        
        let documentTemplateDebPiece   = documentsDirectory.appendingPathComponent(  "Pieces_deb").appendingPathExtension("html")
        let documentTemplateLignePiece = documentsDirectory.appendingPathComponent("Pieces_ligne").appendingPathExtension("html")
        let documentTemplateFinPiece   = documentsDirectory.appendingPathComponent(  "Pieces_fin").appendingPathExtension("html")

        let documentTemplateDebPieceSortie   = documentsDirectory.appendingPathComponent(  "Pieces_deb_sortie").appendingPathExtension("html")
        let documentTemplateLignePieceSortie = documentsDirectory.appendingPathComponent("Pieces_ligne_sortie").appendingPathExtension("html")
        let documentTemplateFinPieceSortie   = documentsDirectory.appendingPathComponent(  "Pieces_fin_sortie").appendingPathExtension("html")
        
        let documentTemplateDebLegende   = documentsDirectory.appendingPathComponent(  "Legende_deb").appendingPathExtension("html")
        let documentTemplateLigneLegende = documentsDirectory.appendingPathComponent("Legende_ligne").appendingPathExtension("html")
        let documentTemplateFinLegende   = documentsDirectory.appendingPathComponent(  "Legende_fin").appendingPathExtension("html")
        
        let documentTemplateEntetePage   = documentsDirectory.appendingPathComponent(  "EntetePage").appendingPathExtension("html")
        
        let documentTemplatePiedPageCourante   = documentsDirectory.appendingPathComponent(  "PiedPageCourante").appendingPathExtension("html")
        let documentTemplatePiedPageDerniere   = documentsDirectory.appendingPathComponent(  "PiedPageDerniere").appendingPathExtension("html")
        
        let documentTemplateReferenceEDLEntree   = documentsDirectory.appendingPathComponent(  "ReferenceEDLEntree").appendingPathExtension("html")
        
        do {
           debImageHTML = try String(contentsOf: documentTemplateDebImage)
           ligneImageHTML = try String(contentsOf: documentTemplateLigneImage)
           finImageHTML = try String(contentsOf: documentTemplateFinImage)
           imageHTML = try String(contentsOf: documentTemplateImage)
            
            debHTMLCompteur = try String(contentsOf: documentTemplateDebCompteur)
            ligneHTMLCompteur = try String(contentsOf: documentTemplateLigneCompteur)
            finHTMLCompteur = try String(contentsOf: documentTemplateFinCompteur)
            
            debHTMLCompteurSortie = try String(contentsOf: documentTemplateDebCompteurSortie)
            ligneHTMLCompteurSortie = try String(contentsOf: documentTemplateLigneCompteurSortie)
            finHTMLCompteurSortie = try String(contentsOf: documentTemplateFinCompteurSortie)
            
            debHTMLClef = try String(contentsOf: documentTemplateDebClef)
            ligneHTMLClef = try String(contentsOf: documentTemplateLigneClef)
            finHTMLClef = try String(contentsOf: documentTemplateFinClef)
            
            debHTMLClefSortie = try String(contentsOf: documentTemplateDebClefSortie)
            ligneHTMLClefSortie = try String(contentsOf: documentTemplateLigneClefSortie)
            finHTMLClefSortie = try String(contentsOf: documentTemplateFinClefSortie)
            
            debHTMLEntretien = try String(contentsOf: documentTemplateDebEntretien)
            ligneHTMLEntretien = try String(contentsOf: documentTemplateLigneEntretien)
            finHTMLEntretien = try String(contentsOf: documentTemplateFinEntretien)
            
            debHTMLEntretienSortie = try String(contentsOf: documentTemplateDebEntretienSortie)
            ligneHTMLEntretienSortie = try String(contentsOf: documentTemplateLigneEntretienSortie)
            finHTMLEntretienSortie = try String(contentsOf: documentTemplateFinEntretienSortie)
            
            debHTMLFourniture = try String(contentsOf: documentTemplateDebFourniture)
            ligneHTMLFourniture = try String(contentsOf: documentTemplateLigneFourniture)
            finHTMLFourniture = try String(contentsOf: documentTemplateFinFourniture)
            
            debHTMLFournitureSortie = try String(contentsOf: documentTemplateDebFournitureSortie)
            ligneHTMLFournitureSortie = try String(contentsOf: documentTemplateLigneFournitureSortie)
            finHTMLFournitureSortie = try String(contentsOf: documentTemplateFinFournitureSortie)
            
            debHTMLPiece = try String(contentsOf: documentTemplateDebPiece)
            ligneHTMLPiece = try String(contentsOf: documentTemplateLignePiece)
            finHTMLPiece = try String(contentsOf: documentTemplateFinPiece)
            
            debHTMLPieceSortie = try String(contentsOf: documentTemplateDebPieceSortie)
            ligneHTMLPieceSortie = try String(contentsOf: documentTemplateLignePieceSortie)
            finHTMLPieceSortie = try String(contentsOf: documentTemplateFinPieceSortie)
            
            debHTMLLegende = try String(contentsOf: documentTemplateDebLegende)
            ligneHTMLLegende = try String(contentsOf: documentTemplateLigneLegende)
            finHTMLLegende = try String(contentsOf: documentTemplateFinLegende)
            
            entetePageHTML = try String(contentsOf: documentTemplateEntetePage)
            piedPageCouranteHTML = try String(contentsOf: documentTemplatePiedPageCourante)
            piedPageDerniereHTML = try String(contentsOf: documentTemplatePiedPageDerniere)
            
            referenceEDLEntreeHTML = try String(contentsOf: documentTemplateReferenceEDLEntree)
            
        } catch {
            print (error.localizedDescription)
            print("Erreur lecture fichier HTML")}
        
    }
    
    
    
    func renderEDL() -> String! {
 //       let documentEDLHTMLTemplate = Bundle.main.path(forResource: nomDocumentMaitre, ofType: "html")
        let documentEDLHTMLTemplate = documentsDirectory.appendingPathComponent(nomDocumentMaitre).appendingPathExtension("html")
        documentEDLHTMLFusion = documentsDirectory.appendingPathComponent(nomDocumentMaitre + "Fusion").appendingPathExtension("html")
        
        chargeFichiersTemplateHTML()
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOf: documentEDLHTMLTemplate, encoding: .utf8)
            fusionEDL(&HTMLContent)
                do {
                    try HTMLContent.write(to: documentEDLHTMLFusion!, atomically: true, encoding: .utf8)
                }
                catch { print ("Ecriture fichier fusionné impossible")
                }
                return documentEDLHTMLFusion!.absoluteString
            }
            catch {
                print("Impossible d'accéder aux modèles HTML")
            }
        return nil
    }
    
    // MARK: - Fonctions de fusion EDL
    
    fileprivate func fusionEDL(_ HTMLContent: inout String) {
        
        
        if let emetteur = EDLsController.emetteurEDL(edl: edl) {
            let nomEmetteur = emetteur.nomEmetteur
            let adresseEmetteur = emetteur.adresseEmetteur ?? ""
            let codePostalEmetteur = emetteur.codePostalEmetteur ?? ""
            let villeEmetteur = emetteur.villeEmetteur ?? ""
            let clauseJuridique = isEDLSortie ?  emetteur.clauseContractuelleSortie : emetteur.clauseContractuelleEntree
            let libelleSignatureLocataire = emetteur.libelleSignatureLocataire
            let libelleSignatureBailleur = emetteur.libelleSignatureBailleur
            let nomFichierLogo = EmetteurController.nomFichierLogo(idEmetteur: emetteur.idEmetteur)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_nomEmetteur#", with: nomEmetteur)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_logoEmetteur#", with: nomFichierLogo)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_adresseEmetteur#", with: adresseEmetteur)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_codePostalEmetteur#", with: codePostalEmetteur )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_villeEmetteur#", with: villeEmetteur)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_clauseJuridique#", with: clauseJuridique)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_libelleSignatureLocataire#", with: libelleSignatureLocataire)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_libelleSignatureBailleur#", with: libelleSignatureBailleur)
            
        }
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_typeEDL#", with: edl.typeEDL.libelleTypeEdl)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_refEDL#", with: edl.refEDL ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateEDL#", with: dateDayFormatter.string(from: edl.dateEDL))
        
        var HTMLreferenceEDLEntree = referenceEDLEntreeHTML
        var presenceReference: Bool = false
        
        // TODO: ajouter la saisie de la référence quand on fait un EDL de sortie sans avoir l'EDL d'entrée dans l'appli
        /* <h2>Etabli à partir de l'état des lieux d'entrée #ITEM_Num_EDL_Entree##ITEM_Date_EDL_Entree#</h2>*/
        if let refEDLEntree = edl.refEDLEntree {
            HTMLreferenceEDLEntree = HTMLreferenceEDLEntree.replacingOccurrences(of: "#ITEM_Num_EDL_Entree#", with: "n° " + refEDLEntree + " ")
            presenceReference = true
        } else {
            HTMLreferenceEDLEntree = HTMLreferenceEDLEntree.replacingOccurrences(of: "#ITEM_Num_EDL_Entree#", with: "")
        }
        if let dateEDLEntree = edl.dateEDLEntree {
            HTMLreferenceEDLEntree = HTMLreferenceEDLEntree.replacingOccurrences(of: "#ITEM_Date_EDL_Entree#", with:  "réalisé le " + dateDayFormatter.string(from: dateEDLEntree))
            presenceReference = true
        } else {
            HTMLreferenceEDLEntree = HTMLreferenceEDLEntree.replacingOccurrences(of: "#ITEM_Date_EDL_Entree#", with:  "")
        }
        
        if presenceReference {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_Reference_EDL_Entree#", with: HTMLreferenceEDLEntree)
        } else {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_Reference_EDL_Entree#", with: "")
        }
        
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_nomProprietaire#", with: edl.nomProprietaire)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_nomExecutantEDL#", with: edl.nomExecutantEDL)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_nomMandataire#", with: edl.nomMandataire ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_adresseMandataire#", with: edl.adresseMandataire ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_codePostalMandataire#", with: edl.codePostalMandataire ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_villeMandataire#", with: edl.villeMandataire ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_nomLocataire#", with: edl.nomLocataire)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_emailLocataire#", with: edl.emailLocataire)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_adresseBien#", with: edl.adresseBien)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_codePostalBien#", with: edl.codePostalBien)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_villeBien#", with: edl.villeBien)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_typeBien#", with: edl.typeBien ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_localisationBien#", with: edl.localisationBien)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_adresseBien#", with: edl.adresseBien)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_codePostalBien#", with: edl.codePostalBien)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_villeBien#", with: edl.villeBien)
        
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_compteurs#", with: fusionCompteur())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_entretiens#", with: fusionEntretien())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_clefs#", with: fusionClef())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_fournitures#", with: fusionFournitureEquipement(equipements: FournitureController.shared.fournitures, nomRubrique: "", nomFic: "Fournitures"))
        
        var HTMLContentPiece: String = ""
        for categorie in CategorieController.shared.categories.sorted(by: { $0.ordreAffichage ?? 9999 < $1.ordreAffichage ?? 9999 } ) {
            if categorie.typeElement == .equipement {
                let equipementsPiece = EquipementController.shared.equipements.filter({$0.idCategorie == categorie.idCategorie})
                if equipementsPiece.count > 0 {
                    
                    HTMLContentPiece += fusionFournitureEquipement(equipements: equipementsPiece, nomRubrique: categorie.nomCategorie, nomFic: "Pieces")
                }
            }
        }
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_pieces#", with: HTMLContentPiece)
        
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_legende#", with: fusionLegende())
        if isAvecSignature {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_signatureLocataireImageEDL#", with: edl.signatureLocataireImageEDL?.nomImage ??   "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateSignatureLocataire#",     with: edl.signatureLocataireImageEDL?.legendText ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateParapheLocataire#",       with: edl.parapheLocataireImageEDL?.legendText ??   "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_signatureBailleurImageEDL#",  with: edl.signatureBailleurImageEDL?.nomImage ??    "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateSignatureBailleur#",      with: edl.signatureBailleurImageEDL?.legendText ??  "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateParapheBailleur#",        with: edl.parapheBailleurImageEDL?.legendText ??    "")
        } else {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_signatureLocataireImageEDL#", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateSignatureLocataire#",     with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateParapheLocataire#",       with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_signatureBailleurImageEDL#",  with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateSignatureBailleur#",      with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateParapheBailleur#",        with: "")
        }
        
       
        
        let mentionDocumentGenereLe = "Document généré le \(dateFormatter.string(from: Date()))"
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_documentGenereLe#", with: mentionDocumentGenereLe)
        
    
        
        
    }
    
    // MARK: - Fonctions de fusion des différents composants
    
    fileprivate func fusionCompteur() -> String {
        
        if  CompteurController.shared.compteurs.count == 0 { return "" }
        
        var contentHTML: String = ""
 
        // Toutes les lignes de description en HTML
        var allItems = ""
        // Toutes les cellules (image + legende) de l'ensemble des equipements organisé en tableau de celulle (image + legende)
        var allTabItemsImage : [String] = []
        
        
        for compteur in CompteurController.shared.compteurs {
            // On prepare pour l'item d'observations un renvoi vers les photos
            // On complete le tableau des celulles d'image
            var commentaireObservations : String = ""
            var commentaireObservationsSortie : String = ""
            if let imagesEDL = compteur.images {
                // Appel du formatage de commentaire avec l'indicateur de EDLSortie à false
                commentaireObservations = fusionImage(imagesEDL, &allTabItemsImage, false)
                if isEDLSortie {
                    // Appel du formatage de commentaire avec l'indicateur de EDLSortie ) True
                    commentaireObservationsSortie = fusionImage(imagesEDL, &allTabItemsImage, true)
                }
            }
            
            var ajoutRenvoiIndex: String = ""
            var ajoutRenvoiMotif: String = ""
            var ajoutRenvoiDescriptif: String = ""
            
            if commentaireObservations != "" {
                
                if compteur.indexCompteur != nil {
                    ajoutRenvoiIndex += ( " " + commentaireObservations)
                } else if compteur.motifNonReleve != nil {
                    ajoutRenvoiMotif += ( " " + commentaireObservations)
                } else {
                    ajoutRenvoiDescriptif += (" " + commentaireObservations)
                }
            }
            
            var ajoutRenvoiIndexSortie: String = ""
            var ajoutRenvoiMotifSortie: String = ""
            var ajoutRenvoiDescriptifSortie: String = ""
            
            if isEDLSortie {
                if commentaireObservationsSortie != "" {
                    
                    if compteur.indexCompteurSortie != nil {
                        ajoutRenvoiIndexSortie += ( " " + commentaireObservationsSortie)
                    } else if compteur.motifNonReleveSortie != nil {
                        ajoutRenvoiMotifSortie += ( " " + commentaireObservationsSortie)
                    } else {
                        ajoutRenvoiDescriptifSortie += (" " + commentaireObservationsSortie)
                    }
                }
            }
            
            
            var itemHTMLContent: String = isEDLSortie ?  ligneHTMLCompteurSortie : ligneHTMLCompteur
            
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nomCompteur#",           with: compteur.nomCompteur + ajoutRenvoiDescriptif + ajoutRenvoiDescriptifSortie)
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_localisationCompteur#",  with: compteur.localisationCompteur ?? "")
            
            
            if let enServicePresent = compteur.enServicePresent {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_enServicePresent#",      with: enServicePresent ? "Oui" : "Non")
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_enServicePresent#",      with: "")}
            
            if let index = compteur.indexCompteur {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_indexCompteur#",         with: String(index)) + ajoutRenvoiIndex }
                else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_indexCompteur#",         with: "")}
            
            // On prend par ordre : unite de sortie, unite d'entree ou ""
            if let uniteCompteurSortie = compteur.uniteCompteurSortie {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_uniteCompteur#",         with: uniteCompteurSortie)
            } else if let uniteCompteurEntree = compteur.uniteCompteur {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_uniteCompteur#",         with: uniteCompteurEntree)
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_uniteCompteur#",         with: "")
            }
            
            if let motifNonReleve = compteur.motifNonReleve {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_motifNonReleve#",        with: motifNonReleve + ajoutRenvoiMotif )
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_motifNonReleve#",        with: "")
            }
            // Sortie
            if isEDLSortie {
                
                var isChangementEDLSortie: Bool = false
                // On prepare pour l'item d'observations un renvoi vers les photos correspondant à l'EDL de Sortie
                // On complete le tableau des celulles d'image
                
                
                if let enServicePresentSortie = compteur.enServicePresentSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_enServicePresentSortie#",      with: enServicePresentSortie ? "Oui" : "Non")
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_enServicePresentSortie#",      with: "")}
                
                if let indexSortie = compteur.indexCompteurSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_indexCompteurSortie#",         with: String(indexSortie) + ajoutRenvoiIndexSortie)
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_indexCompteurSortie#",         with: "")}
                
                if let motifNonReleveSortie = compteur.motifNonReleveSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_motifNonReleveSortie#",        with: motifNonReleveSortie + ajoutRenvoiMotifSortie)
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_motifNonReleveSortie#",        with: "")
                }
                
                if isChangementEDLSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "<mark>")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "</mark>")
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "")
                }
            }
            
            allItems += itemHTMLContent
        }
        
        // Assemblage du tableau de détail
        contentHTML = (isEDLSortie ? debHTMLCompteurSortie : debHTMLCompteur) + allItems + (isEDLSortie ? finHTMLCompteurSortie : finHTMLCompteur)
        
        creerTableauImages(allTabItemsImage, &contentHTML)
       
        return contentHTML
        
    }
    
    
    
   
    
    fileprivate func fusionEntretien() -> String {
        
        if  EntretienController.shared.entretiens.count == 0 { return "" }
        
        var contentHTML: String = ""
            
        // Toutes les lignes de description en HTML
        var allItems = ""
        
        // Toutes les cellules (image + legende) de l'ensemble des equipements organisé en tableau de celulle (image + legende)
        var allTabItemsImage : [String] = []
        
        for entretien in EntretienController.shared.entretiens {

            // On prepare pour l'item d'observations un renvoi vers les photos
            // On complete le tableau des celulles d'image
            var commentaireObservations : String = ""
            var commentaireObservationsSortie : String = ""
            if let imagesEDL = entretien.images {
                // Appel du formatage de commentaire avec l'indicateur de EDLSortie à false
                commentaireObservations = fusionImage(imagesEDL, &allTabItemsImage, false)
                if isEDLSortie {
                    // Appel du formatage de commentaire avec l'indicateur de EDLSortie ) True
                    commentaireObservationsSortie = fusionImage(imagesEDL, &allTabItemsImage, true)
                }
            }
            
            var ajoutRenvoiObservation: String = ""
            if commentaireObservations != "" {
                if entretien.observationEntretien != nil {
                    ajoutRenvoiObservation += ( " " + commentaireObservations)
                }
            }
            
            var ajoutRenvoiObservationSortie: String = ""
            if isEDLSortie {
                if commentaireObservationsSortie != "" {
                    if entretien.observationEntretienSortie != nil {
                        ajoutRenvoiObservationSortie +=  commentaireObservationsSortie
                    }
                }
            }
            var itemHTMLContent: String = isEDLSortie ? ligneHTMLEntretienSortie : ligneHTMLEntretien
            
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_intitule#",                 with: entretien.intitule)
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_realise#",                 with: entretien.realise ? "Oui" : "Non")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_dateEcheanceEntretien#",              with: entretien.dateEcheanceEntretien)
            
            if let observation = entretien.observationEntretien {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationEntretien#",          with: observation + " " + ajoutRenvoiObservation)
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationEntretien#",          with: ajoutRenvoiObservation)
            }
            
            // Sortie
            if isEDLSortie {
                
                var isChangementEDLSortie: Bool = false
                // On prepare pour l'item d'observations un renvoi vers les photos correspondant à l'EDL de Sortie
                // On complete le tableau des celulles d'image
                
                
                if let observationSortie = entretien.observationEntretienSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationEntretienSortie#",          with: observationSortie + " " + ajoutRenvoiObservationSortie)
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationEntretien#",          with: ajoutRenvoiObservationSortie)
                }
                
                if isChangementEDLSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "<mark>")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "</mark>")
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "")
                }
            }
            
            allItems += itemHTMLContent
        }
        // Assemblage du tableau de détail
        contentHTML = ( isEDLSortie ? debHTMLEntretienSortie : debHTMLEntretien )  + allItems + ( isEDLSortie ? finHTMLEntretienSortie : finHTMLEntretien )
        
        creerTableauImages(allTabItemsImage, &contentHTML)
       
        return contentHTML
    }

    
    fileprivate func fusionClef() -> String {
        
        if  ClefController.shared.clefs.count == 0 { return "" }
        
           
        var contentHTML: String = ""
            
        var allItems = ""
        // Toutes les cellules (image + legende) de l'ensemble des equipements organisé en tableau de celulle (image + legende)
        var allTabItemsImage : [String] = []
        
        for clef in ClefController.shared.clefs {
            
            // On prepare pour l'item d'observations un renvoi vers les photos
            // On complete le tableau des celulles d'image
            var commentaireObservations : String = ""
            var commentaireObservationsSortie : String = ""
            if let imagesEDL = clef.images {
                // Appel du formatage de commentaire avec l'indicateur de EDLSortie à false
                commentaireObservations = fusionImage(imagesEDL, &allTabItemsImage, false)
                if isEDLSortie {
                    // Appel du formatage de commentaire avec l'indicateur de EDLSortie ) True
                    commentaireObservationsSortie = fusionImage(imagesEDL, &allTabItemsImage, true)
                }
            }
            
            var ajoutRenvoiObservation: String = ""
            if commentaireObservations != "" {
                if clef.observationClef != nil {
                    ajoutRenvoiObservation += ( " " + commentaireObservations)
                }
            }
            
            var ajoutRenvoiObservationSortie: String = ""
            if isEDLSortie {
                if commentaireObservationsSortie != "" {
                    if clef.observationClefSortie != nil {
                        ajoutRenvoiObservationSortie +=  commentaireObservationsSortie
                    }
                }
            }
            
            
            var itemHTMLContent :String = isEDLSortie ? ligneHTMLClefSortie : ligneHTMLClef
            
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_intituleClef#",    with: clef.intituleClef)
            
            if let nombreClef = clef.nombreClefs {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nombreClefs#",   with: String(nombreClef))
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nombreClefs#",   with: "")
            }
            
            if let observation = clef.observationClef {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationClef#", with: observation + " " + ajoutRenvoiObservation )
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationClef#", with: ajoutRenvoiObservation )
            }
            
            // Sortie
            if isEDLSortie {
                
                var isChangementEDLSortie: Bool = false
                // On prepare pour l'item d'observations un renvoi vers les photos correspondant à l'EDL de Sortie
                // On complete le tableau des celulles d'image
                
                
                if let nombreClefSortie = clef.nombreClefsSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nombreClefsSortie#",   with: String(nombreClefSortie))
                    isChangementEDLSortie = true
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nombreClefsSortie#",   with: "" )
                }
                
                if let observationSortie = clef.observationClefSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationClefSortie#", with: observationSortie + " " + ajoutRenvoiObservationSortie )
                    isChangementEDLSortie = true
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observationClefSortie#", with: ajoutRenvoiObservationSortie )
                }
                
                if isChangementEDLSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "<mark>")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "</mark>")
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "")
                }
            }
            allItems += itemHTMLContent
                
                
        }
        // Assemblage du tableau de détail
        contentHTML = ( isEDLSortie ? debHTMLClefSortie : debHTMLClef ) + allItems + ( isEDLSortie ? finHTMLClefSortie : finHTMLClef )
        creerTableauImages(allTabItemsImage, &contentHTML)
   
        return contentHTML
    }

    
    
   

    fileprivate func fusionFournitureEquipement( equipements: [Equipement] , nomRubrique: String, nomFic: String ) -> String {
        
        if  equipements.count == 0 { return "" }
        
        var contentHTML: String = ""
             
        // NB : pour la réutilisation de ce code sur les Fournitures, la substitution suivante est sans effet
        var debHTMLCourant: String = ""
        if nomFic == "Pieces" {
            if isEDLSortie {
                debHTMLCourant = debHTMLPieceSortie.replacingOccurrences(of: "#ITEM_nomCategorie#", with: nomRubrique)
            } else {
                debHTMLCourant = debHTMLPiece.replacingOccurrences(of: "#ITEM_nomCategorie#", with: nomRubrique)
            }
        } else {
            if isEDLSortie {
                debHTMLCourant = debHTMLFournitureSortie
            } else {
                debHTMLCourant = debHTMLFourniture
            }
        }
        // Toutes les lignes de description en HTML
        var allItems = ""
        // Toutes les cellules (image + legende) de l'ensemble des equipements organisé en tableau de celulle (image + legende)
        var allTabItemsImage : [String] = []
        
        for equipement in equipements {
            
            // On prepare pour l'item d'observations un renvoi vers les photos
            // On complete le tableau des celulles d'image
            var commentaireObservations : String = ""
            if let imagesEDL = equipement.images {
                // Appel du formatage de commentaire avec l'indicateur de EDLSortie à false
                commentaireObservations = fusionImage(imagesEDL, &allTabItemsImage, false)
            }
            var observationFinale = ""
            if let observations = equipement.observations {
                if commentaireObservations != "" {
                    observationFinale = observations + " " + commentaireObservations
                } else {
                    observationFinale = observations
                }
            } else if commentaireObservations != "" {
                    observationFinale = commentaireObservations
            }
            
            
            
            var itemHTMLContent: String
            if nomFic == "Pieces" {
                itemHTMLContent = isEDLSortie ?  ligneHTMLPieceSortie : ligneHTMLPiece
            } else {
                itemHTMLContent = isEDLSortie ?  ligneHTMLFournitureSortie : ligneHTMLFourniture
            }
            
            /*
             <tr>
                 <td>#ITEM_equipement#</td>
                 <td><div class = "#ITEM_etat_couleur#">#ITEM_etat#</div></td>
                 <td><div class = "#ITEM_etat_couleur#">#ITEM_etat_sortie#</div></td>
                 <td><div class = "#ITEM_proprete_couleur#">#ITEM_proprete#</div></td>
                 <td><div class = "#ITEM_proprete_couleur#">#ITEM_proprete_sortie#</div></td>
                 <td><div class = "#ITEM_fonctionnel_couleur#">#ITEM_fonctionnel#</div></td>
                 <td><div class = "#ITEM_fonctionnel_couleur#">#ITEM_fonctionnel_sortie#</div></td>
                 <td>#ITEM_observations#</td>
                 <td>#ITEM_observations_sortie#</td>
             </tr>

             
             
             */
            
            
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_equipement#",   with: equipement.equipement)
            if let nExemplaire = equipement.nExemplaire {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nExemplaire#",   with: String(nExemplaire))
            } else {
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nExemplaire#",   with: "")
            }
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat#",         with: Abreviation.etat(etat: equipement.etat).abreviation().keys.first!)
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_fonctionnel#",  with: Abreviation.fonctionnel(fonctionnel: equipement.fonctionnel).abreviation().keys.first!)
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_proprete#",     with: Abreviation.proprete(proprete: equipement.proprete).abreviation().keys.first!)
            
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur#", with: Abreviation.etat(etat: equipement.etat).abreviation().values.first!)
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_fonctionnel_couleur#",  with: Abreviation.fonctionnel(fonctionnel: equipement.fonctionnel).abreviation().values.first!)
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_proprete_couleur#",     with: Abreviation.proprete(proprete: equipement.proprete).abreviation().values.first!)
            
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observations#", with: observationFinale)
            
            if isEDLSortie {
                var isChangementEDLSortie: Bool = false
                // On prepare pour l'item d'observations un renvoi vers les photos correspondant à l'EDL de Sortie
                // On complete le tableau des celulles d'image
                var commentaireObservations : String = ""
                if let imagesEDL = equipement.images {
                    // Appel du formatage de commentaire avec l'indicateur de EDLSortie ) True
                    commentaireObservations = fusionImage(imagesEDL, &allTabItemsImage, true)
                }
                var observationFinale = ""
                if let observations = equipement.observationsSortie {
                    isChangementEDLSortie = true
                    if commentaireObservations != "" {
                        observationFinale = observations + " " + commentaireObservations
                    } else {
                        observationFinale = observations
                    }
                } else if commentaireObservations != "" {
                        isChangementEDLSortie = true
                        observationFinale = commentaireObservations
                }
                
                
                
                
                
                if let nExemplaireSortie = equipement.nExemplaireSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nExemplaireSortie#",   with: String(nExemplaireSortie))
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_nExemplaireSortie#",   with: "")
                }
                
                if let etatSortie = equipement.etatSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_sortie#",         with: Abreviation.etat(etat: etatSortie).abreviation().keys.first!)
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_sortie_couleur#", with: Abreviation.etat(etat: etatSortie).abreviation().values.first!)
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_sortie#",         with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_sortie_couleur#", with: "")
                }
                
                if let propreteSortie = equipement.propreteSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_proprete_sortie#",     with: Abreviation.proprete(proprete: propreteSortie).abreviation().keys.first!)
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_proprete_sortie_couleur#",     with: Abreviation.proprete(proprete: propreteSortie).abreviation().values.first!)
                    
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_proprete_sortie#",     with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_proprete_sortie_couleur#",     with:"")
                    
                }
                
                if let fonctionnelSortie = equipement.fonctionnelSortie {
                    isChangementEDLSortie = true
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_fonctionnel_sortie#",  with: Abreviation.fonctionnel(fonctionnel: fonctionnelSortie).abreviation().keys.first!)
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_fonctionnel_sortie_couleur#",  with: Abreviation.fonctionnel(fonctionnel: fonctionnelSortie).abreviation().values.first!)
                    
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_fonctionnel_sortie#",  with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_fonctionnel_sortie_couleur#",  with: "")
                }
                
       //         if let observationSortie = equipement.observationsSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observations_sortie#", with: observationFinale)
      //          } else {
      //              itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_observations_sortie#", with: "")
      //          }
                if isChangementEDLSortie {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "<mark>")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "</mark>")
                } else {
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MD#", with: "")
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#MF#", with: "")
                }
            }
            
            allItems += itemHTMLContent
        }
        
            // Assemblage du tableau de détail
       
        if nomFic == "Pieces" {
            if isEDLSortie {
                contentHTML = debHTMLCourant + allItems + finHTMLPieceSortie
            } else {
                contentHTML = debHTMLCourant + allItems + finHTMLPiece
            }
        } else {
            if isEDLSortie {
                contentHTML = debHTMLCourant + allItems + finHTMLFournitureSortie
            } else {
                contentHTML = debHTMLCourant + allItems + finHTMLFourniture
            }
        }
        creerTableauImages(allTabItemsImage, &contentHTML)
        
        return contentHTML
    }
    
    
    func tagRenvoieImage ( renvoi: String ) -> String {
        return "<sup>" + renvoi + "</sup>"
    }
    
    
    
    
    func fusionImage (_ imagesEDL: [ImageEDL] , _ tabHTMLContent: inout [String] , _ isEDLSortie: Bool = false) -> String {
        
        // On ajoute dans l'item d'observations un renvoie vers les photos
        var commentaireObservations : String = ""
        
            
            for imageEDL in imagesEDL {
                var itemHTMLContent = imageHTML
                var itemEDLSortie = false
                if let isImageEDLSortie = imageEDL.isImageEDLSortie {
                    itemEDLSortie = isImageEDLSortie
                }
                
                if itemEDLSortie == isEDLSortie {
                    
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_NomFichier#",with:      imageEDL.nomImage)
                    if let legende = imageEDL.legendText {
                        itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_Legende#", with:  "(\(indexRenvoi)):" + " " + legende)
                        if commentaireObservations == "" {
                            commentaireObservations += "(\(indexRenvoi))"
                        } else {
                            commentaireObservations += ",(\(indexRenvoi))"
                        }
                    }
                    
                    
                    tabHTMLContent.append(itemHTMLContent)
                    indexRenvoi += 1
                }
            }
        
        return tagRenvoieImage(renvoi: commentaireObservations)
    }
    
    fileprivate func creerTableauImages(_ allTabItemsImage: [String], _ contentHTML: inout String) {
        // Création du tableau d'image (3 par ligne) à partir du tableau des celulles calculés
        if allTabItemsImage.count > 0 {
            var allItemsImage: String = ""
            let (q, r) = allTabItemsImage.count.quotientAndRemainder(dividingBy: 3)
            let nombreLignesPleines: Int = q
            let ligneIncomplete = ( r > 0 )
            
            
            // Lignes completes
            var index: Int = 0
            if nombreLignesPleines > 0 {
                for _ in 1...nombreLignesPleines {
                    var itemLigneCourante = ligneImageHTML
                    itemLigneCourante = itemLigneCourante.replacingOccurrences(of: "#ITEM_ImageEDL1#", with: allTabItemsImage[index])
                    index += 1
                    itemLigneCourante = itemLigneCourante.replacingOccurrences(of: "#ITEM_ImageEDL2#", with: allTabItemsImage[index])
                    index += 1
                    itemLigneCourante = itemLigneCourante.replacingOccurrences(of: "#ITEM_ImageEDL3#", with: allTabItemsImage[index])
                    index += 1
                    allItemsImage += itemLigneCourante
                }}
            
       
            
            // Dernière ligne ou seule ligne mais incomplete ou ligne vide si on a un multiple de 3
            if ligneIncomplete {
                var itemDerniereLigne = ligneImageHTML
                
                for c in 0...r-1 {
                    itemDerniereLigne = itemDerniereLigne.replacingOccurrences(of: "#ITEM_ImageEDL\(c+1)#", with: allTabItemsImage[index])
                    index += 1
                }
                for c in r...2  {
                    itemDerniereLigne = itemDerniereLigne.replacingOccurrences(of: "#ITEM_ImageEDL\(c+1)#", with: " ")
                }
                allItemsImage += itemDerniereLigne
            }
            
            
            contentHTML = contentHTML + debImageHTML + allItemsImage + finImageHTML
        }
    }
    
    fileprivate func fusionLegende() -> String {
        
        var contentHTML: String = ""
 
        // Toutes les lignes de description en HTML
        var allItems = ""
        var j = 1
        var itemHTMLContent = ligneHTMLLegende
        for i in 0...dicoLegende.count - 1 {
            
            switch dicoLegende[i] {
            case .etat(let etat):
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_acronyme\(j)#",           with: Abreviation.etat(etat: etat).abreviation().keys.first!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur\(j)#",           with: Abreviation.etat(etat: etat).abreviation().values.first!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_signification\(j)#",           with: etat.description)
                
            case.fonctionnel(let fonctionnel):
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_acronyme\(j)#",           with: Abreviation.fonctionnel(fonctionnel: fonctionnel).abreviation().keys.first!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur\(j)#",           with: Abreviation.fonctionnel(fonctionnel: fonctionnel).abreviation().values.first!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_signification\(j)#",           with: fonctionnel.description)
                
            case .proprete(let proprete):
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_acronyme\(j)#",           with: Abreviation.proprete(proprete: proprete).abreviation().keys.first!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur\(j)#",           with: Abreviation.proprete(proprete: proprete).abreviation().values.first!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_signification\(j)#",           with: proprete.description)
            }
            j += 1
            if j == 4 {
                j = 1
                allItems += itemHTMLContent
                itemHTMLContent = ligneHTMLLegende
            }
        }
        if dicoLegende.count % 3 == 1 {
            // Rajouter deux item à vide
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_acronyme\(j)#",           with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur\(j)#",with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_signification\(j)#",           with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_acronyme\(j+1)#",           with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur\(j+1)#",with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_signification\(j+1)#",           with: "")
            allItems += itemHTMLContent
        }
        if dicoLegende.count % 3 == 2 {
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_acronyme\(j)#",           with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_etat_couleur\(j)#",with: "")
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_signification\(j)#",           with: "")
            allItems += itemHTMLContent
        }
       
            
        
        
        // Assemblage du tableau de détail
        contentHTML = debHTMLLegende + allItems + finHTMLLegende
        
        return contentHTML
        
    }
    
    // MARK: - Création du PDF
    
    func exportHTMLContentToPDF(webViewPrintFormatter: UIViewPrintFormatter , urlPDF: URL) {
        
     let printPageRenderer = CustomPrintPageRenderer()
        printPageRenderer.delegate = self
        
        
         printPageRenderer.addPrintFormatter(webViewPrintFormatter, startingAtPageAt: 1)
        
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil)
        
        
        for i in 1..<printPageRenderer.numberOfPages  {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        
       
        
        do {  try pdfData.write(to: urlPDF)
        } catch {
            print ("erreur ecriture fichier PDF")
            return
        }
        
        
    }
    
    
    //MARK: - Entete et pied de page exposé à CustomPrintPageRender
    
    func enteteRender (_ customPrintPageRenderer: CustomPrintPageRenderer, enteteAtPage numPage : Int , nombrePages nPages: Int) -> String
     {
        return ""
    }
    
    func piedPageRender (_ customPrintPageRenderer: CustomPrintPageRenderer, piedAtPage numPage : Int , nombrePages nPages: Int) -> String {
        
        var HTMLContent: String
        var blocPiedPage: String = """
AGENCEIMMO - SAS au Capital de 20 000 €
RCS Paris 111 222 333 44444 - Code APE 8299Z
TVA Intracommunautaire : FR 11 000 000 000
"""
        if edl.idEmetteur != nil {
            if let emetteur = EmetteurController.emetteurByUUID(uuidEmetteur: edl.idEmetteur!),
               let blocPiedPageEmetteur = emetteur.blocPiedPage {
                blocPiedPage = blocPiedPageEmetteur
            }}
        print ("page n° \(numPage)")
        if numPage < nPages - 1 {
            HTMLContent = piedPageCouranteHTML
            print ("page n° \(numPage)")
            
        } else {
            HTMLContent = piedPageDerniereHTML
            print ("Derniere page n° \(numPage)")
        }
        
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_blocPiedPage#", with: blocPiedPage)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_numPage#", with: String(numPage))
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_nombrePages#", with: String(nPages - 1))
        
        let refDocument = dateDayFormatter.string(from: edl.dateEDL)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_dateEDL#", with: refDocument)
        
        
        
        
        
        if let edlRef = edl.refEDL {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_refEDL#", with: "Ref: \(edlRef)")
        } else {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_refEDL#", with: "")
        }
        
        return HTMLContent
    }
    
  
    func piedPageRender(_ customPrintPageRenderer: CustomPrintPageRenderer, imagePiedAtPage numPage: Int, nombrePages nPages: Int) -> [Int : UIImage] {
        var imageTab: [Int : UIImage] = [:]
        if edl.idEmetteur != nil && isAvecSignature {
            if let parapheBailleurImageEDL = edl.parapheBailleurImageEDL {
                if existeImage(idImage: parapheBailleurImageEDL.nomImage) {
                    imageTab[0]=chargeImage(idImage: parapheBailleurImageEDL.nomImage)
                }
            }
            if let parapheLocataireImageEDL = edl.parapheLocataireImageEDL {
                if existeImage(idImage: parapheLocataireImageEDL.nomImage) {
                    imageTab[1]=chargeImage(idImage: parapheLocataireImageEDL.nomImage)
                }
                
            }
            
            
        }
        return imageTab
    }
    
}


