//
//  EquipementsCollectionViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 15/12/2022.
//

import UIKit

private let reuseIdentifier = "cellEquipement"

protocol EquipementsCollectionViewControllerDelegate: AnyObject {
    // Pour la mise en page
    func equipementsCollectionViewController (_ equipementsCollectionViewController: EquipementsCollectionViewController, didModifyEDL  edl: EDL, for actionBien: ActionBien, indexPath: IndexPath )
}
class EquipementsCollectionViewController: UICollectionViewController {
    
    // MARK: - Propriétés
    
    var edl: EDL!
    var indexPath: IndexPath!
    var actionBien: ActionBien!
    var pieceEnCours: Categorie?
    var model = Model()
    var dataSource: DataSourceType!
    
    var delegate: EquipementsCollectionViewControllerDelegate?
    
    
    
    // MARK: - Types
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        
        enum Section: Int, CaseIterable, Hashable, Sequence, IteratorProtocol {
            mutating func next() -> EquipementsCollectionViewController.ViewModel.Section? {
                switch self {
                case .listeReleves:
                    return .listePieces
                case .listePieces:
                    return .listeReleves
                }
            }
            
            case listeReleves
            case listePieces
            var titreSection: String {
                switch self {
                case .listePieces: return "Pièces et annexes"
                case .listeReleves: return "Relevés et fournitures"
                }
            }
        }
        
        enum Item: Hashable {
            
            case compteur (compteur: Compteur)
            case entretien (entretien: Entretien)
            case clef (clef: Clef)
            case equipement(equipement: Equipement)
            case categorie(categorie: Categorie)
            case fourniture (fourniture: Fourniture)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .compteur(let compteur):
                    hasher.combine(compteur.idCompteur.uuidString + String(compteur.idSnapshot))
                case .entretien(let entretien):
                    hasher.combine(entretien.idEntretien.uuidString + String(entretien.idSnapshot))
                case .clef(let clef):
                    hasher.combine(clef.idClef.uuidString + String(clef.idSnapshot))
                case .equipement(let equipement):
                    hasher.combine(equipement.idEquipement.uuidString + String(equipement.idSnapshot))
                case .categorie(let categorie):
                    hasher.combine(categorie.idCategorie.uuidString + String(categorie.idSnapshot))
                case .fourniture(let fourniture):
                    hasher.combine(fourniture.idEquipement.uuidString + String(fourniture.idSnapshot))
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                    
                case (.compteur(let lid), .compteur(let rid)):
                    return lid.idCompteur == rid.idCompteur && lid.idSnapshot == rid.idSnapshot
                case (.entretien(let lid), .entretien(let rid)):
                    return lid.idEntretien == rid.idEntretien && lid.idSnapshot == rid.idSnapshot
                case (.clef(let lid), .clef(let rid)):
                    return lid.idClef == rid.idClef && lid.idSnapshot == rid.idSnapshot
                case (.equipement(let lid), .equipement(let rid)):
                    return lid.idEquipement == rid.idEquipement && lid.idSnapshot == rid.idSnapshot
                case (.categorie(let lid), .categorie(let rid)):
                    // Ajout du nom pour permettre la modification du nom de la catagorie dans le snapshot
                    return lid.idCategorie == rid.idCategorie && lid.idSnapshot == rid.idSnapshot
                    
                case (.fourniture(let lid), .fourniture(let rid)):
          //          return lid.idEquipement == rid.idEquipement && lid.idSnapshot == rid.idSnapshot
                    return lid == rid
                default:
                    return false
                }
            }
        }
    }
    
    struct Model {
        var compteurs : [Compteur] { return CompteurController.shared.compteurs}
        var entretiens : [Entretien] { return EntretienController.shared.entretiens}
        var clefs : [Clef]{ return ClefController.shared.clefs}
        var equipements : [Equipement]{ return EquipementController.shared.equipements}
        var categories : [Categorie] { return CategorieController.shared.categories}
        var fournitures : [Fourniture] { return FournitureController.shared.fournitures}
    }
    
    // MARK: - Cycle de vie
    
    init?(edl: EDL, indexPath: IndexPath, actionBien: ActionBien, coder: NSCoder) {
        self.edl = edl
        self.indexPath = indexPath
        self.actionBien = actionBien
        super.init(coder: coder)
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Initialisation de l'EDL sur lequel on travaille
        // Si on est appelé par le menu avec le push, on a l'EDL positionné dans l'appel, sinon on le recupere du controller
        
       
        
        self.navigationItem.prompt = edl.nomBien
        self.navigationItem.backButtonTitle = "Retour"
        
        _ = EDLsController.selectEDLbyUUID(id: edl.idEDL)
        
        print("----Viewdidload")
        CategorieController.reChargeCategorie()
        CompteurController.reChargeCompteur()
        EntretienController.reChargeEntretien()
        ClefController.reChargeClef()
        EquipementController.reChargeEquipement()
        FournitureController.reChargeFourniture()
        EmetteurController.reChargeEmetteur()
        
        
        dataSource = makeDataSource()
        
        collectionView.dataSource = dataSource
        // Activation reordering
        dataSource.reorderingHandlers.canReorderItem = { item in return true }
        configureLayout()
        applyInitialSnaphot()
        
        downloadAllFichiers()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----ViewWillAppear")
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print ("-----ViewWillDisappear")
        majEDLCountItems()
        
        delegate?.equipementsCollectionViewController(self, didModifyEDL: edl, for: actionBien, indexPath: indexPath)
        
        sauveOrdreAffichagePieces()
        
    }
    
    // MARK: - Fonctions
    
    fileprivate func sauveOrdreAffichagePieces() {
        // Sauvegarde de l'ordre d'affichage des pieces
        let releveSnapshotItems = dataSource.snapshot(for: .listePieces).items
        for i in 0...releveSnapshotItems.count  - 1{
            switch releveSnapshotItems[i] {
            case .categorie(var categorie):
                categorie.ordreAffichage = i
                CategorieController.majCategorie(categorie: categorie)
            default:
                print("")
                
            }
        }
    }
    
    func majEDLCountItems () {
        var nCategorie = 0
        let listeCategories = CategorieController.shared.categories.map{ $0.typeElement }
        if listeCategories.contains(.compteur) {
            edl.nCompteurs = CompteurController.shared.compteurs.count
            nCategorie += 1
            print("+++ Compteur :", CompteurController.shared.compteurs.count)
        }
        if listeCategories.contains(.clef) { edl.nClefs = ClefController.shared.clefs.count
            nCategorie += 1
            print ("+++ Clefs : ", ClefController.shared.clefs.count)
        }
        
        if listeCategories.contains(.fourniture) { edl.nFournitures = FournitureController.shared.fournitures.count
            nCategorie += 1
            print ("+++ Fournitures : ", FournitureController.shared.fournitures.count)
        }
        if listeCategories.contains(.entretien) { edl.nEntretiens = EntretienController.shared.entretiens.count
            nCategorie += 1
            print ("+++ Entretiens : ", EntretienController.shared.entretiens.count)
        }
        edl.nPieces = listeCategories.count - nCategorie
        print ("+++ Pieces : ", listeCategories.count - nCategorie)
        
        if listeCategories.contains(.equipement) { edl.nEquipements = EquipementController.shared.equipements.count
            print ("+++ Equipements : ", EquipementController.shared.equipements.count)
            
        }
        
    }
    
    

    
    
    
    func pushElementDetail(item: ViewModel.Item) {
            switch item {
            case .compteur(let compteur):
           
                // Edition d'un compteur existant
                let storyboard = UIStoryboard(name: "CompteurDetailTableViewController", bundle: .main)
                let compteurDetailTableViewController =
                storyboard.instantiateViewController(identifier: "CompteurDetailTableViewController") { coder in
                    return CompteurDetailTableViewController(compteur: compteur, modeModif: true , coder: coder)
                }
                compteurDetailTableViewController.delegate = self
                navigationController?.pushViewController(compteurDetailTableViewController, animated: true)
          
            case .entretien(let entretien):
                                        
                // Edition d'un contrat d'entretien existant
                let storyboard = UIStoryboard(name: "EntretienDetailTableViewController", bundle: .main)
                let entretienDetailTableViewController =
                storyboard.instantiateViewController(identifier: "EntretienDetailTableViewController") { coder in
                    return EntretienDetailTableViewController(entretien: entretien, modeModif: true , coder: coder)
                }
                entretienDetailTableViewController.delegate = self
                navigationController?.pushViewController(entretienDetailTableViewController, animated: true)
                
                
            case .fourniture(let fourniture):
                // Edition d'une fourniture existant
                let storyboard = UIStoryboard(name: "FournitureDetailTableViewController", bundle: .main)
                let fournitureDetailTableViewController =
                storyboard.instantiateViewController(identifier: "FournitureDetailTableViewController") { coder in
                    return FournitureDetailTableViewController(fourniture: fourniture, modeModif: true , coder: coder)
                }
                fournitureDetailTableViewController.delegate = self
                navigationController?.pushViewController(fournitureDetailTableViewController, animated: true)
                
            case .clef(let clef):
                // Edition d'une clef existante
                let storyboard = UIStoryboard(name: "ClefDetailTableViewController", bundle: .main)
                let clefDetailTableViewController =
                storyboard.instantiateViewController(identifier: "ClefDetailTableViewController") { coder in
                    return ClefDetailTableViewController(clef: clef, modeModif: true , coder: coder)
                }
                clefDetailTableViewController.delegate = self
                navigationController?.pushViewController(clefDetailTableViewController, animated: true)
                
            case .equipement(let equipement):
                // Edition d'un equipement existant sur une pièce
                self.pieceEnCours = CategorieController.categorieByUUID(uuidCategorie: equipement.idCategorie)
                let storyboard = UIStoryboard(name: "EquipementDetailTableViewController", bundle: .main)
                let equipementDetailTableViewController =
                storyboard.instantiateViewController(identifier: "EquipementDetailTableViewController") { coder in
                    return EquipementDetailTableViewController(equipement: equipement, piece: self.pieceEnCours!, modeModif: true , coder: coder)
                }
                equipementDetailTableViewController.delegate = self
                navigationController?.pushViewController(equipementDetailTableViewController, animated: true)
                
            case .categorie(let categorie):
                switch categorie.nomCategorie {
                case libelleCompteur :
                    // Il faut ajouter un compteur
                    performSegue(withIdentifier: "addCompteur", sender: self)
                    
                case libelleContratsEntretien :
                    // Il faut ajouter un contrat d'entretien
                    performSegue(withIdentifier: "addEntretien", sender: self)
                
                case libelleClefs :
                    // Il faut ajouter une clef
                    performSegue(withIdentifier: "addClef", sender: self)
                
                case libelleFournitures :
                    // Il faut ajouter une fourniture
                    performSegue(withIdentifier: "addFourniture", sender: self)
                
                
                    
                default:
                    // On est sur une categorie représentant une pièce
                    self.pieceEnCours = categorie
                    performSegue(withIdentifier: "addEquipement", sender: self)

                    }
            }
    }
    
    
    
    @IBSegueAction func addCompteurversVC(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> CompteurDetailTableViewController? {
        
        let compteurDetailTableViewController = CompteurDetailTableViewController(coder: coder)
            
        compteurDetailTableViewController?.delegate = self
        return compteurDetailTableViewController
        
    }
    
    @IBSegueAction func addEntretienversVC(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> EntretienDetailTableViewController? {
        let entretienDetailTableViewController = EntretienDetailTableViewController(coder: coder)
            
        entretienDetailTableViewController?.delegate = self
        return entretienDetailTableViewController
    }
    
    
    
    
    @IBSegueAction func addClefversVC(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) ->  ClefDetailTableViewController? {
        let clefDetailTableViewController = ClefDetailTableViewController(coder: coder)
        
        clefDetailTableViewController?.delegate = self
        return clefDetailTableViewController
    }
    
   
    @IBSegueAction func addFournitureversVC(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> FournitureDetailTableViewController? {
        let fournitureDetailTableViewController = FournitureDetailTableViewController(coder: coder)
        fournitureDetailTableViewController?.delegate = self
        
        return fournitureDetailTableViewController
    }
    
    
    @IBSegueAction func addEquipementversVC(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> EquipementDetailTableViewController? {
        let equipementDetailTableViewController = EquipementDetailTableViewController(piece: pieceEnCours!, coder: coder)
        equipementDetailTableViewController?.delegate = self
        
        
        return equipementDetailTableViewController
    }
    
    
    
    @IBSegueAction func previsualiserEDLversVC(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> PrevisualiserViewController? {
        return PrevisualiserViewController(edl: self.edl, coder: coder )
    }
    
    
    @IBAction func previsualiserConstatEDL() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let previsualiserViewController =
        storyboard.instantiateViewController(identifier: "PrevisualiserViewController") { coder in
            return PrevisualiserViewController(edl: self.edl, coder: coder)
        }
        
        navigationController?.pushViewController(previsualiserViewController, animated: true)
    }
    
    func addCategorieDynamique() {
        showInputDialog(title: "Ajouter une pièce ou une extension au bien", subtitle: "Entrée, Séjour, Chambre...", inputPlaceholder: "Libellé de la pièce ou extension", inputKeyboardType: .default, actionHandler:  { text , _ , _ in
            if let nomCategorie = text {
                let newCategorie = Categorie(nomCategorie: nomCategorie, idBien: EDLsController.selectedEDLUUID()!, typeElement: .equipement)
                CategorieController.majCategorie(categorie: newCategorie)
                
                self.sauveOrdreAffichagePieces()
                
                self.updateDataSource(for: .listePieces)
                
                if let indexPath = self.dataSource.indexPath(for: ViewModel.Item.categorie(categorie: newCategorie)) {
                    if let cell = self.collectionView.cellForItem(at: indexPath) {
                        cell.alpha = 0
                        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
                        
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            cell.alpha = 1
                            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                            
                        })
                    }
                }
                
                
            }
        })
    }
    
    func majCategorieDynamique(item: ViewModel.Item) {
        let indexPath = dataSource.indexPath(for: item)
        switch item {
        case .categorie(let categorie):
            showInputDialog(title: "Modifier le nom de la pièce", subtitle: "Une piece sans équipement renseigné peut etre supprimée en faisant glisser sur la gauche son intitulé",actionTitle: "Modifier", inputPlaceholder: "Libellé de la pièce ou extension", inputDefaultValue: categorie.nomCategorie, indexPath: indexPath,  inputKeyboardType: .default, actionHandler:  { nouveauNom , ancienNom , indexPath in
  
                guard let nomActuelCategorie = ancienNom,
                      let nomCategorieModif = nouveauNom else { return }
                let actuelleCategorie = CategorieController.categorieByNom(nomCategorie: nomActuelCategorie)
                
                var nouvelleCategorie = actuelleCategorie
                nouvelleCategorie.nomCategorie = nomCategorieModif
                nouvelleCategorie.idSnapshot = actuelleCategorie.idSnapshot + 1
                
                CategorieController.renommeCategorie(idActuelleCategorie: actuelleCategorie.idCategorie, idNouvellecategorie: actuelleCategorie.idCategorie, nouvNom: nomCategorieModif)
                
                var newSectionSnapshot = self.dataSource.snapshot(for: .listePieces)
                let isExpand: Bool = newSectionSnapshot.isExpanded(ViewModel.Item.categorie(categorie: actuelleCategorie))
                
                newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: nouvelleCategorie)], after: ViewModel.Item.categorie(categorie: actuelleCategorie))
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: actuelleCategorie)])
                
                // On recree les equipements rattachés car ils ont été supprimés
                for equipement in self.model.equipements {
                    let categorieEquipementUUID = equipement.idCategorie
                    if categorieEquipementUUID == nouvelleCategorie.idCategorie {
                        newSectionSnapshot.append([ViewModel.Item.equipement(equipement: equipement)], to: ViewModel.Item.categorie(categorie: nouvelleCategorie) )
                    }
                    
                }
                // On restaure l'expand de l'item
                if isExpand {
                    newSectionSnapshot.expand([ ViewModel.Item.categorie(categorie: nouvelleCategorie)])
                }
                self.dataSource.apply(newSectionSnapshot, to: .listePieces, animatingDifferences: true)
                
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
                
            })
        default:
            print("Cas non prévu")
        }
                
    }
    
    
    
    func supprimerElement (indexPath: IndexPath ) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .compteur(let compteur):
                CompteurController.supprCompteur(compteur: compteur)
                var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
                
                guard let itemcategorieCompteur = newSectionSnapshot.parent(of: ViewModel.Item.compteur(compteur: compteur)) else { return }
                guard case let ViewModel.Item.categorie(categorie: categorieCompteur) = itemcategorieCompteur else { return }
                var newCategorieCompteur = categorieCompteur
                    
                // Hack pour contourner l'unicité
                newCategorieCompteur.idSnapshot = categorieCompteur.idSnapshot + 1
                    
                newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieCompteur)], after: ViewModel.Item.categorie(categorie: categorieCompteur))
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieCompteur)])
                    
                    
                // On recree les compteurs rattachés car ils ont été supprimés
                for compteurBoucle in self.model.compteurs {
                    // On ajoute sauf le compteur supprimé
                    if compteurBoucle.idCompteur != compteur.idCompteur {
                        newSectionSnapshot.append([ViewModel.Item.compteur(compteur: compteurBoucle)], to: ViewModel.Item.categorie(categorie: newCategorieCompteur) )
                    }
                }
                    
                newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieCompteur)])
                
                
                dataSource.apply(newSectionSnapshot, to: .listeReleves)
           
                        
            case .entretien(let entretien):
                EntretienController.supprEntretien(entretien: entretien)
                var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
                
                guard let itemcategorieEntretien = newSectionSnapshot.parent(of: ViewModel.Item.entretien(entretien: entretien)) else { return }
                guard case let ViewModel.Item.categorie(categorie: categorieEntretien) = itemcategorieEntretien else { return }
                var newCategorieEntretien = categorieEntretien
                    
                // Hack pour contourner l'unicité
                newCategorieEntretien.idSnapshot = categorieEntretien.idSnapshot + 1
                    
                newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieEntretien)], after: ViewModel.Item.categorie(categorie: categorieEntretien))
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieEntretien)])
                    
                    
                // On recree les entretiens rattachés car ils ont été supprimés
                for entretienBoucle in self.model.entretiens {
                    // On ajoute sauf le entretien supprimé
                    if entretienBoucle.idEntretien != entretien.idEntretien {
                        newSectionSnapshot.append([ViewModel.Item.entretien(entretien: entretienBoucle)], to: ViewModel.Item.categorie(categorie: newCategorieEntretien) )
                    }
                }
                    
                newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieEntretien)])
                
                
                dataSource.apply(newSectionSnapshot, to: .listeReleves)
           
            case .clef(let clef):
                ClefController.supprClef(clef: clef)
                var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
                
                guard let itemcategorieClef = newSectionSnapshot.parent(of: ViewModel.Item.clef(clef: clef)) else { return }
                guard case let ViewModel.Item.categorie(categorie: categorieClef) = itemcategorieClef else { return }
                var newCategorieClef = categorieClef
                    
                // Hack pour contourner l'unicité
                newCategorieClef.idSnapshot = categorieClef.idSnapshot + 1
                    
                newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieClef)], after: ViewModel.Item.categorie(categorie: categorieClef))
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieClef)])
                    
                    
                // On recree les clefs rattachés car ils ont été supprimés
                for clefBoucle in self.model.clefs {
                    // On ajoute sauf le clef supprimé
                    if clefBoucle.idClef != clef.idClef {
                        newSectionSnapshot.append([ViewModel.Item.clef(clef: clefBoucle)], to: ViewModel.Item.categorie(categorie: newCategorieClef) )
                    }
                }
                    
                newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieClef)])
                
                
                dataSource.apply(newSectionSnapshot, to: .listeReleves)
           
            case .fourniture(let fourniture):
                FournitureController.supprFourniture(fourniture: fourniture)
                var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
                
                guard let itemcategorieFourniture = newSectionSnapshot.parent(of: ViewModel.Item.fourniture(fourniture: fourniture)) else { return }
                guard case let ViewModel.Item.categorie(categorie: categorieFourniture) = itemcategorieFourniture else { return }
                var newCategorieFourniture = categorieFourniture
                    
                // Hack pour contourner l'unicité
                newCategorieFourniture.idSnapshot = categorieFourniture.idSnapshot + 1
                    
                newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieFourniture)], after: ViewModel.Item.categorie(categorie: categorieFourniture))
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieFourniture)])
                    
                    
                // On recree les fournitures rattachés car ils ont été supprimés
                for fournitureBoucle in self.model.fournitures {
                    // On ajoute sauf le fourniture supprimé
                    if fournitureBoucle.idEquipement != fourniture.idEquipement {
                        newSectionSnapshot.append([ViewModel.Item.fourniture(fourniture: fournitureBoucle)], to: ViewModel.Item.categorie(categorie: newCategorieFourniture) )
                    }
                }
                    
                newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieFourniture)])
                
                
                dataSource.apply(newSectionSnapshot, to: .listeReleves)
                
            case .equipement(let equipement):
                EquipementController.supprEquipement(equipement: equipement)
                var newSectionSnapshot = self.dataSource.snapshot(for: .listePieces)
                
                guard let itemcategorieEquipement = newSectionSnapshot.parent(of: ViewModel.Item.equipement(equipement: equipement)) else { return }
                guard case let ViewModel.Item.categorie(categorie: categorieEquipement) = itemcategorieEquipement else { return }
                var newCategorieEquipement = categorieEquipement
                    
                // Hack pour contourner l'unicité
                newCategorieEquipement.idSnapshot = categorieEquipement.idSnapshot + 1
                    
                newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieEquipement)], after: ViewModel.Item.categorie(categorie: categorieEquipement))
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieEquipement)])
                    
                    
                // On recree les fournitures rattachés car ils ont été supprimés
                for equipementBoucle in self.model.equipements {
                    if equipementBoucle.idCategorie == newCategorieEquipement.idCategorie {
                        // On ajoute sauf le fourniture supprimé
                        if equipementBoucle.idEquipement != equipement.idEquipement {
                            newSectionSnapshot.append([ViewModel.Item.equipement(equipement: equipementBoucle)], to: ViewModel.Item.categorie(categorie: newCategorieEquipement) )
                        }
                    }
                }
                    
                newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieEquipement)])
                
                
                dataSource.apply(newSectionSnapshot, to: .listePieces)
           
            case .categorie(let categorie):
                CategorieController.supprCategorie(categorie: categorie)
                var newSectionSnapshot = self.dataSource.snapshot(for: .listePieces)
                newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorie)])
                self.dataSource.apply(newSectionSnapshot, to: .listePieces, animatingDifferences: true)
 
            default:
                print("Pas encore implementé")
            }
        }
    }
    
    
    @IBAction func previsualiserAction(_ sender: Any) {
        
        performSegue(withIdentifier: "previsualiserSegue" , sender: self)
    }
    
    @IBAction func unwindToEquipements(_ unwindSegue: UIStoryboardSegue) {
        if  let sourceViewController = unwindSegue.source as? CompteurDetailTableViewController {
            if let compteur = sourceViewController.compteur {
                CompteurController.majCompteur(compteur: compteur)
            }
        }
        
        if  let sourceViewController = unwindSegue.source as? EntretienDetailTableViewController {
            if let entretien = sourceViewController.entretien {
                EntretienController.majEntretien(entretien: entretien)
            }
        }
        
        if  let sourceViewController = unwindSegue.source as? ClefDetailTableViewController {
            if let clef = sourceViewController.clef {
                ClefController.majClef(clef: clef)
            }
        }
        if  let sourceViewController = unwindSegue.source as? FournitureDetailTableViewController {
            if let fourniture = sourceViewController.fourniture {
                FournitureController.majFourniture(fourniture: fourniture)
            }
        }
        if  let sourceViewController = unwindSegue.source as? EquipementDetailTableViewController {
            if let equipement = sourceViewController.equipement {
                EquipementController.majEquipement(equipement: equipement)
            }
        }
        
        if  unwindSegue.source is PrevisualiserViewController {
            print("Retour de prévisualisation")
        }
        
    }
    
    
    
    
    
    // MARK: - CollectionView
    
    func configureLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        // configuration.headerMode = .firstItemInSection
        
        // Entete
        configuration.headerMode = .supplementary
        
        // Configuration des actions swipe trailing
        configuration.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            
            var actifSwipe: Bool = false
            if let item = self.dataSource.itemIdentifier(for: indexPath) {
                switch item {
                case .categorie(let categorie):
                    if categorie.typeElement == .equipement && EquipementController.nombreEquipements(idCategorie: categorie.idCategorie) == 0 {
                        actifSwipe = true
                    }
                case .clef(_) , .compteur(_), .fourniture(_), .equipement(_), .entretien(_):
                    actifSwipe = true
                }
            }
            if actifSwipe {
                let del = UIContextualAction(style: .destructive, title: "Supprimer") {
                    action, view, completion in
                    self.supprimerElement(indexPath: indexPath)
                    // self?.delete(self)
                    completion(true)
                }
                
                return .init(actions: [del])
            } else {
                return .init(actions: [])
            }
        }
        configuration.showsSeparators = true
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            collectionView.deselectItem(at: indexPath, animated: false)
            pushElementDetail(item: item)
        }
        
        
    }
    
   
    // Evite de déplacer une cellule hors de sa section
    override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        print("here")
        if originalIndexPath.section == proposedIndexPath.section {
            return proposedIndexPath
        }
        return originalIndexPath
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated:animated)
        self.collectionView.isEditing = editing
    }
    

    
    // MARK: - Datasource - Snapshot
    
    func makeDataSource () -> DataSourceType {
        
        
        
        let compteurCellRegistration = UICollectionView.CellRegistration<CompteurCollectionViewCell,ViewModel.Item> {
            cell, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .compteur(let compteur):
                cell.compteur = compteur
                
            default:
                print("toto")
            }
        }
        
        let entretienCellRegistration = UICollectionView.CellRegistration<EntretienCollectionViewCell,ViewModel.Item> {
            cell, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .entretien(let entretien):
                cell.entretien = entretien
                
            default:
                print("toto")
            }
        }
        
        let clefCellRegistration = UICollectionView.CellRegistration<ClefCollectionViewCell,ViewModel.Item> {
            cell, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .clef(let clef):
                cell.clef = clef
            default:
                print("toto")
            }
        }
        
        let fournitureCellRegistration = UICollectionView.CellRegistration<FournitureCollectionViewCell,ViewModel.Item> {
            cell, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .fourniture(let fourniture):
                cell.fourniture = fourniture
            default:
                print("toto")
            }
        }
        
        let equipementCellRegistration = UICollectionView.CellRegistration<EquipementCollectionViewCell,ViewModel.Item> {
            cell, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .equipement(let equipement):
                cell.equipement = equipement
            default:
                print("toto")
            }
        }
        
        
        let genericCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell,ViewModel.Item> {
            cell, indexPath, itemIdentifier in
            
            var configuration = cell.defaultContentConfiguration()
            
            
            let nClef = self.model.clefs.count
            let nEntretien = self.model.entretiens.count
            let nCompteur = self.model.compteurs.count
            let nFourniture = self.model.fournitures.count
            
            
            var cellAccessorie = [UICellAccessory]()
            
            
            // Accessoire pour les items de type catégories dynamiques ainsi que les items de détail (en fait seul les catégories Compteur, Clef, Entretien ne l'on pas)  -> modification
        
            let detailAccessoryOptions = UICellAccessory.DetailOptions(isHidden: false,
                                                                       //reservedLayoutWidth: .custom(40),
                                                                       tintColor: .vertEDL)
          
            let cellAccessoryDetail = UICellAccessory.detail(displayed: .whenNotEditing, options: detailAccessoryOptions) {
                self.majCategorieDynamique( item: itemIdentifier)
                print("Push Detail")
            }

            
            // Accessoire pour les items de type categories Compteur, Clef, Entretien,  ET les catégories dynamiques
            let outlineDisclosureAccessoryOptions = UICellAccessory.OutlineDisclosureOptions(style: .header , isHidden: false,  tintColor: .vertEDL)
            let cellAccessoryOutlineDisclosureEquipement = UICellAccessory.outlineDisclosure(displayed: .whenNotEditing, options: outlineDisclosureAccessoryOptions)
            let cellAccessoryOutlineDisclosureAutre = UICellAccessory.outlineDisclosure(options: outlineDisclosureAccessoryOptions)
            
            
            
            // Accessoire pour les items de type categories Compteur, Clef, Entretien,  ET les catégories dynamiques-> ajout
            // Accessoire custom : Insert en trailing
            
            let insertButton = UIButton()
            insertButton.addAction(UIAction {_ in
                self.pushElementDetail( item: itemIdentifier)
                print("Push Insert")
            }, for: .allTouchEvents)
            var configButton = UIButton.Configuration.plain()
            configButton.image = UIImage(systemName: "plus.circle")
            insertButton.configuration = configButton
            
            // Accessoire insert pour les equipement qui se place après le détail
            let customAccessoryEquipement = UICellAccessory.CustomViewConfiguration( customView: insertButton, placement: .trailing(displayed: .whenNotEditing, at: UICellAccessory.Placement.position(after: cellAccessoryDetail)), tintColor: .vertEDL)
            let cellAccessoryCustomInsertEquipement = UICellAccessory.customView(configuration: customAccessoryEquipement)
            
            // Accessoire insert pour les autres sans spécification d'ordre
            let customAccessoryAutre = UICellAccessory.CustomViewConfiguration( customView: insertButton, placement: .trailing(displayed: .always), tintColor: .vertEDL)
            let cellAccessoryCustomInsertAutre = UICellAccessory.customView(configuration: customAccessoryAutre)
                                                                                
            
            
            
            
            
             let reorder = UICellAccessory.reorder()
            
            
            switch itemIdentifier {
            case .clef(let clef):
                configuration.text = clef.intituleClef
                cellAccessorie = []
            case .compteur(let compteur):
                configuration.text = compteur.nomCompteur
                cellAccessorie = []
            case.entretien(let entretien):
                configuration.text = entretien.intitule
                cellAccessorie = []
            case.fourniture(let fourniture):
                configuration.text = fourniture.equipement
                cellAccessorie = []
            case.equipement(let equipement):
                configuration.text = equipement.equipement
                cellAccessorie = []
            case .categorie(let categorie):
                configuration.text = categorie.nomCategorie
                
                if #available(iOS 16.0, *) {
                    var configurationBackground = cell.defaultBackgroundConfiguration()
                    configurationBackground.backgroundColor = .systemGroupedBackground
                    configurationBackground.cornerRadius = 8
                    cell.backgroundConfiguration = configurationBackground
                }
                
                switch categorie.typeElement {
                case .clef:
                    configuration.text = categorie.nomCategorie + ( nClef > 0 ? " (\(String(nClef)))" : "")
                    configuration.image = UIImage(systemName: "key")
                    cellAccessorie = [cellAccessoryOutlineDisclosureAutre, cellAccessoryCustomInsertAutre]
                case .compteur:
                    configuration.text = categorie.nomCategorie + ( nCompteur > 0 ? " (\(String(nCompteur)))" : "")
                    configuration.image = UIImage(systemName: "arrow.counterclockwise.circle")
                    cellAccessorie = [cellAccessoryOutlineDisclosureAutre, cellAccessoryCustomInsertAutre]
                case .entretien:
                    configuration.text = categorie.nomCategorie + ( nEntretien > 0 ? " (\(String(nEntretien)))" : "")
                    configuration.image = UIImage(systemName: "doc.append")
                    cellAccessorie = [cellAccessoryOutlineDisclosureAutre, cellAccessoryCustomInsertAutre]
                case .fourniture:
                    configuration.text = categorie.nomCategorie + ( nFourniture > 0 ? " (\(String(nFourniture)))" : "")
                    configuration.image = UIImage(systemName: "homekit")
                    cellAccessorie = [cellAccessoryOutlineDisclosureAutre, cellAccessoryCustomInsertAutre]
                case .categorie:
                    
                    configuration.text = categorie.nomCategorie
                    configuration.image = UIImage(systemName: "photo")
                case .equipement:
                    let tabItem = self.model.equipements.map { $0.idCategorie }
                    let nItem = tabItem.filter{ $0 == categorie.idCategorie}.count
                    
                    
                    
                    configuration.text = categorie.nomCategorie + ( nItem > 0 ? " (\(String(nItem)))" : "")
                    configuration.image = UIImage(systemName: "puzzlepiece")
                    cellAccessorie = [cellAccessoryOutlineDisclosureEquipement, cellAccessoryDetail, reorder, cellAccessoryCustomInsertEquipement]
                }
            }
            cell.contentConfiguration = configuration
            
            cell.accessories = cellAccessorie
            
            
        }
        
        let dataSource = DataSourceType (collectionView: collectionView)
            { collectionView , indexPath, item -> UICollectionViewCell? in
                
                switch item {
                case .compteur:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: compteurCellRegistration, for: indexPath, item: item)
                    return cell
                case .entretien:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: entretienCellRegistration, for: indexPath, item: item)
                    return cell
                case .clef:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: clefCellRegistration, for: indexPath, item: item)
                    return cell
                case .fourniture:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: fournitureCellRegistration, for: indexPath, item: item)
                    return cell
                case .equipement:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: equipementCellRegistration, for: indexPath, item: item)
                    return cell
                default:
                    let cell = collectionView.dequeueConfiguredReusableCell(using: genericCellRegistration, for: indexPath, item: item)
                    return cell
                }}
        
        // Ajout de l'entete de section pour les relevés (sans bouton ajout)
        
        let headerRegistrationReleves = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader) { [ unowned self] (supplementaryView,elementKind,indexPath) in
                // Obtain header item
                let headerItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                
                // Configure head er view content based on headerItem
                var configuration = supplementaryView.defaultContentConfiguration()
                configuration.text = headerItem.titreSection
                
                // Customize header appearance
                configuration.textProperties.font = .boldSystemFont(ofSize: 16)
                configuration.textProperties.color = .systemBlue
                configuration.directionalLayoutMargins = .init(top: 20.0, leading: 0.0, bottom: 10.0, trailing: 0.0)
                
                supplementaryView.contentConfiguration = configuration
                
                
            }
        // Ajout de l'entete de section pour les pieces (avec un bouton d'ajout)
        let headerRegistrationPieces = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader) { [ unowned self] (supplementaryView,elementKind,indexPath) in
                // Obtain header item
                let headerItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                
                // Configure header view content based on headerItem
                var configuration = supplementaryView.defaultContentConfiguration()
                configuration.text = headerItem.titreSection
                
                // Customize header appearance
                configuration.textProperties.font = .boldSystemFont(ofSize: 16)
                configuration.textProperties.color = .systemBlue
                configuration.directionalLayoutMargins = .init(top: 20.0, leading: 0.0, bottom: 10.0, trailing: 0.0)
                
                supplementaryView.contentConfiguration = configuration
                
                // On regarde si un bouton Ajouter a été créé dans un traitement précédent (tag = 1 pour une subview)
                if (supplementaryView.subviews.map { $0.tag }.filter {$0 == 1 }.count == 0) {
                    // Bouton d'ajout de catégorie
                    let button = UIButton()
                    button.tag = 1
                    
                    var buttonConfiguration = UIButton.Configuration.plain()
               //     buttonConfiguration.title = "Ajouter"
                    buttonConfiguration.title = ""
                    buttonConfiguration.image = UIImage(systemName: "plus.circle")
                    buttonConfiguration.imagePlacement = .trailing
                    buttonConfiguration.buttonSize = .medium
                    
                    button.addAction(UIAction  {_ in
                        self.addCategorieDynamique()
                    }, for: .touchDown)
                    button.configuration = buttonConfiguration
                    supplementaryView.addSubview(button)
                    
                    //Set constraints as per your requirements
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.trailingAnchor.constraint(equalTo: supplementaryView.trailingAnchor, constant: -20).isActive = true
                    button.topAnchor.constraint(equalTo: supplementaryView.topAnchor, constant: 10).isActive = true
                    button.widthAnchor.constraint(equalToConstant: 30).isActive = true
                    
                    // Boutton de modification d'ordre
                    let buttonModif = UIButton()
                    
                    
                    var buttonModifConfiguration = UIButton.Configuration.plain()
               //     buttonConfiguration.title = "Ajouter"
                    buttonModifConfiguration.title = ""
                    buttonModifConfiguration.image = UIImage(systemName: "arrow.up.and.down")
                    buttonModifConfiguration.imagePlacement = .trailing
                    buttonModifConfiguration.buttonSize = .medium
                    
                    buttonModif.addAction(UIAction  {_ in
                        self.setEditing(!self.isEditing, animated: true)
                        if !self.isEditing { self.sauveOrdreAffichagePieces() }
                        
                    }, for: .touchDown)
                    buttonModif.configurationUpdateHandler = { [unowned self] button in
                      // 1
                      var config = button.configuration

                      // 2
                      let symbolName = self.isEditing ? "arrow.up.and.down.circle.fill" : "arrow.up.and.down.circle"
                      config?.image = UIImage(systemName: symbolName)

                      // 3
                      button.configuration = config
                    }
                    
                    buttonModif.configuration = buttonModifConfiguration
                    supplementaryView.addSubview(buttonModif)
                    
                    //Set constraints as per your requirements
                    buttonModif.translatesAutoresizingMaskIntoConstraints = false
                    buttonModif.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10).isActive = true
                    buttonModif.topAnchor.constraint(equalTo: supplementaryView.topAnchor, constant: 10).isActive = true
                    buttonModif.widthAnchor.constraint(equalToConstant: 30).isActive = true
                    
                    
                }
                
            }
        
        
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            if elementKind == UICollectionView.elementKindSectionHeader {
        
                let headerItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                switch headerItem {
                case .listeReleves:
                    return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistrationReleves, for: indexPath)
                case .listePieces:
                    return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistrationPieces, for: indexPath)
                }
            } else { return nil }
        }
        
        return dataSource
    }
    
    
    func sauveEtatExpanded( section: ViewModel.Section ) -> [ViewModel.Item] {
        let snapshotSection = dataSource.snapshot(for: section)
     
        // Sauvegarde des états expanded
        let items = snapshotSection.items
        var itemsExpanded: [ViewModel.Item] = []
        for item in items {
            if snapshotSection.isExpanded(item) { itemsExpanded.append(item)}
        }
        return itemsExpanded
    }
    
    
    
    func updateDataSource (for item: ViewModel.Item) {
       // Maj pour un item existant
        
        guard let indexPath = dataSource.indexPath(for: item),
              let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else { print ("---- Maj pour un ITEM KO")
            return }
        print("---- Maj pour un ITEM \(sectionIdentifier )")
        let etatExpand = sauveEtatExpanded(section: sectionIdentifier)
        applySnapshotSection(section: sectionIdentifier, etatExpanded: etatExpand)
        
    }
    
    func updateDataSource (for section: ViewModel.Section) {
        // Maj sur une section complete
        let etatExpand = sauveEtatExpanded(section: section)
        applySnapshotSection(section: section, etatExpanded: etatExpand)
        
    }
        
        
   
    
    func applyInitialSnaphot () {
        var snapshot = NSDiffableDataSourceSnapshot<ViewModel.Section, ViewModel.Item>()
        snapshot.appendSections([.listeReleves, .listePieces])
        dataSource.apply(snapshot)
        
        for section in ViewModel.Section.allCases {
            applySnapshotSection(section: section, etatExpanded: nil )
        }
        
    }
    
    
    func applySnapshotSection(section: ViewModel.Section , etatExpanded: [ViewModel.Item]? ) {
        
        if section == .listeReleves {
            // Snapshot pour les relevés
            var releveSnapshot = NSDiffableDataSourceSectionSnapshot<ViewModel.Item>()
            for categorie in model.categories {
                
                
                
                switch categorie.typeElement {
                case .compteur:
                    let categorieItem = ViewModel.Item.categorie(categorie: categorie)
                    releveSnapshot.append([categorieItem])
                    var releveItem = [ViewModel.Item]()
                    for compteur in model.compteurs {
                        releveItem.append(ViewModel.Item.compteur(compteur: compteur))
                    }
                    releveSnapshot.append(releveItem, to: categorieItem)
                case .entretien:
                    let categorieItem = ViewModel.Item.categorie(categorie: categorie)
                    releveSnapshot.append([categorieItem])
                    var releveItem = [ViewModel.Item]()
                    for entretien in model.entretiens {
                        releveItem.append(ViewModel.Item.entretien(entretien: entretien))
                    }
                    releveSnapshot.append(releveItem, to: categorieItem)
                case .clef:
                    let categorieItem = ViewModel.Item.categorie(categorie: categorie)
                    releveSnapshot.append([categorieItem])
                    var releveItem = [ViewModel.Item]()
                    for clef in model.clefs {
                        releveItem.append(ViewModel.Item.clef(clef: clef))
                    }
                    releveSnapshot.append(releveItem, to: categorieItem)
                case .fourniture:
                    let categorieItem = ViewModel.Item.categorie(categorie: categorie)
                    releveSnapshot.append([categorieItem])
                    var releveItem = [ViewModel.Item]()
                    for fourniture in model.fournitures {
                        releveItem.append(ViewModel.Item.fourniture(fourniture: fourniture))
                    }
                    releveSnapshot.append(releveItem, to: categorieItem)
                
                default:
                    continue
                }
            }
            
            
            if let etatExpandedVar = etatExpanded { releveSnapshot.expand(etatExpandedVar)}
            
            dataSource.apply(releveSnapshot, to: .listeReleves, animatingDifferences: true)
            
            
        }
        
        if section == .listePieces {
            // Snapshot pour les pièces (categories dynamiques)
            var pieceSnapshot = NSDiffableDataSourceSectionSnapshot<ViewModel.Item>()
            
            // dictionnaire qui permet de reconstituer la liste des equipements par categorie définis dynamiquement (pièce ou autre)
            var itemsByCategorieDynamique = [ Categorie : [ViewModel.Item]]()
            
            
            
            for categorie in model.categories {
                
                switch categorie.typeElement {
                case .equipement:
                    for equipement in model.equipements {
                        let categorieEquipementUUID = equipement.idCategorie
                        if categorieEquipementUUID == categorie.idCategorie {
                            // On est sur un élément à rattacher à la catagorie dynamique
                            itemsByCategorieDynamique[categorie] == nil ? itemsByCategorieDynamique[categorie] = [ViewModel.Item.equipement(equipement: equipement)] : itemsByCategorieDynamique[categorie]?.append(ViewModel.Item.equipement(equipement: equipement))
                            
                        } }
                    if itemsByCategorieDynamique[categorie] == nil {
                        // On est sur une categorie qui n'a pas encore d'équipement
                        itemsByCategorieDynamique[categorie] = [ ]
                    }
                default:
                    continue
                }
            }
            // On ajoute toutes les catagories dynamiques tracées dans la boucle précédente
     //       let sortedItemsByCategorieDynamique = itemsByCategorieDynamique.sorted( by: { $0.0 < $1.0 })
            let sortedItemsByCategorieDynamique = itemsByCategorieDynamique.sorted( by: { $0.0.ordreAffichage ?? 9999 < $1.0.ordreAffichage ?? 9999 })
     
            sortedItemsByCategorieDynamique.forEach() {
                (categorieRegroupement , tabEquipement) in
                let categorieItem = ViewModel.Item.categorie(categorie: categorieRegroupement)
                pieceSnapshot.append([categorieItem])
                pieceSnapshot.append(tabEquipement, to: categorieItem)
            }
            if let etatExpandedVar = etatExpanded { pieceSnapshot.expand(etatExpandedVar)}
            dataSource.apply(pieceSnapshot, to: .listePieces, animatingDifferences: true)
            
        }
    }
    
}
   // MARK: - CompteurDetailTableViewControllerDelegate
extension EquipementsCollectionViewController: CompteurDetailTableViewControllerDelegate {
    
    
    func compteurDetailTableViewController(_ compteurDetailTableViewController: CompteurDetailTableViewController?, didModifyCompteur compteur: Compteur) {
        
        var isModif: Bool
        if let compteurDetailTableViewController = compteurDetailTableViewController {
            isModif = compteurDetailTableViewController.modeModif
        } else {
            isModif = true
        }
        
        CompteurController.majCompteur(compteur: compteur)
        // Première mise à jour pour inclure le nouveau compteur dans le snapshot
        updateDataSource(for: .listeReleves)
        
   
        var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
        guard let itemcategorieCompteur = newSectionSnapshot.parent(of: ViewModel.Item.compteur(compteur: compteur)) else { return }
        
        if !isModif {
            // On a cree un compteur, il faut mettre à jour le nombre de compteur dans le titre
            // On supprime et recree la categorie compteur en mettant un blanc en fin du nom pour éviter le doublon  et les items enfants
            
            guard case let ViewModel.Item.categorie(categorie: categorieCompteur) = itemcategorieCompteur else { return }
            var newCategorieCompteur = categorieCompteur
            
            // Hack pour contourner l'unicité
            newCategorieCompteur.idSnapshot = categorieCompteur.idSnapshot + 1
            
            
            newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieCompteur)], after: ViewModel.Item.categorie(categorie: categorieCompteur))
            newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieCompteur)])
            
            
            // On recree les compteurs rattachés car ils ont été supprimés (dont le nouveau compyeur)
            for compteur in self.model.compteurs {
                newSectionSnapshot.append([ViewModel.Item.compteur(compteur: compteur)], to: ViewModel.Item.categorie(categorie: newCategorieCompteur) )
            }
            
            newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieCompteur)])
            dataSource.apply(newSectionSnapshot, to: .listeReleves)
        
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.compteur(compteur: compteur)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            
            
            
        } else {
            // Mise à jour du compteur
            // Supprime et recree le compteur dan le snapshot pour forcer la mise à jour
            var newCompteur = compteur
            newCompteur.idSnapshot = compteur.idSnapshot + 1
            newSectionSnapshot.insert([ViewModel.Item.compteur(compteur: newCompteur)], after: ViewModel.Item.compteur(compteur: compteur))
            newSectionSnapshot.delete([ViewModel.Item.compteur(compteur: compteur)])
            
            
            newSectionSnapshot.expand([itemcategorieCompteur])
            dataSource.apply(newSectionSnapshot, to: .listeReleves)
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.compteur(compteur: newCompteur)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
        }
        
    
    }
}
       
// MARK: - EntretienDetailTableViewControllerDelegate
extension EquipementsCollectionViewController: EntretienDetailTableViewControllerDelegate {
 func entretienDetailTableViewController(_ entretienDetailTableViewController: EntretienDetailTableViewController, didModifyEntretien entretien: Entretien) {
     
     EntretienController.majEntretien(entretien: entretien)
     // Première mise à jour pour inclure le nouveau entretien dans le snapshot
     updateDataSource(for: .listeReleves)
     

     var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
     guard let itemcategorieEntretien = newSectionSnapshot.parent(of: ViewModel.Item.entretien(entretien: entretien)) else { return }
     
     if !entretienDetailTableViewController.modeModif {
         // On a cree un entretien, il faut mettre à jour le nombre de entretien dans le titre
         // On supprime et recree la categorie entretien en mettant un blanc en fin du nom pour éviter le doublon  et les items enfants
         
         guard case let ViewModel.Item.categorie(categorie: categorieEntretien) = itemcategorieEntretien else { return }
         var newCategorieEntretien = categorieEntretien
         
         // Hack pour contourner l'unicité
         newCategorieEntretien.idSnapshot = categorieEntretien.idSnapshot + 1
         
         
         newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieEntretien)], after: ViewModel.Item.categorie(categorie: categorieEntretien))
         newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieEntretien)])
         
         
         // On recree les entretiens rattachés car ils ont été supprimés (dont le nouveau compyeur)
         for entretien in self.model.entretiens {
             newSectionSnapshot.append([ViewModel.Item.entretien(entretien: entretien)], to: ViewModel.Item.categorie(categorie: newCategorieEntretien) )
         }
         
         newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieEntretien)])
         dataSource.apply(newSectionSnapshot, to: .listeReleves)
     
         if let indexPath = dataSource.indexPath(for: ViewModel.Item.entretien(entretien: entretien)) {
             collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
         }
         
         
         
     } else {
         // Mise à jour du entretien
         // Supprime et recree le entretien dan le snapshot pour forcer la mise à jour
         var newEntretien = entretien
         newEntretien.idSnapshot = entretien.idSnapshot + 1
         newSectionSnapshot.insert([ViewModel.Item.entretien(entretien: newEntretien)], after: ViewModel.Item.entretien(entretien: entretien))
         newSectionSnapshot.delete([ViewModel.Item.entretien(entretien: entretien)])
         
         
         newSectionSnapshot.expand([itemcategorieEntretien])
         dataSource.apply(newSectionSnapshot, to: .listeReleves)
         if let indexPath = dataSource.indexPath(for: ViewModel.Item.entretien(entretien: newEntretien)) {
             collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
         }
     }
     
 
 }
}

// MARK: - ClefDetailTableViewControllerDelegate

extension EquipementsCollectionViewController: ClefDetailTableViewControllerDelegate {
    func clefDetailTableViewController (_ clefDetailTableViewController: ClefDetailTableViewController, didModifyClef  clef: Clef ) {
        
        ClefController.majClef(clef: clef)
        // Première mise à jour pour inclure le nouveau clef dans le snapshot
        updateDataSource(for: .listeReleves)
        

        var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
        guard let itemcategorieClef = newSectionSnapshot.parent(of: ViewModel.Item.clef(clef: clef)) else { return }
        
        if !clefDetailTableViewController.modeModif {
            // On a cree un clef, il faut mettre à jour le nombre de clef dans le titre
            // On supprime et recree la categorie clef en mettant un blanc en fin du nom pour éviter le doublon  et les items enfants
            
            guard case let ViewModel.Item.categorie(categorie: categorieClef) = itemcategorieClef else { return }
            var newCategorieClef = categorieClef
            
            // Hack pour contourner l'unicité
            newCategorieClef.idSnapshot = categorieClef.idSnapshot + 1
            
            
            newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieClef)], after: ViewModel.Item.categorie(categorie: categorieClef))
            newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieClef)])
            
            
            // On recree les clefs rattachés car ils ont été supprimés (dont le nouveau compyeur)
            for clef in self.model.clefs {
                newSectionSnapshot.append([ViewModel.Item.clef(clef: clef)], to: ViewModel.Item.categorie(categorie: newCategorieClef) )
            }
            
            newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieClef)])
            dataSource.apply(newSectionSnapshot, to: .listeReleves)
        
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.clef(clef: clef)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            
            
            
        } else {
            // Mise à jour du clef
            // Supprime et recree le clef dan le snapshot pour forcer la mise à jour
            var newClef = clef
            newClef.idSnapshot = clef.idSnapshot + 1
            newSectionSnapshot.insert([ViewModel.Item.clef(clef: newClef)], after: ViewModel.Item.clef(clef: clef))
            newSectionSnapshot.delete([ViewModel.Item.clef(clef: clef)])
            
            
            newSectionSnapshot.expand([itemcategorieClef])
            dataSource.apply(newSectionSnapshot, to: .listeReleves)
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.clef(clef: newClef)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
        }
        
        
        
        
    }
}


// MARK: - FournitureDetailTableViewControllerDelegate

extension EquipementsCollectionViewController: FournitureDetailTableViewControllerDelegate {
    func fournitureDetailTableViewController (_ fournitureDetailTableViewController: FournitureDetailTableViewController, didModifyFourniture  fourniture: Fourniture ) {
        
        FournitureController.majFourniture(fourniture: fourniture)
        // Première mise à jour pour inclure le nouveau fourniture dans le snapshot
        updateDataSource(for: .listeReleves)
        

        var newSectionSnapshot = self.dataSource.snapshot(for: .listeReleves)
        guard let itemcategorieFourniture = newSectionSnapshot.parent(of: ViewModel.Item.fourniture(fourniture: fourniture)) else { return }
        
        if !fournitureDetailTableViewController.modeModif {
            // On a cree un fourniture, il faut mettre à jour le nombre de fourniture dans le titre
            // On supprime et recree la categorie fourniture en mettant un blanc en fin du nom pour éviter le doublon  et les items enfants
            
            guard case let ViewModel.Item.categorie(categorie: categorieFourniture) = itemcategorieFourniture else { return }
            var newCategorieFourniture = categorieFourniture
            
            // Hack pour contourner l'unicité
            newCategorieFourniture.idSnapshot = categorieFourniture.idSnapshot + 1
            
            
            newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieFourniture)], after: ViewModel.Item.categorie(categorie: categorieFourniture))
            newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieFourniture)])
            
            
            // On recree les fournitures rattachés car ils ont été supprimés (dont le nouveau compyeur)
            for fourniture in self.model.fournitures {
                newSectionSnapshot.append([ViewModel.Item.fourniture(fourniture: fourniture)], to: ViewModel.Item.categorie(categorie: newCategorieFourniture) )
            }
            
            newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieFourniture)])
            dataSource.apply(newSectionSnapshot, to: .listeReleves)
        
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.fourniture(fourniture: fourniture)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            
            
            
        } else {
            /*           // Mise à jour du fourniture
             // Supprime et recree le fourniture dan le snapshot pour forcer la mise à jour
             
             var oldSnapshot = dataSource.snapshot(for: .listeReleves)
             
             guard let itemcategorieFourniture = oldSnapshot.parent(of: ViewModel.Item.fourniture(fourniture: fourniture)) else { return }
             
             let items = oldSnapshot.snapshot(of: itemcategorieFourniture)
             let itemsListe = items.items
             
             //        if !existeChangementAction {
             //          // Mise à jour du snapshot avec reload de celulle uniquement, on a les mêmes items
             //          print("---- Snapshot Reload")
             //          var newSnapshot = dataSource.snapshot()
             //          newSnapshot.reloadItems([itemcategorieFourniture])
             //          newSnapshot.reconfigureItems(itemsListe)
             //          dataSource.apply(newSnapshot)
             
             //         } else {
             // Mise à jour par annule et remplace car il y a des différences
             // Puis reload
             print("---- Snapshot Annule et recree")
             oldSnapshot.delete(itemsListe)
             oldSnapshot.append(itemsListe, to: itemcategorieFourniture)
             dataSource.apply(oldSnapshot, to: .listeReleves)
             print("---- Snapshot Reload")
             var newSnapshot = dataSource.snapshot()
             newSnapshot.reloadItems([itemcategorieFourniture])
             newSnapshot.reloadItems(itemsListe)
             dataSource.apply(newSnapshot)
             
             
             }
             */
            
            
            
            
            
            var newFourniture = fourniture
            newFourniture.idSnapshot = fourniture.idSnapshot + 1
            newSectionSnapshot.insert([ViewModel.Item.fourniture(fourniture: newFourniture)], after: ViewModel.Item.fourniture(fourniture: fourniture))
            newSectionSnapshot.delete([ViewModel.Item.fourniture(fourniture: fourniture)])
            
            
            newSectionSnapshot.expand([itemcategorieFourniture])
            dataSource.apply(newSectionSnapshot, to: .listeReleves)
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.fourniture(fourniture: newFourniture)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            
        }
        
    }
}

// MARK: - EquipementDetailTableViewControllerDelegate

extension EquipementsCollectionViewController: EquipementDetailTableViewControllerDelegate {
    
    func equipementDetailTableViewController (_ equipementDetailTableViewController: EquipementDetailTableViewController, didModifyEquipement  equipement: Equipement ) {
        EquipementController.majEquipement(equipement: equipement)
        // Première mise à jour pour inclure le nouveau equipement dans le snapshot
        updateDataSource(for: .listePieces)
        

        var newSectionSnapshot = self.dataSource.snapshot(for: .listePieces)
        guard let itemcategorieEquipement = newSectionSnapshot.parent(of: ViewModel.Item.equipement(equipement: equipement)) else { return }
        
        if !equipementDetailTableViewController.modeModif {
            // On a cree un equipement, il faut mettre à jour le nombre de equipement dans le titre
            // On supprime et recree la categorie equipement en mettant un blanc en fin du nom pour éviter le doublon  et les items enfants
            
            guard case let ViewModel.Item.categorie(categorie: categorieEquipement) = itemcategorieEquipement else { return }
            var newCategorieEquipement = categorieEquipement
            
            // Hack pour contourner l'unicité
            newCategorieEquipement.idSnapshot = categorieEquipement.idSnapshot + 1
            
            
            newSectionSnapshot.insert([ViewModel.Item.categorie(categorie: newCategorieEquipement)], after: ViewModel.Item.categorie(categorie: categorieEquipement))
            newSectionSnapshot.delete([ViewModel.Item.categorie(categorie: categorieEquipement)])
            
            
            // On recree les equipements rattachés car ils ont été supprimés (dont le nouveau compyeur)
            for equipement in self.model.equipements {
                if equipement.idCategorie == newCategorieEquipement.idCategorie {
                    newSectionSnapshot.append([ViewModel.Item.equipement(equipement: equipement)], to: ViewModel.Item.categorie(categorie: newCategorieEquipement) )
                }
            }
            
            newSectionSnapshot.expand([ViewModel.Item.categorie(categorie: newCategorieEquipement)])
            dataSource.apply(newSectionSnapshot, to: .listePieces)
        
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.equipement(equipement: equipement)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            
            
            
        } else {
            // Mise à jour du equipement
            // Supprime et recree le equipement dan le snapshot pour forcer la mise à jour
            var newEquipement = equipement
            newEquipement.idSnapshot = equipement.idSnapshot + 1
            newSectionSnapshot.insert([ViewModel.Item.equipement(equipement: newEquipement)], after: ViewModel.Item.equipement(equipement: equipement))
            newSectionSnapshot.delete([ViewModel.Item.equipement(equipement: equipement)])
            
            
            newSectionSnapshot.expand([itemcategorieEquipement])
            dataSource.apply(newSectionSnapshot, to: .listePieces)
            if let indexPath = dataSource.indexPath(for: ViewModel.Item.equipement(equipement: newEquipement)) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
        }
        
    }
    }


