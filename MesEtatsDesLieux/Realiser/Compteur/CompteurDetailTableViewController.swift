//
//  CompteurDetailTableViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 19/12/2022.
//

import UIKit

protocol CompteurDetailTableViewControllerDelegate: AnyObject {
    // Permet de mettre à jour avant de faire disparaitre le compteur (Controlleur et snapshot)
    func compteurDetailTableViewController (_ compteurDetailTableViewController: CompteurDetailTableViewController?, didModifyCompteur  compteur: Compteur )
}


class CompteurDetailTableViewController: UITableViewController , UIImagePickerControllerDelegate & UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    var modeModif: Bool = false
    var compteur: Compteur?
    
    var pourEDLSortie = false  // Le compteur est associée à un EDL de Sortie relatif à un EDL d'entrée initialement géré dans l'appli
    var estItemSortieAvecAnteriorite = false // La fourniture est en saisie de sortie et dispose de données antérieures
    
    
    
    weak var delegate: CompteurDetailTableViewControllerDelegate?
    
    // En miroir de compteur, tableau (legend, UIImage obtenue à partir du chargemet du fichier)
    var imagesEDLImage : [ImageEDLImage]?
    
    
    @IBOutlet var valideBarButton: UIBarButtonItem!
    @IBOutlet var retourBarButton: UIBarButtonItem!
    
    @IBOutlet var nomCompteurTextField: UITextField!
    @IBOutlet var localisationCompteurTextField: UITextField!
    
    @IBOutlet var enServiceEntree: UISwitch!
    @IBOutlet var enServiceSortie: UISwitch!
    
    @IBOutlet var entreeLibelleLabel: UILabel!
    @IBOutlet var indexCompteurTextField: UITextField!
    @IBOutlet var uniteCompteurTextField: UITextField!
    @IBOutlet var motifNonReleveTextField: UITextField!
    @IBOutlet var releveEntreeStack: UIStackView!
    @IBOutlet var motifEntreeStack: UIStackView!
    @IBOutlet var indexEntreeStack: UIStackView!
    
    @IBOutlet var indexCompteurSortieTextField: UITextField!
    @IBOutlet var uniteCompteurSortieTextField: UITextField!
    @IBOutlet var motifNonReleveSortieTextField: UITextField!
    @IBOutlet var indexSortieStack: UIStackView!
    
    @IBOutlet var prendrePhoto: UIButton!
    @IBOutlet var importerPhoto: UIButton!
    
    @IBOutlet var imagesEDLCollectionView: UICollectionView!
    
    // Utiliser pour palier que l'on ne peut pas récupérer la cellule éditée car la class EquipementTableViewCell ne peut pas déclencher le segue
    // au lieu de cela on le déclenche manuellement depuis le didSelect de la table en mettant de coté l'indexPath sélectionne
    var indexPathSegue: IndexPath?
    
    // var images: [ImageEDL]?
    
    
    // MARK: Cycle de vie
    
    init?(compteur: Compteur, modeModif: Bool, coder: NSCoder) {
        self.compteur = compteur
        self.modeModif = modeModif
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.compteur = Compteur(idCategorie: CategorieController.categorieUUID(nomCategorie: "Compteurs"), nomCompteur: "", enServicePresent: false, indexCompteur: 0, uniteCompteur: "", localisationCompteur: "", motifNonReleve: "")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Relevé du compteur"
        self.navigationItem.prompt = libelleCompteur
        
        // Determination du type d'EDL : standard ou EDL de Sortie relié à un EDL d'entrée avec antériorité ou pas
        if let edl = EDLsController.selectedEDLedl() {
            pourEDLSortie =  edl.isEDLSortieApresEntree
            
            // Calcul estItemSortieAvecAnteriorite
            var presenceReleveCompteur: Bool = false
            
            
            if let compteur = compteur {
                if compteur.indexCompteur != nil {
                    presenceReleveCompteur = true
                }
                if let motifNonReleve = compteur.motifNonReleve,
                   motifNonReleve != "" {
                    presenceReleveCompteur = true
                }
            }
            estItemSortieAvecAnteriorite = presenceReleveCompteur
        }
        
        if modeModif {
            // On masque le bouton droit OK et on renomme le bouton gauche en Retour
            retourBarButton.title = "Retour"
            if #available(iOS 16.0, *) {
                valideBarButton.isHidden = true
            } else {
                valideBarButton.title = ""
            }
            title = compteur?.nomCompteur
            
        } else {
            // On cree uncompteur : Bouton droit = OK et gauche "Annuler"
            retourBarButton.title = "Annuler"
            valideBarButton.title = "OK"
            if #available(iOS 16.0, *) {
                valideBarButton.isHidden = false
            }
            title = "Ajout d'un relevé"
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
    
    
  
    
    fileprivate func sauveCompteur() {
        print("SauveCompteur")
        if var compteur = compteur {
            if nomCompteurTextField.text != "" {
                compteur.nomCompteur =  nomCompteurTextField.text!
                compteur.localisationCompteur = localisationCompteurTextField.text!
                compteur.enServicePresent = enServiceEntree.isOn
                compteur.indexCompteur = Int(indexCompteurTextField.text!) ?? 0
                compteur.uniteCompteur = uniteCompteurTextField.text!
                compteur.motifNonReleve = motifNonReleveTextField.text!
                
                if pourEDLSortie {
                    
                    compteur.enServicePresentSortie = enServiceSortie.isOn
                    
                    if  indexCompteurSortieTextField.text != "",
                        let indexSortie = Int(indexCompteurSortieTextField.text!) {
                        compteur.indexCompteurSortie = indexSortie
                    }
                    if uniteCompteurSortieTextField.text != "" {
                        compteur.uniteCompteurSortie = uniteCompteurSortieTextField.text!
                    }
                    if motifNonReleveSortieTextField.text != "" {
                        compteur.motifNonReleveSortie = motifNonReleveSortieTextField.text!
                    }
                }
                self.compteur = compteur
                self.delegate?.compteurDetailTableViewController(self, didModifyCompteur: self.compteur!)
                
                
            }
        }
    }
    
    @IBAction func valideBarButton(_ sender: UIBarButtonItem) {
        print("Valide")
        sauveCompteur()
        
    }
    
    @IBAction func editNomBien(_ sender: Any) {
        self.title = self.nomCompteurTextField.text
        self.updateSaveButtonState()
    }
    
    func majButtonPhoto() {
        prendrePhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        importerPhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    func updateSaveButtonState() {
        let nomCompteur = nomCompteurTextField.text ?? ""
        valideBarButton.isEnabled = !nomCompteur.isEmpty
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        guard let senderObj = sender as? UIBarButtonItem else { return }
        if senderObj == valideBarButton {
            sauveCompteur()
        } else  if senderObj == retourBarButton {
            if modeModif {
                sauveCompteur()
            } else {
                // On efface le compteur initialisé
                // On efface les données de photos
                if let compteur = compteur,
                   let images = compteur.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                compteur = nil
            }
        }
        
        
    }
    
    
    // MARK: - Gestion des photos
    
    // MARK: - Image Picker et prendre photos
    
    
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
        if let n = compteur?.images?.count {
            indexImage = n
        } else { compteur?.images = [] }
        
        if var imageEDL = ajoutImageEDL(inImage: selectedImage, inLegende: "Photo " + self.compteur!.nomCompteur + " " + String(indexImage + 1)  ) {
            if pourEDLSortie {
                imageEDL.isImageEDLSortie = true
                compteur?.images?.append(imageEDL)
            } else {
                compteur?.images?.append(imageEDL)
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
        if let imagesEDL = compteur?.images {
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
        performSegue(withIdentifier: "legendeImageCompteur", sender: self)
        
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
                supprImage(idImage: (compteur?.images![indexPath.row].nomImage)!)
                compteur?.images?.remove(at: indexPath.row)
            } else {
                // On met à jour la légende
                if pourEDLSortie {
                    // Si on a changé le texte de la legende on tague l'image comme modifié dans le cadre de l'EDL de Sortie
                    if legendText != imagesEDLImage![indexPath.row].legende {
                        compteur?.images![indexPath.row].isImageEDLSortie = true
                        imagesEDLImage![indexPath.row].isImageEDLSortie = true
                    }
                }
                
                imagesEDLImage![indexPath.row].legende = legendText
                compteur?.images![indexPath.row].legendText = legendText
            }
            imagesEDLCollectionView.reloadData()
        }
        
        
    }
    
    // Appel à l'édit / modif de l'image
    @IBSegueAction func legendeImage(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> legendeImageTableViewController? {
        if segueIdentifier == "legendeImageCompteur" {
        if let indexPath = indexPathSegue {
            return legendeImageTableViewController  (coder: coder, imageEDLImage: imagesEDLImage![indexPath.row])
            
        }}
    return nil
    }
    
    
    
    // MARK: - Configuration des cellules de saisie
    
    
    
    var tabHauteurCelulle: [ IndexPath : [CGFloat] ] = [
        IndexPath(row: 0, section: 0) : [100, 100] ,                        // Nom compteur
        IndexPath(row: 0, section: 1) : [120, 240] ,                        // Index du compteur
        IndexPath(row: 0, section: 2) : [44 , 44]  ,                     // collectionView Photos
        IndexPath(row: 1, section: 2) : [132 , 132]                       // collectionView Photos
        
    ]
    
    var tabHauteurSection: [ Int : [CGFloat]] = [
        0 : [25, 25] ,    // Nom Equipement
        1 : [25, 25] ,    // Index
        2 : [25, 25]      // collectionView Photos
    ]
    
    
    
    fileprivate func disableEntreeConfigureSortie() {
        
        for tf in [ indexCompteurSortieTextField, uniteCompteurSortieTextField, motifNonReleveSortieTextField , enServiceSortie] {
            tf!.layer.borderWidth = 3
            tf!.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
        
        for tf in [ indexCompteurTextField, uniteCompteurTextField, motifNonReleveTextField ] {
           
            if tf!.text! != "" && tf!.text! != "0" {
                tf?.isEnabled = false
                tf?.backgroundColor = .systemGray6
            } else {
                tf?.isHidden = true
            }
        }
        enServiceEntree.isEnabled = false

        
        
    }
    
    fileprivate func masqueSortie() {
        // on masque les champs pour la sortie (ajout (EDLSortie ou pas) et modif pas EDL Sortie
        
        entreeLibelleLabel.isHidden = true
        indexSortieStack.isHidden = true
    }
    
    fileprivate func masqueEntree() {
        // on masque les champs d'entrée cas ou on ajoute un nouvel item pour la sortie (ajout (EDLSortie ou pas) et modif pas EDL Sortie
        
        
        indexEntreeStack.isHidden = true
        
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
        
        guard let compteur = self.compteur else { return }
        nomCompteurTextField.text = compteur.nomCompteur
        if let localisationCompteur = compteur.localisationCompteur {
            localisationCompteurTextField.text = localisationCompteur
        }
        
        if let indexCompteur = compteur.indexCompteur,
           indexCompteur > 0
        {   indexCompteurTextField.text = String(indexCompteur)
        } else {
            if pourEDLSortie {
                // On masque la ligne de releve
                releveEntreeStack.isHidden = true
            }
        }
        if let uniteCompteur = compteur.uniteCompteur {
            uniteCompteurTextField.text = uniteCompteur
        }
        
        if let motifNonReleve = compteur.motifNonReleve
        {   motifNonReleveTextField.text = motifNonReleve
        } else {
            if pourEDLSortie {
                // On masque la ligne de motif
                motifEntreeStack.isHidden = true
            }
        }
        enServiceEntree.isOn = compteur.enServicePresent ?? true
        
        
        if !estItemSortieAvecAnteriorite && pourEDLSortie {
            // On masque l'entree vide , On est sur EDL Sortie et pas d'entrée
            indexEntreeStack.isHidden = true
        }
        
        
        
        
        
        if pourEDLSortie {
            
            if let indexCompteurSortie = compteur.indexCompteurSortie,
               indexCompteurSortie > 0
            {   indexCompteurSortieTextField.text = String(indexCompteurSortie)
            }
            if let uniteCompteurSortie = compteur.uniteCompteurSortie {
                uniteCompteurSortieTextField.text = uniteCompteurSortie
            }
            
            if let motifNonReleveSortie = compteur.motifNonReleveSortie
            {   motifNonReleveSortieTextField.text = motifNonReleveSortie
            }
            
            
            // Si on avait une valeur précédente on la restaure, sinon on recopie la valeur d'entrée
            if let enServicePresentSortie = compteur.enServicePresentSortie {
                enServiceSortie.isOn = enServicePresentSortie
                
            } else {
                enServiceSortie.isOn = enServiceEntree.isOn
            }
            
            
        }
        
        // Réalisation des cas identifiés
        // Cas 1
        if !pourEDLSortie {
            masqueSortie()
        }
        if pourEDLSortie && estItemSortieAvecAnteriorite {
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
