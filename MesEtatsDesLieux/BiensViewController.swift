//
//  BiensViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 02/02/2023.
//

import UIKit

class BiensViewController: UIViewController {
    
    // MARK: Proprietes
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, UUID>
    
    var collectionView: UICollectionView!
    
    var model = Model()
    //   var model2 = Model2()
    var dataSource: DataSourceType!
    var itemDictionnary = [UUID : ViewModel.Item]()
    
    @IBOutlet var editBarButton: UIBarButtonItem!
    
    // MARK: Types
    enum ViewModel {
        enum Section: Hashable {
            case biens
        }
        
        enum Item: Hashable {
            case bien       (bien: Bien)
            case actionBien (actionBien: ActionBien)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .bien           (let bien):
                    hasher.combine(bien.id)
                case .actionBien    (let actionBien):
                    hasher.combine(actionBien.id)
                }
            }
            static func == (_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.bien  (let lb), .bien(let rb)):
                    return lb.id == rb.id
                case (.actionBien  (let ld), .actionBien(let rd)):
                    return ld.id == rd.id
                default:
                    return false
                }
                
            }
        }
    }
    
    struct Model {
        var biens : [Bien] {
            var tab: [Bien] = []
            for edl in EDLsController.shared.edls {
                tab.append(Bien(id: edl.idEDL, nomBien: edl.nomBien, idSnapshot: edl.idSnapshot, ordreAffichage: edl.ordreAffichage ?? 9999 ))
            }
            return tab }
        var actionsBien : [ActionBien] {
            var tab: [ActionBien] = []
            for edl in EDLsController.shared.edls {
                for actionBien in edl.actionsBien {
                    if actionBien.statutAction !=  .masque {
                        tab.append(actionBien)
                    }
                }
            }
            return tab }
    }
    
    // MARK: Cycle de vie
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadListeFichiers()
        print ("----- Liste tout", listeFichier())
        print ("----- Liste html", listeFichier("html"))
        print ("----- Liste Categorie", listeFichier("Compteurs"))
    //    supprFichier(listeURL: listeFichier("Compteurs"))
        
        
        
        title = "Mes Etats Des Lieux"
        // Initialisation du dictionnaire pour acceder aux valeurs à partir de UUID
        for b in model.biens {
            itemDictionnary[b.id] = ViewModel.Item.bien(bien: b)
        }
        
        editBarButton.title = ""
        if model.biens.count <= 1 {
            if #available(iOS 16.0, *) {
                editBarButton.isHidden = true
            } else {
                // Fallback on earlier versions
                editBarButton.image = nil
            }
        }
        
       
        
        for a in model.actionsBien {
            if a.statutAction != .masque {
                itemDictionnary[a.id] = ViewModel.Item.actionBien(actionBien: a)
            }
        }
        
        configureLayout()
        
        dataSource = makeDataSource()
        dataSource.reorderingHandlers.canReorderItem = { item in return true }
        
        collectionView.delegate = self as UICollectionViewDelegate
        collectionView.dataSource = dataSource
        
        applyInitialSnaphot()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    @IBAction func unwindToBiens(_ unwindSegue: UIStoryboardSegue) {
        print("unwindBiens")
        if unwindSegue.identifier == "annuleBien" {
            print("Annulation Saisie")
        }
        if unwindSegue.identifier == "sauveBien" {
            print("Saisie confirmée")
        }
        
    }
    
    
    
    // MARK: CollectionViewList
    
    func configureLayout() {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        layoutConfig.headerMode = .none
        layoutConfig.showsSeparators = true
        
        // Configuration des actions swipe
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            
            guard let item = self.dataSource.itemIdentifier(for: indexPath),
                  let id = itemDictionnary[item]  else { return .init(actions: []) }
            switch id {
            case .bien:
                let del = UIContextualAction(style: .destructive, title: "Supprimer") {
                    action, view, completion in
                    self.supprimerEDL(id: item)
                    completion(true)
                }
                return .init(actions: [del])
            default:
                return .init(actions: [])
            }
        }
         
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        view.addSubview(collectionView)
        
        // Make collection view take up the entire view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
        ])
    }
    
    
    func makeDataSource () -> DataSourceType {
        
        let bienCellRegistration = UICollectionView.CellRegistration<BienCollectionViewCell,UUID> {cell,indexPath,itemIdentifier in
            switch self.itemDictionnary[itemIdentifier] {
            case .bien (let bien):
                print("----Enregistrement cell Bien" , bien.nomBien)
                cell.bien = bien
                
                let outlineDisclosureAccessoryOptions = UICellAccessory.OutlineDisclosureOptions(style: .header, isHidden: false)
                let cellAccessoryOutlineDisclosure = UICellAccessory.outlineDisclosure(options: outlineDisclosureAccessoryOptions )
                let reorder = UICellAccessory.reorder()
                cell.accessories = [cellAccessoryOutlineDisclosure , reorder]
                
            default:
                print("")
                
            }
        }
        
        let actionCellRegistration = UICollectionView.CellRegistration<ActionCollectionViewCell,UUID> {cell,indexPath,itemIdentifier in
            
            print (itemIdentifier , "->" , self.itemDictionnary[itemIdentifier] ?? "pas trouve")
            switch self.itemDictionnary[itemIdentifier] {
            case .actionBien (let actionBienSelect):
                print("----Enregistration cell Action" , actionBienSelect.typeAction.description," pour ", actionBienSelect.idBien)
                
                cell.actionBien = actionBienSelect
                
           default:
                print("")
                
            }
            
            
        }
        
        
        
        let dataSource = DataSourceType (collectionView: collectionView)
        { collectionView , indexPath, item -> UICollectionViewCell? in
            
            switch self.itemDictionnary[item] {
            case .bien:
                return collectionView.dequeueConfiguredReusableCell(using: bienCellRegistration, for: indexPath, item: item)
            case .actionBien:
                return collectionView.dequeueConfiguredReusableCell(using: actionCellRegistration, for: indexPath, item: item)
            default:
                print("")
                return nil
            }
            
        }
        return dataSource
    }
    
    
    
    func applyInitialSnaphot () {
        var snapshot = NSDiffableDataSourceSnapshot<ViewModel.Section, UUID>()
        snapshot.appendSections([.biens])
        dataSource.apply(snapshot)
        
        applySnapshotSection(section: .biens, etatExpanded: nil )
        
    }
    
    func applySnapshotSection(section: ViewModel.Section , etatExpanded: [ViewModel.Item]? ) {
        
        print ("----> Maj Snapshot")
        var genericSnapshot = NSDiffableDataSourceSectionSnapshot<UUID>()
        
        for bien in model.biens.sorted(by: {$0.ordreAffichage ?? 9999 <= $1.ordreAffichage ?? 9999 }) {
            print ("Snap: EDL/Bien =" , bien.nomBien)
            
            genericSnapshot.append([bien.id])
            
            // On filtre sur les actions se reportant au bien et on ne garde que l'UUID
            let actionsBienSelect = model.actionsBien.filter{ $0.idBien == bien.id }.sorted{$0.ordreAction < $1.ordreAction }.filter{$0.statutAction != .masque }.map{$0.id }
            print("Actions UUID ->", actionsBienSelect)
            genericSnapshot.append(actionsBienSelect, to: bien.id)
        }
        
        print (genericSnapshot.visualDescription())
        
        
        dataSource.apply(genericSnapshot, to: .biens, animatingDifferences: false)
        
        
    }
    
    
    
    func sauveEtatExpanded( section: ViewModel.Section ) -> [UUID] {
        let snapshotSection = dataSource.snapshot(for: section)
        
        // Sauvegarde des états expanded
        let items = snapshotSection.items
        var itemsExpanded: [UUID] = []
        for item in items {
            if snapshotSection.isExpanded(item) { itemsExpanded.append(item)}
        }
        return itemsExpanded
    }
    
    // MARK: Fonctions
    
    
    func lanceSaisie ( actionBien: ActionBien , indexPath: IndexPath) {
        
        // Informe les controlleurs sur l'EDL selectionné pour lancer une action
        // sauf dans le cas d'un ajout ou l'id de l'EDL ne pointe pas encore sur un EDL dans le controlleur car on est sur un ajout
        if actionBien.typeAction != .ajoutEDL {
            _ = EDLsController.selectEDLbyUUID(id: actionBien.idBien)
        }
        switch actionBien.typeAction {
            
        case .decrireBien, .identActeurs, .planifEDL, .ajoutEDL, .ajoutSortieEDLEntree , .repriseNouvelEDL:
            let storyboard = UIStoryboard(name: "SaisieGeneric", bundle: .main)
            let saisieGenericTableViewController =
            storyboard.instantiateViewController(identifier: "SaisieGenericTableViewController") { coder in
                return MesEtatsDesLieux.SaisieGenericTableViewController(coder: coder, actionBien: actionBien , indexPath: indexPath)
            }
            print("---- > Appel : ", actionBien.typeAction.description, "Self =", self)
            
            // Positionnement de la déléguée
            saisieGenericTableViewController.delegate = self
            self.navigationController?.pushViewController(saisieGenericTableViewController, animated: true)
        case .realEDL:
            // Sauvegarde des EDLS avant d'éditer un EDL
            EDLsController.sauveEDLs()
        
            if let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) {
                print("---- Edition de ", edl.nomBien)
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let equipementsCollectionViewController =
                storyboard.instantiateViewController(identifier: "EquipementsCollectionViewController") { coder in
                    return EquipementsCollectionViewController(edl: edl, indexPath: indexPath, actionBien: actionBien, coder: coder)
                }
                equipementsCollectionViewController.delegate = self
                navigationController?.pushViewController(equipementsCollectionViewController, animated: true)
            }
            
        case .miseEnPage:
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let miseEnPageViewController =
            storyboard.instantiateViewController(identifier: "MiseEnPageViewController") { coder in
                return MiseEnPageViewController(coder: coder, actionBien: actionBien, indexPath: indexPath)
            }
            miseEnPageViewController.delegate = self
            navigationController?.pushViewController(miseEnPageViewController, animated: true)
            
        
        case .genererDocSigne:
            let statutAction = actionBien.statutAction
            guard statutAction != .inactif || statutAction != .nonApplicable  else { return }
            
            if statutAction == .termine {
                // On affiche le PDF existant
                
                    let storyboard = UIStoryboard(name: "Main", bundle: .main)
                    let previsualiserViewController =
                    storyboard.instantiateViewController(identifier: "PrevisualiserViewController") { coder in
                        return PrevisualiserViewController(actionBien: actionBien, indexPath: indexPath , coder: coder)
                    }
                    previsualiserViewController.delegate = self
                    navigationController?.pushViewController(previsualiserViewController, animated: true)
                
            } else {
                // On recueille ou vérifie les signatures, avant de générer le document
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let signatureViewController =
                storyboard.instantiateViewController(identifier: "SignatureViewController") { coder in
                    return SignatureViewController(coder: coder, actionBien: actionBien, indexPath: indexPath, surSignature: false)
                }
                signatureViewController.delegatePreview = self
                navigationController?.pushViewController(signatureViewController, animated: true)
            }
        case .genererDocVierge:
            let statutAction = actionBien.statutAction
            guard statutAction != .inactif || statutAction != .nonApplicable  else { return }
            
        
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let previsualiserViewController =
            storyboard.instantiateViewController(identifier: "PrevisualiserViewController") { coder in
                return PrevisualiserViewController(actionBien: actionBien, indexPath: indexPath , coder: coder)
            }
            previsualiserViewController.delegate = self
            navigationController?.pushViewController(previsualiserViewController, animated: true)
            
        case .clotureEDL:
            cloturerEDL(actionBien: actionBien)
            
        case .reactivationEDL:
            reactiverEDL(id: actionBien.idBien)
            
        case .visuDocDefinitifSigne, .visuDocDefinitifVierge:
                
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let previsualiserViewController =
            storyboard.instantiateViewController(identifier: "PrevisualiserViewController") { coder in
                return PrevisualiserViewController(actionBien: actionBien, indexPath: indexPath , coder: coder)
            }
            previsualiserViewController.delegate = self
            navigationController?.pushViewController(previsualiserViewController, animated: true)
        
            
        
            
        
        default:
            print("Pas encore implémenté")
        }
    }
    
    @IBAction func ajoutEDLBoutton(_ sender: UIBarButtonItem) {
        
        lanceSaisie(actionBien: ActionBien(id: UUID(), idBien: UUID(), typeAction: .ajoutEDL), indexPath: IndexPath(row: 0, section: 0))
        
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        self.setEditing(!self.isEditing, animated: true)
        if !self.isEditing { self.sauveOrdreAffichageEDL() }
        
    }
    
    func sauveOrdreAffichageEDL() {
        // Sauvegarde de l'ordre d'affichage des pieces
        let releveSnapshotItems = dataSource.snapshot(for: .biens).items
        for i in 0...releveSnapshotItems.count  - 1{
            switch  itemDictionnary[releveSnapshotItems[i]] {
            case .bien(var bien):
                if var edl = EDLsController.edlFromUUID(idEDL: bien.id) {
                    edl.ordreAffichage = i
                    _ = EDLsController.majEDL(edl: edl)
                }
            default:
                print("")
                
            }
        }
        
    }
    func supprimerEDL(id: UUID) {
        print("Supprimer")
        if
           let edl = EDLsController.edlFromUUID(idEDL: id) {
            
            let alertController = UIAlertController (title: "Confirmation de la suppression", message: "La suppression du bien entraine la perte des informations associées à \(edl.nomBien). Cette opération est IRREVERSIBLE", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Je confirme la suppression des données", style: .default, handler: {_ in
                    // Mise à jour du dictionnaire
                    self.itemDictionnary.removeValue(forKey: edl.idEDL)
                    for a in edl.actionsBien {
                        self.itemDictionnary.removeValue(forKey: a.id)
                    }
                    EDLsController.supprEDL(id: edl.idEDL)
                
                
                    var newSnapshot = self.dataSource.snapshot(for: .biens)
                    newSnapshot.delete([edl.idEDL])
                    self.dataSource.apply(newSnapshot, to: .biens)
            }
                    ))
            alertController.addAction(UIAlertAction(title: "Annuler", style: .default, handler: nil ))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func cloturerEDL(actionBien: ActionBien) {
        guard  var edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) else { return }
        
        // 1- On cloture les actions en cheangeant l'état de l'EDL à cloturer
        edl.etatEDL = .cloture
        
        // 2- Si on n'a pas généré de doc à jour, on met les variables nomFichier et Date à Nil pour ne pas afficher les actions de visu
        let statutDocDefinitifSigne = actionBien.statutCalc(actionBien: actionBien, .genererDocSigne)
        if statutDocDefinitifSigne != .termine {
            edl.dernierFichierSigneNomFichier = nil
            edl.dateDernierFichierSigne = nil
        }
        let statutDocDefinitifVierge = actionBien.statutCalc(actionBien: actionBien, .genererDocVierge)
        if statutDocDefinitifVierge != .termine {
            edl.dernierFichierViergeNomFichier = nil
            edl.dateDernierFichierVierge = nil
        }
        _ = EDLsController.majEDL(edl: edl, false)
        
        // 3- On lance la mise à jour de la liste
        miseAJourActionsEDL(id: edl.idEDL)
        
    }
    
    func reactiverEDL(id: UUID) {
        // 1- On cloture les actions en cheangeant l'état de l'EDL à cloturer
        guard  var edl = EDLsController.edlFromUUID(idEDL: id) else { return }
        edl.etatEDL = .actif
        _ = EDLsController.majEDL(edl: edl, false)
        
        // 2- On lance la mise à jour de la liste
        miseAJourActionsEDL(id: id)
       
    }
    
    
    func miseAJourActionsEDL ( id: UUID ) {
        
        // On repart de la dernière version car l'application du modele a pu changer des éléments
        if let newEDL = EDLsController.edlFromUUID(idEDL: id) {
            
            // Mise à jour du dictionnaire
            // Mise à jour de l'EDL
            itemDictionnary[newEDL.idEDL] = ViewModel.Item.bien(bien: Bien(id: newEDL.idEDL, nomBien: newEDL.nomBien, idSnapshot: 0))
            // Mise à jour des actions de l'EDL
            var listeAMettreAJour: [ActionBien.ID] = []
            var existeChangementAction: Bool = false
            
            print ("*** Dictionnaire AVANT")
            for i in itemDictionnary.keys {
                switch itemDictionnary[i] {
                case .bien(let bien):
                    print ("*** Bien        : ", bien.nomBien)
                case .actionBien(let actionBien):
                    print ("*** Action Bien : ", EDLsController.edlFromUUID(idEDL: actionBien.idBien)?.nomBien ?? " : ", actionBien.typeAction.description , "->", actionBien.statutAction.description)
                default:
                    _ = 1
                }
            }
            
            
            // Mise à jour du dictionnaire
            for a in newEDL.actionsBien {
                if a.statutAction == .masque {
                    // Action à masquer
                    if itemDictionnary[a.id] != nil {
                        // On doit retirer l'action
                        itemDictionnary[a.id] = nil
                        existeChangementAction = true
                    } // else l'action est déjà absente du dictionnaire on ne fait rien
                } else {
                    // Action non masquee
                    listeAMettreAJour.append(a.id)
                    if itemDictionnary[a.id] == nil {
                        // Elle n'existait pas, il faut l'y mettre
                        itemDictionnary[a.id] = ViewModel.Item.actionBien(actionBien: a)
                        existeChangementAction = true
                    } else {
                        // Elle existait mais on la met à jour
                        itemDictionnary[a.id] = ViewModel.Item.actionBien(actionBien: a)
                    }
                }
            }
            print ("*** Dictionnaire APRES")
            for i in itemDictionnary.keys {
                switch itemDictionnary[i] {
                case .bien(let bien):
                    print ("*** Bien        : ", bien.nomBien)
                case .actionBien(let actionBien):
                    print ("*** Action Bien : ", EDLsController.edlFromUUID(idEDL: actionBien.idBien)?.nomBien ?? " : ", actionBien.typeAction.description , "->", actionBien.statutAction.description)
                default:
                    _ = 1
                }
            }
            print ("*** Différence dans la liste des actions :" , existeChangementAction)
            print ("*** EDL   à mettre à jour" , newEDL.idEDL)
            print ("*** Liste à mettre à jour" , listeAMettreAJour)
            // Application au Snapshot
            var oldSnapshot = dataSource.snapshot(for: .biens)
            let items = oldSnapshot.snapshot(of: newEDL.idEDL)
            
            if !existeChangementAction {
                // Mise à jour du snapshot avec reload de celulle uniquement, on a les mêmes items
                print("---- Snapshot Reload")
                var newSnapshot = dataSource.snapshot()
                newSnapshot.reloadItems([newEDL.idEDL])
                newSnapshot.reloadItems(listeAMettreAJour)
                dataSource.apply(newSnapshot)
                
            } else {
                // Mise à jour par annule et remplace car il y a des différences
                // Puis reload
                print("---- Snapshot Annule et recree")
                oldSnapshot.delete(items.items)
                oldSnapshot.append(listeAMettreAJour, to: newEDL.idEDL)
                dataSource.apply(oldSnapshot, to: .biens)
                print("---- Snapshot Reload")
                var newSnapshot = dataSource.snapshot()
                newSnapshot.reloadItems([newEDL.idEDL])
                newSnapshot.reloadItems(listeAMettreAJour)
                dataSource.apply(newSnapshot)
                
                
            }
        }
    }
   
}
    // MARK: CollectionView
extension BiensViewController: UICollectionViewDelegate {
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated:animated)
        self.collectionView.isEditing = editing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print ("Selection")
        
        
        // Get selected item using index path
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath)  else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        
        switch self.itemDictionnary[selectedItem] {
        
        case .actionBien(let actionBien):
            
            print ("Selection ActionBien")
            lanceSaisie(actionBien: actionBien, indexPath: indexPath)
            
        default:
            print("")
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    // Evite de déplacer une cellule hors de sa section
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        print("here")
        if originalIndexPath.section == proposedIndexPath.section {
            return proposedIndexPath
        }
        return originalIndexPath
    }
}

    // MARK: Délégués -> Saisie générique

extension BiensViewController: SaisieGenericTableViewControllerDelegate {
    func saisieGenericTableViewController(_ saisieGenericTableViewController: SaisieGenericTableViewController, willAddEDL edl: EDL, for actionBien: ActionBien, from typeModele: TypeModele, nomModele: String, indexPath: IndexPath) {
        print ("---> Appel de la delegue sur :", actionBien.typeAction, "-", actionBien.statutAction)
    _ = EDLsController.majEDL(edl: edl)
    EDLsController.sauveEDLs()
    if EDLsController.shared.edls.count > 1 {
        if #available(iOS 16.0, *) {
            editBarButton.isHidden = false
        } else {
            // Fallback on earlier versions
            editBarButton.image = UIImage( systemName: "arrow.up.and.down")
        }
    }
    _ = EDLsController.selectEDLbyUUID(id: edl.idEDL)
    
        ModeleEDLController.completeEDLfromType(typeModel: typeModele, nomModele: nomModele)
    
    // On repart de la dernière version car l'application du modele a pu changer des éléments
    let newEDL = EDLsController.selectedEDLedl()!
    
    // Mise à jour du dictionnaire
    // Ajout de l'EDL
    itemDictionnary[newEDL.idEDL] = ViewModel.Item.bien(bien: Bien(id: newEDL.idEDL, nomBien: newEDL.nomBien, idSnapshot: 0))
    // Ajout des actions de l'EDL
        for a in newEDL.actionsBien {
            if a.statutAction != .masque {
                itemDictionnary[a.id] = ViewModel.Item.actionBien(actionBien: a)
            }
        }
    
    // Mise à jour du snapshot nouveau Bienw
    var newSnapshot = dataSource.snapshot(for: .biens)
    newSnapshot.append([newEDL.idEDL])
    let actionsBienSelect = model.actionsBien.filter{ $0.idBien == newEDL.idEDL }.sorted{$0.ordreAction < $1.ordreAction }.map{$0.id }
    newSnapshot.append(actionsBienSelect, to: newEDL.idEDL)
    dataSource.apply(newSnapshot, to: .biens)
    
    // Positionnement du scrolling sur le nouveau bien et animation de la création
    if let nitem = dataSource.snapshot().indexOfItem(newEDL.idEDL),
       let sitem = dataSource.snapshot().indexOfSection(.biens) {
        let indexPathNouvelEDL = IndexPath (item: nitem, section: sitem)
        collectionView.selectItem(at: indexPathNouvelEDL, animated: true, scrollPosition: .centeredVertically)
           if let cell = collectionView.cellForItem(at: indexPathNouvelEDL) {
               cell.alpha = 0
               cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
               UIView.animate(withDuration: 1.0, animations: { () -> Void in
                   cell.alpha = 1
                   cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
               }) { (_) in
                   self.collectionView.deselectItem(at: indexPathNouvelEDL, animated: true)
               }
           }
        }
       
    }
    
    func saisieGenericTableViewController(_ saisieGenericTableViewController: SaisieGenericTableViewController, didModifyEDL edl: EDL, for actionBien: ActionBien , indexPath: IndexPath) {
        
        print("---> Appel déléguée pour modifier", edl.nomBien, ".", actionBien.typeAction.description)
        
        var indexPathNomBien = IndexPath(row: 0, section: 0)
        var nomBienModifie = false
        var newEDL = edl
        
            
        // Est-ce que le nom a été modifié ? Si Oui on stocke l'indexPath pour animer la cellule en fin de traitement
        if let oldEDL = EDLsController.edlFromUUID(idEDL: edl.idEDL) ,
           let indexRowItem = dataSource.snapshot().indexOfItem(edl.idEDL) {
            if oldEDL.nomBien != edl.nomBien
            {
                indexPathNomBien.row = indexRowItem
                indexPathNomBien.section = indexPath.section
                nomBienModifie = true
            }
        }
        // Si on est en realEDL, et si c'est la premiere fois, on positionne le booleen de modif
        if actionBien.typeAction == .planifEDL && !edl.validationPlanifEDL {
            newEDL.validationPlanifEDL = true
        }
        
        
        
        // Mise à jour des données avec les nouvelles valeurs
        _ = EDLsController.majEDL(edl: newEDL)
        
        miseAJourActionsEDL(id: edl.idEDL)
  
        // Surlignage de la cellule d'ou est issue la modif
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 0
            cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.alpha = 1
                cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            })
        }
        
        // Surlignage de la cellule de nom de bien si elle a été modifié
        if nomBienModifie {
            if let cell = collectionView.cellForItem(at: indexPathNomBien) {
                cell.alpha = 0
                cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    cell.alpha = 1
                    cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                    
                })
            }
        
    
    }
    }
    
}
    // MARK: Délégués -> Mise en page

extension BiensViewController: MiseEnPageViewControllerDelegate {
    
    func miseEnPageViewController (_ miseEnPageViewController: MiseEnPageViewController, for actionBien: ActionBien,  indexPath: IndexPath ) {
        
        print ("---> Appel de la delegue sur :", actionBien.typeAction, "-", actionBien.statutAction)
        
        // Mise à jour de l'horodatage pour faire périmer les PDF
        EDLsController.touchEDL(idEDL: actionBien.idBien)
        
        // Mise à jour du snapshot avec reload de celulle uniquement
        miseAJourActionsEDL(id: actionBien.idBien)
   
        
        // Surlignage de la cellule d'ou est issue la modif
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 0
            cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.alpha = 1
                cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            })
        }
    }
    
}



extension BiensViewController: EquipementsCollectionViewControllerDelegate {
   
    func equipementsCollectionViewController(_ equipementsCollectionViewController: EquipementsCollectionViewController, didModifyEDL edl: EDL, for actionBien: ActionBien, indexPath: IndexPath) {
        
        print ("---> Appel de la delegue sur :", actionBien.typeAction, "-", actionBien.statutAction)
        
        _ = EDLsController.majEDL(edl: edl)
        EDLsController.sauveEDLs()
        miseAJourActionsEDL(id: edl.idEDL)
  
        // collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        // Surlignage de la cellule d'ou est issue la modif
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 0
            cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.alpha = 1
                cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                
            })
        }
        
        
    }
    
}



extension BiensViewController: PrevisualiserViewControllerDelegate {
    func previsualiserViewController(_ previsualiserViewController: PrevisualiserViewController, didPublishDoc edl: EDL, for actionBien: ActionBien, indexPath: IndexPath) {
        print ("---> Appel de la delegue sur :", actionBien.typeAction, "-", actionBien.statutAction)
        
        // Pas de sauvegarde de EDL car il a été sauvegardé par le VC Preview
   
        // Deux appels pour gérer l'interdépendance entre les actions pour le document Signé et le document Vierge
        // Pas de solutions trouvée pour n'en avoir qu'un
        miseAJourActionsEDL(id: edl.idEDL)
        miseAJourActionsEDL(id: edl.idEDL)
        
        // Surlignage de la cellule d'ou est issue la modif
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 0
            cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.alpha = 1
                cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                
            })
        }
        
        
    }
    
    
}
