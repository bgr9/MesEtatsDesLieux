//
//  ModeleEDLController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 14/02/2023.
//

import Foundation

class ModeleEDLController {
    
    static let shared = ModeleEDLController(modelesEDL: [])
    var modelesEDL = [ModeleEDL]()
    
    init(modelesEDL: [ModeleEDL] = [ModeleEDL]()) {
        if let modelesEDL = ModeleEDLController.chargeModelesEDL() {
            self.modelesEDL = modelesEDL
        } else {
            // Première exécution, on prend les modeles types qui seront sauvegarder
            self.modelesEDL = [ ]
        }
    }

    // MARK: Fonctions de gestion
    static func chargeModelesEDL() -> [ModeleEDL]? {
        let archiveURL = documentsDirectory.appendingPathComponent("ModelesEDL").appendingPathExtension("plist")
        print("--- ArchiveURL : \( archiveURL)")
        guard let modelesEDL = try? Data(contentsOf: archiveURL ) else { return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode([ModeleEDL].self, from: modelesEDL)
    }
    
    static func sauveModelesEDL (_ modelesEDL: [ModeleEDL]? = ModeleEDLController.shared.modelesEDL) {
        
        if EDLsController.selectedEDLUUIDString() != "" {
            let archiveURL = documentsDirectory.appendingPathComponent("ModelesEDL").appendingPathExtension("plist")
            let propertyListEncoder = PropertyListEncoder()
            let modelesEDL = try? propertyListEncoder.encode(modelesEDL)
            try? modelesEDL?.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func getModeleEDLbyType (typeModele: TypeModele) -> [ ModeleEDL ] {
        return ModeleEDLController.shared.modelesEDL.filter { $0.typeModele == typeModele}
    }
    
    // Complete un nouveau EDL avec les catégories et les valeurs issues du modèle
    static func completeEDLfromType ( typeModel : TypeModele, nomModele: String) {
        
        
        // On récupère l'EDL via l'EDL sélectionné
        
        switch typeModel {
        case .vide:
            // Personalisation des idBien de Categories à partir de l'EDL sélectionné
            var modeleCategories = ModeleCategories
            for i in 0...modeleCategories.count - 1 {
                modeleCategories[i].idBien = EDLsController.selectedEDLUUID()!
            }
            // On stocke le modele de catagorie en fichier puis on le charge
            // L'EDL de référence est celui référencé dans le controlleur EDL
            CategorieController.sauveCategories(modeleCategories)
            CategorieController.shared.categories = CategorieController.chargeCategories()!
            
            // Création d'un émetteur par défaut et rattachement à l'EDL
            var emetteur = ModeleEmetteurDefaut
            emetteur.idEmetteur = UUID ()
            _ = EmetteurController.majEmetteur(emetteur: emetteur)
            
            var newEDL = EDLsController.selectedEDLedl()!
            newEDL.idEmetteur = emetteur.idEmetteur
            _ = EDLsController.majEDL(edl: newEDL)
        
        case .demo:
            
            
            var modeleCategories = ModeleCategoriesDemo
            for i in 0...modeleCategories.count - 1 {
                modeleCategories[i].idBien = EDLsController.selectedEDLUUID()!
            }
            CategorieController.sauveCategories(ModeleCategoriesDemo)
            CategorieController.shared.categories = CategorieController.chargeCategories()!
            
            CompteurController.sauveCompteurs(ModeleCompteursDemo)
            CompteurController.shared.compteurs = CompteurController.chargeCompteurs()!
            
            EntretienController.sauveEntretiens(ModeleEntretiensDemo)
            EntretienController.shared.entretiens = EntretienController.chargeEntretiens()!
            
            ClefController.sauveClefs(ModeleClesDemo)
            ClefController.shared.clefs = ClefController.chargeClefs()!
            
            FournitureController.sauveFournitures(ModeleFournituresDemo)
            FournitureController.shared.fournitures = FournitureController.chargeFournitures()!
            
            EquipementController.sauveEquipements(ModeleEquipementsDemo)
            EquipementController.shared.equipements = EquipementController.chargeEquipements()!
            
            var newEDLDemo = EDLsController.selectedEDLedl()!
            
            self.majEDLDemo(edl: &newEDLDemo)
            
            if let emetteur = EmetteurController.emetteurByNom(nomEmetteur: ModeleEmetteurDemo.nomEmetteur) {
                // L'emetteur existe il suffit de rattacher l'EDL
                    newEDLDemo.idEmetteur = emetteur.idEmetteur
                    _ = EDLsController.majEDL(edl: newEDLDemo)
            } else {
                // Il faut creer l'emetteur de Demo
                var emetteur = ModeleEmetteurDemo
                emetteur.idEmetteur = UUID ()
                _ = EmetteurController.majEmetteur(emetteur: emetteur)
                newEDLDemo.idEmetteur = emetteur.idEmetteur
            }
            _ = EDLsController.majEDL(edl: newEDLDemo)
            
        case .typeBien:
            for m in ModeleEDLController.modelesTypes {
                if m.nomModele == nomModele {
                    
                    var modeleCategories = m.categories
                    for i in 0...modeleCategories.count - 1 {
                        modeleCategories[i].idBien = EDLsController.selectedEDLUUID()!
                    }
                    CategorieController.sauveCategories(modeleCategories)
                    CategorieController.shared.categories = CategorieController.chargeCategories()!
                    
                    CompteurController.sauveCompteurs(m.compteurs)
                    CompteurController.shared.compteurs = CompteurController.chargeCompteurs()!
                    
                    EntretienController.sauveEntretiens(m.entretiens)
                    EntretienController.shared.entretiens = EntretienController.chargeEntretiens()!
                    
                    ClefController.sauveClefs(m.clefs)
                    ClefController.shared.clefs = ClefController.chargeClefs()!
                    
                    FournitureController.sauveFournitures(m.fournitures)
                    FournitureController.shared.fournitures = FournitureController.chargeFournitures()!
                    
                    EquipementController.sauveEquipements(m.equipements)
                    EquipementController.shared.equipements = EquipementController.chargeEquipements()!
                    
                    // Création d'un émetteur par défaut et rattachement à l'EDL
                    var emetteur = ModeleEmetteurDefaut
                    emetteur.idEmetteur = UUID ()
                    _ = EmetteurController.majEmetteur(emetteur: emetteur)
                    
                    var newEDL = EDLsController.selectedEDLedl()!
                    newEDL.idEmetteur = emetteur.idEmetteur
                    _ = EDLsController.majEDL(edl: newEDL)
                    
                     
                }
            }
        case .sortieApresEntree , .reprise:
            
            // TODO: Différencier la reprise
            
            if var sortieEDL = EDLsController.selectedEDLedl(),
               let identreeEDL = sortieEDL.idEDLEntree,
               let entreeEDL = EDLsController.edlFromUUID(idEDL: identreeEDL){
                // On recharge l'EDL d'entree pour recuperer toutes les informations
                _ = EDLsController.selectEDLbyUUID(id: identreeEDL)
                
                // Copie et adaptation des Categories
                CategorieController.shared.categories = CategorieController.chargeCategories()!
                var sortieCategories = CategorieController.shared.categories
                for i in 0...sortieCategories.count - 1 {
                    sortieCategories[i].idBien = sortieEDL.idEDL
                }
                // Copie des Compteurs
                CompteurController.shared.compteurs = CompteurController.chargeCompteurs()!
                var sortieCompteurs = CompteurController.shared.compteurs
                // Modification des images en créant des duplicatas avec des nouveaux noms
                // pour rendre indépendant les EDL
                for i in 0...sortieCompteurs.count - 1 {
                    if let images = sortieCompteurs[i].images {
                        var newImages: [ImageEDL] = [ ]
                        for image in images {
                            let duplicateImageEDL = ImageEDL(legendText: image.legendText, nomImage: duplicateImage(idImage: image.nomImage))
                            newImages.append(duplicateImageEDL)
                        }
                        sortieCompteurs[i].images = newImages
                    }
                }
                
                // Copie des Entretiens
                EntretienController.shared.entretiens = EntretienController.chargeEntretiens()!
                var sortieEntretiens = EntretienController.shared.entretiens
                // Modification des images en créant des duplicatas avec des nouveaux noms
                // pour rendre indépendant les EDL
                for i in 0...sortieEntretiens.count - 1 {
                    if let images = sortieEntretiens[i].images {
                        var newImages: [ImageEDL] = [ ]
                        for image in images {
                            let duplicateImageEDL = ImageEDL(legendText: image.legendText, nomImage: duplicateImage(idImage: image.nomImage))
                            newImages.append(duplicateImageEDL)
                        }
                        sortieEntretiens[i].images = newImages
                    }
                }
                
                // Copie des Clefs
                ClefController.shared.clefs = ClefController.chargeClefs()!
                var sortieClefs = ClefController.shared.clefs
                // Modification des images en créant des duplicatas avec des nouveaux noms
                // pour rendre indépendant les EDL
                for i in 0...sortieClefs.count - 1 {
                    if let images = sortieClefs[i].images {
                        var newImages: [ImageEDL] = [ ]
                        for image in images {
                            let duplicateImageEDL = ImageEDL(legendText: image.legendText, nomImage: duplicateImage(idImage: image.nomImage))
                            newImages.append(duplicateImageEDL)
                        }
                        sortieClefs[i].images = newImages
                    }
                }
                
                // Copie des Fournitures
                FournitureController.shared.fournitures = FournitureController.chargeFournitures()!
                var sortieFournitures = FournitureController.shared.fournitures
                // Modification des images en créant des duplicatas avec des nouveaux noms
                // pour rendre indépendant les EDL
                for i in 0...sortieFournitures.count - 1 {
                    if let images = sortieFournitures[i].images {
                        var newImages: [ImageEDL] = [ ]
                        for image in images {
                            let duplicateImageEDL = ImageEDL(legendText: image.legendText, nomImage: duplicateImage(idImage: image.nomImage))
                            newImages.append(duplicateImageEDL)
                        }
                        sortieFournitures[i].images = newImages
                    }
                }
                
                // Copie des Equipements
                EquipementController.shared.equipements = EquipementController.chargeEquipements()!
                var sortieEquipements = EquipementController.shared.equipements
                // Modification des images en créant des duplicatas avec des nouveaux noms
                // pour rendre indépendant les EDL
                for i in 0...sortieEquipements.count - 1 {
                    if let images = sortieEquipements[i].images {
                        var newImages: [ImageEDL] = [ ]
                        for image in images {
                            let duplicateImageEDL = ImageEDL(legendText: image.legendText, nomImage: duplicateImage(idImage: image.nomImage))
                            newImages.append(duplicateImageEDL)
                        }
                        sortieEquipements[i].images = newImages
                    }
                }
                
                // On rebascule l'EDL selectionné sur la sortie pour mettre à jour les éléments de l'EDL Sortie et les sauvegarder
                _ = EDLsController.selectEDLbyUUID(id: sortieEDL.idEDL)
                
                CategorieController.shared.categories = sortieCategories
                CategorieController.sauveCategories()
                
                CompteurController.shared.compteurs = sortieCompteurs
                CompteurController.sauveCompteurs()
                
                EntretienController.shared.entretiens = sortieEntretiens
                EntretienController.sauveEntretiens()
                
                ClefController.shared.clefs = sortieClefs
                ClefController.sauveClefs()
                
                FournitureController.shared.fournitures = sortieFournitures
                FournitureController.sauveFournitures()
                
                EquipementController.shared.equipements = sortieEquipements
                EquipementController.sauveEquipements()
                
                // Mise à jour sélectives des autres propriétés
                sortieEDL.isEDLSortieApresEntree = true
                sortieEDL.etatEDL = .actif
                sortieEDL.typeBien = entreeEDL.typeBien
                sortieEDL.adresseBien = entreeEDL.adresseBien
                sortieEDL.villeBien = entreeEDL.villeBien
                sortieEDL.codePostalBien = entreeEDL.codePostalBien
                sortieEDL.localisationBien = entreeEDL.localisationBien
                sortieEDL.nomProprietaire = entreeEDL.nomProprietaire
                sortieEDL.nomLocataire = entreeEDL.nomLocataire
                sortieEDL.emailLocataire = entreeEDL.emailLocataire
                sortieEDL.nomMandataire = entreeEDL.nomMandataire
                sortieEDL.adresseMandataire = entreeEDL.adresseMandataire
                sortieEDL.codePostalMandataire = entreeEDL.codePostalMandataire
                sortieEDL.villeMandataire = entreeEDL.villeMandataire
                sortieEDL.refEDLEntree = entreeEDL.refEDL
                sortieEDL.dateEDLEntree = entreeEDL.dateEDL
                sortieEDL.idEmetteur = entreeEDL.idEmetteur
                
                if let nomFichierInitial = entreeEDL.dernierFichierViergeNomFichier{
                    sortieEDL.fichierEntreePDFViergeNomFichier = duplicatePDF(nomFichierPDF:  nomFichierInitial )
                }
                if let nomFichierInitial = entreeEDL.dernierFichierSigneNomFichier{
                    sortieEDL.fichierEntreePDFSigneNomFichier = duplicatePDF(nomFichierPDF:  nomFichierInitial )
                }
                
                _ = EDLsController.majEDL(edl: sortieEDL)
                EDLsController.sauveEDLs()
                
            
                
                
            }
        
            
            
        }
    }
    
    // MARK: Liste des modeles
    
    // MARK: Modele demo
    static let ModeleEDLDemo: EDL = EDL()
    
    static func majEDLDemo ( edl: inout EDL ) {
        // edl.nomBien = "App T3 sur 1 niveau" -> Le nom a été saisi par l'utilisateur
        edl.adresseBien = "10 rue d'Alsace Lorraine"
        edl.villeBien = "Paris"
        edl.codePostalBien = "75000"
        edl.localisationBien = "Batiment A, Escalier 2, 2ème étage, porte droite "
        edl.nomProprietaire = "Tenardier Charles"
        edl.nomLocataire = "Léonard de Vinci et Paul Toutlemonde"
        edl.emailLocataire = "ldvci@mail.com"
        edl.nomMandataire = "Agence Immo"
        edl.typeEDL = .entree
        edl.dateEDL = dateDayFormatter.date(from:"01/01/2000")!
        edl.nomExecutantEDL = "Arsène Lupin"
    }
    
    
    static let ModeleCategoriesDemo: [Categorie] = [
        Categorie(nomCategorie: "Compteurs",            idBien: UUID(),typeElement: .compteur),
        Categorie(nomCategorie: "Contrats Entretien",   idBien: UUID(),typeElement: .entretien),
        Categorie(nomCategorie: "Clefs",                idBien: UUID(),typeElement: .clef),
        Categorie(nomCategorie: "Fournitures",          idBien: UUID(),typeElement: .fourniture),
        Categorie(nomCategorie: "Cuisine",              idBien: UUID(),typeElement: .equipement),
        Categorie(nomCategorie: "Entrée",               idBien: UUID(),typeElement: .equipement),
        Categorie(nomCategorie: "Chambre",              idBien: UUID(),typeElement: .equipement)
    ]

    static let ModeleCompteursDemo: [Compteur] = [
        Compteur ( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleCompteur) , nomCompteur: "Compteur Electricité", enServicePresent: true, indexCompteur: 99999, uniteCompteur: "Kwh", localisationCompteur: "Dans la cave", motifNonReleve: "" ),
        Compteur ( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleCompteur) , nomCompteur: "Compteur Eau", enServicePresent: true, indexCompteur: 2389, uniteCompteur: "m3", localisationCompteur: "Dans le jardin", motifNonReleve: "" )
        ]
    
    static let ModeleEntretiensDemo: [Entretien] = [
        Entretien(idCategorie: CategorieController.categorieUUID(nomCategorie: libelleContratsEntretien), intitule: "Entretien Chauffe-eau", realise: true, dateEcheanceEntretien: "Tous les ans, le dernier a eu lieu le 12/12/2022", observationEntretien: "RAS")
        ]
    
    static let ModeleClesDemo: [Clef] = [
        Clef ( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleClefs) , intituleClef: "Clef de la porte d'entrée", nombreClefs: 2, observationClef: "Belles clefs !"),
        Clef ( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleClefs), intituleClef: "Clef immeuble", nombreClefs: 5, observationClef: "")
        ]
    
    static let ModeleFournituresDemo: [Fourniture] = [
        Fourniture( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleFournitures), equipement : "Boite aux lettres", observations: "RAS"),
        Fourniture( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleFournitures), equipement : "Détecteur de fumée", etat: .bonetat, observations: "RAS" )
    ]
    
    static let ModeleEquipementsDemo: [Equipement] = [
        Equipement( idCategorie: CategorieController.categorieUUID(nomCategorie: "Entrée"), equipement: "Mur", observations: "RAS sur le mur"),
        Equipement( idCategorie: CategorieController.categorieUUID(nomCategorie: "Cuisine"), equipement: "Mur", observations: "RAS sur le mur"),
        Equipement( idCategorie: CategorieController.categorieUUID(nomCategorie: "Chambre"), equipement: "Mur", observations: "RAS sur le mur"),
        Equipement( idCategorie: CategorieController.categorieUUID(nomCategorie: "Chambre"), equipement: "Sol", observations: "RAS sur le mur")
    ]
    
    static let ModeleEmetteurDemo =
        Emetteur(nomEmetteur: "Agence Immo", idSnapshot: 0, adresseEmetteur: "1, rue des Cerisiers", villeEmetteur: "Paris Cedex 00", codePostalEmetteur: "75000", clauseContractuelleEntree: """
Les soussignés reconnaissent exactes les constatations sur l'état du logement, sous réserve du bon fonctionnement des canalisations, appareils et installations sanitaires, électriques et du chauffage qui n'a pu être vérifié ce jour, toute défectuosité dans le fonctionnement de ceux-ci devant être signalée dans le délai maximum de dix jours, et pendant le premier mois de la période de chauffe en ce qui concerne les éléments de chauffage. Les co-signataires reconnaissent avoir reçu chacun un exemplaire du présent état des lieux et s'accordent pour y faire référence lors du départ du locataire
Le présent état des lieux, a été établi contradictoirement entre les parties qui le reconnaissent exact. Le présent état des lieux, a été envoyé par mail au(x) locataire(s) à l'adresse indiqué ci-dessus.
"""
        , validationClauseContractuelleEntree: false, clauseContractuelleSortie: """
         Les soussignés reconnaissent exactes les constatations sur l'état du logement, sous réserve du bon fonctionnement des canalisations, appareils et installations sanitaires, électriques et du chauffage qui n'a pu être vérifié ce jour, toute défectuosité dans le fonctionnement de ceux-ci devant être signalée dans le délai maximum de dix jours, et pendant le premier mois de la période de chauffe en ce qui concerne les éléments de chauffage. Les co-signataires reconnaissent avoir reçu chacun un exemplaire du présent état des lieux et s'accordent pour y faire référence lors du départ du locataire
         Le présent état des lieux, a été établi contradictoirement entre les parties qui le reconnaissent exact. Le présent état des lieux, a été envoyé par mail au(x) locataire(s) à l'adresse indiqué ci-dessus.
         """
        , validationClauseContractuelleSortie: false , libelleSignatureLocataire: "Le présent document est transmis et accepté par le locataire", libelleSignatureBailleur: "Le présent document est transmis et accepté par le propriétaire ou par son mandataire", blocPiedPage:"""
Agence IMMO, SAS au capital de 20 000 €
RCS Paris 123 123 123 12345, code APE 2345Z
TVA Intracommunautaire : FR 99 999 999 999
"""
        )
  
    
    // MARK: Modele Vide
    static let ModeleCategories: [Categorie] = [
        Categorie(nomCategorie: "Compteurs",            idBien: UUID(),typeElement: .compteur),
        Categorie(nomCategorie: "Contrats Entretien",   idBien: UUID(),typeElement: .entretien),
        Categorie(nomCategorie: "Clefs",                idBien: UUID(),typeElement: .clef),
        Categorie(nomCategorie: "Fournitures",          idBien: UUID(),typeElement: .fourniture),
    ]
    
    
    
    static let ModeleEmetteurDefaut =
        Emetteur(nomEmetteur: "", idSnapshot: 0, adresseEmetteur: "", villeEmetteur: "", codePostalEmetteur: "", clauseContractuelleEntree: """
Les soussignés reconnaissent exactes les constatations sur l'état du logement, sous réserve du bon fonctionnement des canalisations, appareils et installations sanitaires, électriques et du chauffage qui n'a pu être vérifié ce jour, toute défectuosité dans le fonctionnement de ceux-ci devant être signalée dans le délai maximum de dix jours, et pendant le premier mois de la période de chauffe en ce qui concerne les éléments de chauffage. Les co-signataires reconnaissent avoir reçu chacun un exemplaire du présent état des lieux et s'accordent pour y faire référence lors du départ du locataire
Le présent état des lieux, a été établi contradictoirement entre les parties qui le reconnaissent exact. Le présent état des lieux, a été envoyé par mail au(x) locataire(s) à l'adresse indiqué ci-dessus.
"""
        , validationClauseContractuelleEntree: false, clauseContractuelleSortie: """
         Les soussignés reconnaissent exactes les constatations sur l'état du logement, sous réserve du bon fonctionnement des canalisations, appareils et installations sanitaires, électriques et du chauffage qui n'a pu être vérifié ce jour, toute défectuosité dans le fonctionnement de ceux-ci devant être signalée dans le délai maximum de dix jours, et pendant le premier mois de la période de chauffe en ce qui concerne les éléments de chauffage. Les co-signataires reconnaissent avoir reçu chacun un exemplaire du présent état des lieux et s'accordent pour y faire référence lors du départ du locataire
         Le présent état des lieux, a été établi contradictoirement entre les parties qui le reconnaissent exact. Le présent état des lieux, a été envoyé par mail au(x) locataire(s) à l'adresse indiqué ci-dessus.
         """
        , validationClauseContractuelleSortie: false , libelleSignatureLocataire: "Le présent document est transmis et accepté par le locataire", libelleSignatureBailleur: "Le présent document est transmis et accepté par le propriétaire ou par son mandataire", blocPiedPage:"""
Nom de l'emmetteur, statut juridique
inscription au RCS, code APE
n° de TVA
"""
        )
    
   
    
    
    // MARK: Modeles type
    
    static let modelesTypes: [ModeleEDL] = [
     ModeleEDL(id: UUID(), nomModele: "Garage", typeModele: .typeBien, edl: EDL(), categories: ModeleCategoriesGarage, compteurs: [], entretiens: [], clefs: [], fournitures: [], equipements: []),
     ModeleEDL(id: UUID(), nomModele: "Studio", typeModele: .typeBien, edl: EDL(), categories: ModeleCategoriesStudio, compteurs: [], entretiens: [], clefs: [], fournitures: [], equipements: [])
    ]
    
    static let ModeleCategoriesGarage: [Categorie] = [
        Categorie(nomCategorie: "Clefs",                idBien: UUID(),typeElement: .clef),
        Categorie(nomCategorie: "Fournitures",          idBien: UUID(),typeElement: .fourniture),
        Categorie(nomCategorie: "Garage",               idBien: UUID(),typeElement: .equipement),
        
    ]
    
    static let ModeleCategoriesStudio: [Categorie] = [
        Categorie(nomCategorie: "Compteurs",            idBien: UUID(),typeElement: .compteur),
        Categorie(nomCategorie: "Contrats Entretien",   idBien: UUID(),typeElement: .entretien),
        Categorie(nomCategorie: "Clefs",                idBien: UUID(),typeElement: .clef),
        Categorie(nomCategorie: "Fournitures",          idBien: UUID(),typeElement: .fourniture),
        Categorie(nomCategorie: "Piece principale",     idBien: UUID(),typeElement: .equipement),
        
    ]
    
    

    
   
    
   
    
    
    static func ajoutEDLModele (idBien: UUID) {
        
        
    }
}
