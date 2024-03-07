//
//  EntretienDetailTableViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 19/12/2022.
//

import UIKit

protocol EntretienDetailTableViewControllerDelegate: AnyObject {
    // Permet de mettre à jour avant de faire disparaitre le compteur (Controlleur et snapshot)
    func entretienDetailTableViewController (_ entretienDetailTableViewController: EntretienDetailTableViewController, didModifyEntretien  entretien: Entretien )
}


class EntretienDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    var modeModif: Bool = false
    var entretien: Entretien?
    
    var pourEDLSortie = false  // L'entretien est associée à un EDL de Sortie relatif à un EDL d'entrée initialement géré dans l'appli
    var estItemSortieAvecAnteriorite = false // L'entretien est en saisie de sortie et dispose de données antérieures
    
    weak var delegate: EntretienDetailTableViewControllerDelegate?
    
    // En miroir de compteur, tableau (legend, UIImage obtenue à partir du chargemet du fichier)
    var imagesEDLImage : [ImageEDLImage]?
    // Utiliser pour palier que l'on ne peut pas récupérer la cellule éditée car la class EquipementTableViewCell ne peut pas déclencher le segue
    // au lieu de cela on le déclenche manuellement depuis le didSelect de la table en mettant de coté l'indexPath sélectionne
    var indexPathSegue: IndexPath?
    
    
    @IBOutlet var valideBarButton: UIBarButtonItem!
    @IBOutlet var retourBarButton: UIBarButtonItem!
    
    @IBOutlet var intituleTextField: UITextField!
    @IBOutlet var realiseSwitch: UISwitch!
    
    @IBOutlet var dateEcheanceEntretienTextField: UITextField!
    
    @IBOutlet var observationEntretienTextField: UITextField!
    @IBOutlet var observationSortieEntretienTextField: UITextField!
    @IBOutlet var observationStack: UIStackView!
    @IBOutlet var observationEntreeStack: UIStackView!
    @IBOutlet var observationSortieStack: UIStackView!
    
    @IBOutlet var prendrePhoto: UIButton!
    @IBOutlet var importerPhoto: UIButton!
    
    @IBOutlet var imagesEDLCollectionView: UICollectionView!
    
    
    
    // MARK: Cycle de vie
    
    init?(entretien: Entretien, modeModif: Bool, coder: NSCoder) {
        self.entretien = entretien
        self.modeModif = modeModif
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.entretien = Entretien(idCategorie: CategorieController.categorieUUID(nomCategorie: libelleCompteur), intitule: "", realise: false, dateEcheanceEntretien: "")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ajout d'un contrat d'entretien"
        self.navigationItem.prompt = libelleContratsEntretien
        
        // Determination du type d'EDL : standard ou EDL de Sortie relié à un EDL d'entrée avec antériorité ou pas
        if let edl = EDLsController.selectedEDLedl() {
            pourEDLSortie =  edl.isEDLSortieApresEntree
            
            // Calcul estItemSortieAvecAnteriorite
            estItemSortieAvecAnteriorite = false
            
            
            if let entretien = entretien {
                if entretien.observationEntretien != nil  {
                    estItemSortieAvecAnteriorite = true
                }
            }
            
        }
        
        if modeModif {
            // On masque le bouton droit OK et on renomme le bouton gauche en Retour
            retourBarButton.title = "Retour"
            if #available(iOS 16.0, *) {
                valideBarButton.isHidden = true
            } else {
                valideBarButton.title = ""
            }
            title = entretien?.intitule
            
        } else {
            // On cree une catagorie : Bouton droit = OK et gauche "Annuler"
            retourBarButton.title = "Annuler"
            valideBarButton.title = "OK"
            if #available(iOS 16.0, *) {
                valideBarButton.isHidden = false
            }
            title = "Ajout d'un contrat d'entretien"
        }
        
        
        
        majButtonPhoto()
        updateSaveButtonState()
        
        configureDisplayEntreeSortie()
        
        initCollectionEDLImage()
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("willDisappear")
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Fonctions
    
    
    fileprivate func sauveEntretien() {
        print("SauveEntretien")
        
        if var entretien = self.entretien {
            
            if intituleTextField.text != "" {
                entretien.intitule = intituleTextField.text!
                entretien.realise = realiseSwitch.isOn
                entretien.dateEcheanceEntretien = dateEcheanceEntretienTextField.text!
                
                if observationEntretienTextField.text != "" {
                    entretien.observationEntretien = observationEntretienTextField.text!
                } else {
                    if self.entretien?.observationEntretien != nil {
                        entretien.observationEntretien = nil
                    }
                }
                
                if pourEDLSortie {
                    if observationSortieEntretienTextField.text != "" {
                        entretien.observationEntretienSortie = observationSortieEntretienTextField.text!
                    } else {
                        if self.entretien?.observationEntretienSortie != nil {
                            entretien.observationEntretienSortie = nil
                        }
                    }
                }
                self.entretien = entretien
                self.delegate?.entretienDetailTableViewController(self, didModifyEntretien: self.entretien!)
                
            }
        }
    }
    
    @IBAction func valideBarButton2(_ sender: UIBarButtonItem) {
        print("Valide")
        sauveEntretien()
    }
    
    @IBAction func editNomBien(_ sender: Any) {
        self.title = self.intituleTextField.text
        self.updateSaveButtonState()
    }
    
    func majButtonPhoto() {
        prendrePhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        importerPhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    func updateSaveButtonState() {
        let intitule = intituleTextField.text ?? ""
        valideBarButton.isEnabled = !intitule.isEmpty
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        guard let senderObj = sender as? UIBarButtonItem else { return }
        if senderObj == valideBarButton {
            sauveEntretien()
        } else  if senderObj == retourBarButton {
            if modeModif {
                sauveEntretien()
            } else {
                // On efface le compteur initialisé
                // On efface les données de photos
                if let entretien = entretien,
                   let images = entretien.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                entretien = nil
            }
        }
    }
    
    
    
    // MARK: - prise de Photos
    
    
    @IBAction func prendrePhoto(_ sender: UIButton, forEvent event: UIEvent) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if sender == prendrePhoto {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        if sender == importerPhoto {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
    
    
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] ){
        
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("pas d'image")
            return}
        
        
        var indexImage = 0
        if let n = entretien?.images?.count {
            indexImage = n
        } else { entretien?.images = [] }
        if var imageEDL = ajoutImageEDL(inImage: selectedImage, inLegende: "Photo " + self.entretien!.intitule + " " + String(indexImage + 1)  ) {
            
            if pourEDLSortie {
                imageEDL.isImageEDLSortie = true
                entretien?.images?.append(imageEDL)
            } else {
                entretien?.images?.append(imageEDL)
            }
            DispatchQueue.main.async {
                
                self.updateListeImageEDL()
            }
        }
        else { print("erreur")
            
        }
        dismiss(animated: true , completion: nil)
        
        
    }
    
    func updateListeImageEDL() {
        
        imagesEDLImage = [ ]
        if let imagesEDL = entretien?.images {
            if imagesEDL.count > 0 {
                for index in 0...imagesEDL.count - 1 {
                    if let legende = imagesEDL[index].legendText {
                        if let isImageEDLSortie = imagesEDL[index].isImageEDLSortie,
                           isImageEDLSortie {
                            imagesEDLImage?.append(ImageEDLImage(legende: legende, image: chargeImage(idImage: imagesEDL[index].nomImage), isImageEDLSortie: true ))
                        }
                        else {
                            imagesEDLImage?.append(ImageEDLImage(legende: legende, image: chargeImage(idImage: imagesEDL[index].nomImage) ))
                        }
                    }
                    
                }
            }}
        DispatchQueue.main.async {
            self.imagesEDLCollectionView.reloadData()
        }
        
        
    }
    
    // MARK: - Collection View Images
    
    func initCollectionEDLImage() {
        
        // Register the xib for collection cell
        
        self.imagesEDLCollectionView.dataSource = self
        self.imagesEDLCollectionView.delegate = self
        
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 5.0
        self.imagesEDLCollectionView.collectionViewLayout = flowLayout
        self.imagesEDLCollectionView.showsHorizontalScrollIndicator = false
        
        
        let cellNib = UINib(nibName: "ImageEDLCollectionViewCell", bundle: nil)
        self.imagesEDLCollectionView.register(cellNib, forCellWithReuseIdentifier: "ImageEDLCollectionViewCell")
        
        updateListeImageEDL()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesEDLImage?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = imagesEDLCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageEDLCollectionViewCell", for: indexPath) as? ImageEDLCollectionViewCell {
            cell.legendLabel.text = imagesEDLImage![indexPath.row].legende
            cell.imageEDL.image = imagesEDLImage![indexPath.row].image
            if imagesEDLImage![indexPath.row].isImageEDLSortie != nil ,
               imagesEDLImage![indexPath.row].isImageEDLSortie! {
                cell.legendLabel.layer.borderWidth = 3
                cell.legendLabel.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            } else {
                cell.legendLabel.layer.borderWidth = 0
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexPathSegue = indexPath
        performSegue(withIdentifier: "legendeImageEntretien", sender: self)
        
    }
    
    // MARK: - Appel à l'édition d'mages
    
    
    // Retour de l'édition de l'image
    @IBAction func unwindFromLegendeImage ( unwindSegue: UIStoryboardSegue ) {
        guard let sourceViewController = unwindSegue.source as? legendeImageTableViewController else { return }
        if let legendText = sourceViewController.imageEDLImage?.legende,
           let indexPath = indexPathSegue {
            if sourceViewController.aSupprimer {
                // On supprime
                imagesEDLImage?.remove(at: indexPath.row)
                supprImage(idImage: (entretien?.images![indexPath.row].nomImage)!)
                entretien?.images?.remove(at: indexPath.row)
            } else {
                // On met à jour la légende
                imagesEDLImage![indexPath.row].legende = legendText
                entretien?.images![indexPath.row].legendText = legendText
            }
            imagesEDLCollectionView.reloadData()
        }
    }
    
    @IBSegueAction func legendeImageSegue(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> legendeImageTableViewController? {
        if segueIdentifier == "legendeImageEntretien" {
            if let indexPath = indexPathSegue {
                return legendeImageTableViewController  (coder: coder, imageEDLImage: imagesEDLImage![indexPath.row])
                
            }}
        return nil
        
        
        
    }
  
    
    
    // MARK: - Configuration des cellules de saisie
    
    
    
    var tabHauteurCelulle: [ IndexPath : [CGFloat] ] = [
        IndexPath(row: 0, section: 0) : [45, 45] ,                        // Nom Entretien
        IndexPath(row: 0, section: 1) : [45, 45] ,                        // Caractéristiques Fréquence
        IndexPath(row: 1, section: 1) : [45, 45] ,                        // Caractéristiques Actif
        IndexPath(row: 0, section: 2) : [45, 90] ,                        // observations
        IndexPath(row: 0, section: 3) : [45 , 45]  ,                     // collectionView Photos
        IndexPath(row: 1, section: 3) : [132 , 132]                       // collectionView Photos
        
    ]
    
    var tabHauteurSection: [ Int : [CGFloat]] = [
        0 : [25, 25] ,    // Nom Entretien
        1 : [25, 25] ,    // Caractéristiques
        2 : [25, 25] ,    // Observations
        3 : [25, 25]      // collectionView Photos
    ]
    
    
    
    fileprivate func disableEntreeConfigureSortie() {
        
        for tf in [ observationSortieEntretienTextField ] {
            tf!.layer.borderWidth = 3
            tf!.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
        
        for tf in [ observationEntretienTextField ] {
           
            if tf!.text! != "" && tf!.text! != "0" {
                tf?.isEnabled = false
                tf?.backgroundColor = .systemGray6
            } else {
                tf?.isHidden = true
            }
        }

        
        
    }
    
    fileprivate func masqueSortie() {
        // on masque les champs pour la sortie (ajout (EDLSortie ou pas) et modif pas EDL Sortie
        
        observationSortieStack.isHidden = true
        
    }
    
    fileprivate func masqueEntree() {
        // on masque les champs d'entrée cas ou on ajoute un nouvel item pour la sortie (ajout (EDLSortie ou pas) et modif pas EDL Sortie
        
        observationEntreeStack.isHidden = true
        
    }
    
    /// Configuration de la saisie des informations
    ///
    ///* Saisie EDL initial en ajout ou en modif ( pourEDLSortie == false ),
    ///     * On saisie dans les champs Entrée
    ///     * On masque les champs de sortie
    ///* Saisie EDL en sortie avec saisie antérieure, premiere saisie ( pourEDLSortie == true ) && ( estItemSortieAvecAnteriorite == true )   && (champ de saisie Sortie à vide)
    ///     * On initialise nExemplaire et les boutons avec les valeurs antérieures
    ///     * On affiche les champs de sortie et d'entrée
    ///     * Les champs d'entrée sont présentés non modifiables
    ///* Saisie EDL en sortie avec saisie antérieure, saisies suivantes ( pourEDLSortie == true ) && ( estItemSortieAvecAnteriorite == true )   && (champ de saisie Sortie non vide)
    ///     * On initialise nExemplaire et les boutons avec les valeurs précédentes en champ de sortie
    ///     * On affiche les champs de sortie et d'entrée
    ///     * Les champs d'entrée sont présentés non modifiables
    ///* Saisie EDL en sortie sans saisie antérieure, premiere saisie  ( pourEDLSortie == true ) && ( estItemSortieAvecAnteriorite == false )   && (champ de saisie Sortie vide)
    ///     * On masque les champs d'entrée
    ///     * On saisie les champs de sortie
    ///     * Indication de non saisie initiale ?
    ///* Saisie EDL en sortie sans saisie antérieure, saisie suivante  ( pourEDLSortie == true ) && ( estItemSortieAvecAnteriorite == false )   && (champ de saisie Sortie non vide)
    ///     * On masque les champs d'entrée
    ///     * On saisie les champs de sortie avec valeur précédentes
    ///     * Indication de non saisie initiale ?
    ///
    func configureDisplayEntreeSortie() {
        // Display les valeurs présentes en entree et sortie
        
        guard let entretien = self.entretien else { return }
        intituleTextField.text = entretien.intitule
        realiseSwitch.isOn = entretien.realise
        dateEcheanceEntretienTextField.text = entretien.dateEcheanceEntretien
        
        
        
        if let observationEntree = entretien.observationEntretien,
        observationEntree != "" {
            observationEntretienTextField.text = observationEntree
        } else {
            if pourEDLSortie {
                // On masque la ligne de releve
                observationEntreeStack.isHidden = true
                tabHauteurCelulle[IndexPath(row: 0, section: 2)]?[1] = 45
                
            }
        }
        
        
        if !estItemSortieAvecAnteriorite && pourEDLSortie {
            // On masque l'entree vide , On est sur EDL Sortie et pas d'entrée
            observationEntreeStack.isHidden = true
        }
        
        
        
        
        
        if pourEDLSortie {
            if let observationSortie = entretien.observationEntretienSortie {
                observationSortieEntretienTextField.text = observationSortie
            }
            
            
        }
        
        // Réalisation des cas identifiés
        // Cas 1
        if !pourEDLSortie {
            masqueSortie()
        }
        if pourEDLSortie {
            // Cas 2 et 3
            disableEntreeConfigureSortie()
            
        }
        
        if pourEDLSortie && !modeModif {
            // cas 4 et 5
            disableEntreeConfigureSortie()
            masqueEntree()
            
        }
        
        
        
        
        //   if #available(iOS 15.0, *) {
        //       tableView.sectionHeaderTopPadding = 15
        //       tableView.sectionFooterHeight = 0
        //   }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if modeModif {
            return tabHauteurSection[section]![pourEDLSortie ? 1 : 0]
        }
        else {
            return tabHauteurSection[section]![0]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if modeModif {
            return tabHauteurCelulle [indexPath]![pourEDLSortie ? 1 : 0]
        } else {
            return tabHauteurCelulle [indexPath]![0] // on affiche tout
        }
    }
    
    
}
 

   

