//
//  EquipementDetailTableViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 11/01/2023.
//

import UIKit

protocol EquipementDetailTableViewControllerDelegate: AnyObject {
    // Permet de mettre à jour avant de faire disparaitre le compteur (Controlleur et snapshot)
    func equipementDetailTableViewController (_ equipementDetailTableViewController: EquipementDetailTableViewController, didModifyEquipement  equipement: Equipement )
}


class EquipementDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Conformité Protocole ListImageEDL
    
    var imagesEDLImage: [ImageEDLImage]?
    var indexPathSegue: IndexPath?
    
    
    
    
    
    // MARK: - Properties
    var modeModif: Bool = false
    var equipement: Equipement?
    var piece: Categorie?
    var pourEDLSortie = false  // L'équipement est associée à un EDL de Sortie relatif à un EDL d'entrée initialement géré dans l'appli
    var estItemSortieAvecAnteriorite = false // L'équipement est en saisie de sortie et dispose de données antérieures
    weak var delegate: EquipementDetailTableViewControllerDelegate?
    
    
    @IBOutlet var valideBarButton: UIBarButtonItem!
    @IBOutlet var retourBarButton: UIBarButtonItem!
    
    @IBOutlet var equipementTextField: UITextField!
    
    @IBOutlet var observationEntreeLabel: UILabel!
    
    @IBOutlet var observationEntreeLibelleLabel: UILabel!
    @IBOutlet var observationEntreeTextField: UITextField!
    @IBOutlet var observationEntreeStack: UIStackView!
    @IBOutlet var observationSortieTextField: UITextField!
    @IBOutlet var observationSortieStack: UIStackView!
    
    
    @IBOutlet var nExemplaireEntreeTextField: UITextField!
    @IBOutlet var nExemplaireSortieTextField: UITextField!
    @IBOutlet var nExemplaireEntreeLibelleLabel: UILabel!
    @IBOutlet var nExemplaireSortieLibelleLabel: UILabel!
    
    @IBOutlet var etatEnTeteStack: UIStackView!
    
    @IBOutlet var etatEntreeButton: EtatButton!
    @IBOutlet var etatSortieButton: EtatButton!
    
    @IBOutlet var propreteEntreeButton: PropreteButton!
    @IBOutlet var propreteSortieButton: PropreteButton!
    
    @IBOutlet var fonctionnelEntreeButton: FonctionnelButton!
    @IBOutlet var fonctionnelSortieButton: FonctionnelButton!
    
    @IBOutlet var prendrePhoto: UIButton!
    @IBOutlet var importerPhoto: UIButton!
    
    @IBOutlet var imagesEDLCollectionView: UICollectionView!
    
    
    
    
    // MARK: Cycle de vie
    
    init?(equipement: Equipement, piece: Categorie, modeModif: Bool, coder: NSCoder) {
        self.equipement = equipement
        self.piece = piece
        self.modeModif = modeModif
        super.init(coder: coder)
    }
    
    init?(piece: Categorie, coder: NSCoder) {
        self.piece = piece
        self.equipement = Equipement( idCategorie: piece.idCategorie, equipement: "", etat: .nondefini, fonctionnel: .nondefini, proprete: .nondefini)
        self.modeModif = false
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Ajout d'un équipement"
        
        self.navigationItem.prompt = piece?.nomCategorie
        
        // Determination du type d'EDL : standard ou EDL de Sortie relié à un EDL d'entrée avec antériorité ou pas
        if let edl = EDLsController.selectedEDLedl() {
            pourEDLSortie =  edl.isEDLSortieApresEntree
            
            // Calcul estItemSortieAvecAnteriorite
            var presenceObservation: Bool = false
            var presenceExemplaire: Bool = false
            var boutonRenseigne: Bool = false
            
            if let equipement = equipement {
                if let observations = equipement.observations,
                   observations != "" {
                    presenceObservation = true
                }
                if equipement.nExemplaire != nil {
                    presenceExemplaire = true
                }
                if equipement.etat != .nondefini && equipement.etat != .nonapplicable  ||
                    equipement.proprete != .nondefini && equipement.proprete != .nonapplicable ||
                    equipement.fonctionnel != .nondefini && equipement.fonctionnel != .nonapplicable {
                    boutonRenseigne = true
                }
            }
            estItemSortieAvecAnteriorite = presenceExemplaire || presenceObservation || boutonRenseigne
        }
        
        // Configuration des boutons de nav
        if modeModif {
            // On masque le bouton droit OK et on renomme le bouton gauche en Retour
            retourBarButton.title = "Retour"
            if #available(iOS 16.0, *) {
                valideBarButton.isHidden = true
            } else {
                valideBarButton.title = ""
            }
            title = equipement?.equipement
        } else {
            // On cree une equipement : Bouton droit = OK et gauche "Annuler"
            retourBarButton.title = "Annuler"
            valideBarButton.title = "OK"
            if #available(iOS 16.0, *) {
                valideBarButton.isHidden = false
            }
            title = "Ajout d'un equipement"
        }
        
        majButtonPhoto()
        updateSaveButtonState()
        
        configureDisplayEntreeSortie()
        
        initCollectionEDLImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("willDisappear")
        //     super.viewWillDisappear(animated)
        
    }
    
    
    // MARK: - Fonctions
    
    func majButtonPhoto() {
        prendrePhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        importerPhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    func updateSaveButtonState() {
        let equipement = equipementTextField.text ?? ""
        valideBarButton.isEnabled = !equipement.isEmpty
    }
    
    
    
    @IBAction func valideBarButton(_ sender: UIBarButtonItem) {
        print("Valide")
        sauveEquipement()
    }
    
    
    @IBAction func editNomBien() {
        self.title = self.equipementTextField.text
        self.updateSaveButtonState()
    }
    
    fileprivate func sauveEquipement() {
        print("SauveEquipement")
        if equipementTextField.text != "" {
            
            if !pourEDLSortie {
                equipement?.equipement = equipementTextField.text!
                equipement?.observations = observationEntreeTextField.text!
                
                if let stringNExemplaire = nExemplaireEntreeTextField.text,
                   let nExemplaire = Int(stringNExemplaire) {
                    equipement?.nExemplaire = nExemplaire
                } else {
                    equipement?.nExemplaire = nil
                }
                
                equipement?.etat = etatEntreeButton.etat
                equipement?.proprete = propreteEntreeButton.proprete
                equipement?.fonctionnel = fonctionnelEntreeButton.fonctionnel
                
            } else {
                if !modeModif {
                    equipement?.equipement = equipementTextField.text!
                }
                equipement?.observationsSortie = observationSortieTextField.text!
                
                if tabHauteurSection[2]![1] != 0 {
                    // La section du nombre d'exemplaire était affichée, on sauvegarde la valeur de sortie
                    if let stringNExemplaireSortie = nExemplaireSortieTextField.text,
                       let nExemplaireSortie = Int(stringNExemplaireSortie) {
                        equipement?.nExemplaireSortie = nExemplaireSortie
                    } else {
                        // On a effacé la valeur précédemment saisie, on met 0
                        if (equipement?.nExemplaire) != nil {
                            equipement?.nExemplaireSortie = 0
                        } else {
                            equipement?.nExemplaireSortie = nil
                        }
                    }
                }
                
                equipement?.etatSortie = etatSortieButton.etat
                equipement?.propreteSortie = propreteSortieButton.proprete
                equipement?.fonctionnelSortie = fonctionnelSortieButton.fonctionnel
                
            }
            self.delegate?.equipementDetailTableViewController(self, didModifyEquipement: self.equipement!)
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        guard let senderObj = sender as? UIBarButtonItem else { return }
        if senderObj == valideBarButton {
            sauveEquipement()
        } else  if senderObj == retourBarButton {
            if modeModif {
                sauveEquipement()
            } else {
                // On efface le compteur initialisé
                // On efface les données de photos
                if let equipement = equipement,
                   let images = equipement.images {
                    for image in images {
                        supprImage(idImage: image.nomImage)
                    }
                }
                equipement = nil
            }
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
    
    func updateListeImageEDL() {
        
        imagesEDLImage = [ ]
        if let imagesEDL = equipement?.images {
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
        performSegue(withIdentifier: "legendeImageEquipement", sender: self)
        
    }
    
    // MARK: - Prise de photo
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
        if let n = equipement?.images?.count {
            indexImage = n
        } else { equipement?.images = [] }
        if var imageEDL = ajoutImageEDL(inImage: selectedImage, inLegende: "Photo " + self.equipement!.equipement + " " + String(indexImage + 1)  ) {
            if pourEDLSortie {
                imageEDL.isImageEDLSortie = true
                equipement?.images?.append(imageEDL)
            } else {
                equipement?.images?.append(imageEDL)
            }
            
            DispatchQueue.main.async {
                
                self.updateListeImageEDL()
            }
        }
        else { print("erreur")
            
        }
        dismiss(animated: true , completion: nil)
        
        
    }
    
    // Retour de l'édition de l'image
    @IBAction func unwindFromLegendeImage ( unwindSegue: UIStoryboardSegue ) {
        guard let sourceViewController = unwindSegue.source as? legendeImageTableViewController else { return }
        if let legendText = sourceViewController.imageEDLImage?.legende,
           let indexPath = indexPathSegue {
            if sourceViewController.aSupprimer {
                // On supprime
                imagesEDLImage?.remove(at: indexPath.row)
                supprImage(idImage: (equipement?.images![indexPath.row].nomImage)!)
                equipement?.images?.remove(at: indexPath.row)
            } else {
                // On met à jour la légende
                
                if pourEDLSortie {
                    // Si on a changé le texte de la legende on tague l'image comme modifié dans le cadre de l'EDL de Sortie
                    if legendText != imagesEDLImage![indexPath.row].legende {
                        equipement?.images![indexPath.row].isImageEDLSortie = true
                        imagesEDLImage![indexPath.row].isImageEDLSortie = true
                    }
                }
                imagesEDLImage![indexPath.row].legende = legendText
                equipement?.images![indexPath.row].legendText = legendText
            }
            imagesEDLCollectionView.reloadData()
        }
        
    }
    @IBSegueAction func legendeImageSegue(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> legendeImageTableViewController? {
        
        
        if segueIdentifier == "legendeImageEquipement" {
            if let indexPath = indexPathSegue {
                return legendeImageTableViewController  (coder: coder, imageEDLImage: imagesEDLImage![indexPath.row])
                
            }}
        return nil
        
    }
    
    // MARK: - Gestion des bouttons
    
    
    @IBAction func actiontriggeredEtatButton() {
        etatEntreeButton.updateEtatButton()
        //     tableView.reloadRows(at: [IndexPath(row: 2, section: 0)] , with: .automatic)
    }
    
    @IBAction func actiontriggeredEtatSortieButton() {
        etatSortieButton.updateEtatButton()
        //     tableView.reloadRows(at: [IndexPath(row: 2, section: 0)] , with: .automatic)
    }
    
    
    @IBAction func actiontriggeredPropreteButton() {
        propreteEntreeButton.updatePropreteButton()
    }
    
    @IBAction func actiontriggeredPropreteSortieButton() {
        propreteSortieButton.updatePropreteButton()
    }
    
    
    @IBAction func actiontriggeredFonctionnelButton() {
        fonctionnelEntreeButton.updateFonctionnelButton()
    }
    
    @IBAction func actiontriggeredFonctionnelSortieButton() {
        fonctionnelSortieButton.updateFonctionnelButton()
    }
    
    // MARK: - Configuration des cellules de saisie
    
    
    
    var tabHauteurCelulle: [ IndexPath : [CGFloat] ] = [
      IndexPath(row: 0, section: 0) : [45, 0] ,                         // Nom Equipement
      IndexPath(row: 0, section: 1) : [45, 90] ,                        // Observation
      IndexPath(row: 0, section: 2) : [45, 45] ,                        // Nombre Exemplaire
      IndexPath(row: 0, section: 3) : [(46+3)*3 , (46+3)*3 + 25 + 3],   // tableau de bouton
      IndexPath(row: 0, section: 4) : [34 + 10,34+10],                  // Boutons photos
      IndexPath(row: 1, section: 4) : [132 , 132]                       // collectionView Photos
      
     ]
    
    var tabHauteurSection: [ Int : [CGFloat]] = [
      0 : [25,  0] ,    // Nom Equipement
      1 : [25, 25] ,    // Observation
      2 : [25, 25] ,    // Nombre Exemplaire
      3 : [25, 25] ,    // tableau de bouton
      4 : [25, 25] ,    // Boutons photos
      5 : [25, 25]      // collectionView Photos
     ]
    
    
    
    fileprivate func disableEntreeConfigureSortie() {
        nExemplaireSortieTextField.layer.borderWidth = 3
        nExemplaireSortieTextField.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        nExemplaireEntreeTextField.isEnabled = false
        
        
        observationSortieTextField.layer.borderWidth = 3
        observationSortieTextField.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        observationEntreeTextField.isEnabled = false
        
        etatEntreeButton.isEnabled = false
        etatSortieButton.layer.borderWidth = 3
        etatSortieButton.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        
        propreteEntreeButton.isEnabled = false
        propreteSortieButton.layer.borderWidth = 3
        propreteSortieButton.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        fonctionnelEntreeButton.isEnabled = false
        fonctionnelSortieButton.layer.borderWidth = 3
        fonctionnelSortieButton.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
    
    fileprivate func masqueSortie() {
        // on masque les champs pour la sortie (ajout (EDLSortie ou pas) et modif pas EDL Sortie
        
        nExemplaireEntreeLibelleLabel.isHidden = true
        nExemplaireSortieLibelleLabel.isHidden = true
        nExemplaireSortieTextField.isHidden = true
        
        
        observationEntreeLibelleLabel.isHidden = true
        observationSortieStack.isHidden = true
        
        
        etatEnTeteStack.isHidden = true
        
        etatSortieButton.isHidden = true
        propreteSortieButton.isHidden = true
        fonctionnelSortieButton.isHidden = true
    }
    
    fileprivate func masqueEntree() {
        // on masque les champs d'entrée cas ou on ajoute un nouvel item pour la sortie (ajout (EDLSortie ou pas) et modif pas EDL Sortie
        
        nExemplaireEntreeLibelleLabel.isHidden = true
        nExemplaireSortieLibelleLabel.isHidden = true
        nExemplaireEntreeTextField.isHidden = true
        
        
        observationEntreeLibelleLabel.isHidden = true
        observationEntreeTextField.isHidden = true
        
        
        etatEnTeteStack.isHidden = true
        
        etatEntreeButton.isHidden = true
        propreteEntreeButton.isHidden = true
        fonctionnelEntreeButton.isHidden = true
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
        
        guard let equipement = self.equipement else { return }
        equipementTextField.text = equipement.equipement
        
        if let observations = equipement.observations,
           observations != "" && observations != " "
        { observationEntreeTextField.text = observations
        } else {
            if pourEDLSortie && estItemSortieAvecAnteriorite {
                // On masque le label d'affichage de l'observation d'entree non renseigné initialement
                tabHauteurCelulle[IndexPath(row: 0, section: 1)] = [45, 45]
                observationEntreeStack.isHidden = true
            }
        }
        
        if let nExemplaire = equipement.nExemplaire {
            nExemplaireEntreeTextField.text = String(nExemplaire)
        } else {
            if pourEDLSortie && estItemSortieAvecAnteriorite {
                // On masque la section du nombre d'exemplaire car pas de nombre renseigné initialement
                tabHauteurCelulle[IndexPath(row: 0, section: 2)] = [45, 0]
                tabHauteurSection[2] = [25, 0]
            }
        }
        etatEntreeButton.etat = equipement.etat
        propreteEntreeButton.proprete = equipement.proprete
        fonctionnelEntreeButton.fonctionnel = equipement.fonctionnel
        etatEntreeButton.updateEtatButton()
        fonctionnelEntreeButton.updateFonctionnelButton()
        propreteEntreeButton.updatePropreteButton()
        
        var presencenExemplaire: Bool = false
        var presenceBouttonEtat: Bool = false
        var presenceBouttonProprete: Bool = false
        var presenceBouttonFonctionnel: Bool = false
        
        if pourEDLSortie {
            if let observationsSortie = equipement.observationsSortie {
                observationSortieTextField.text = observationsSortie
            }
            if let nExemplaireSortie = equipement.nExemplaireSortie {
                nExemplaireSortieTextField.text = String(nExemplaireSortie)
                presencenExemplaire = true
            }
            if let etatSortie = equipement.etatSortie {
                etatSortieButton.etat = etatSortie
                presenceBouttonEtat = true
            }
            if let propreteSortie = equipement.propreteSortie {
                propreteSortieButton.proprete = propreteSortie
                presenceBouttonProprete = true
            }
            if let fonctionnelSortie = equipement.fonctionnelSortie {
                fonctionnelSortieButton.fonctionnel = fonctionnelSortie
                presenceBouttonFonctionnel = true
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
            
            // Cas 2 Premiere Saisie : on teste la présence de valeur, si pas de valeur on initialise
            //      pour nExemplaire avec la valeur antérieure
            //      pour Observation pas d'initialisation
            //      Pour les bouttons avec les valeurs précédentes
            if !presencenExemplaire {
                if let nExemplaireEntree = equipement.nExemplaire {
                    nExemplaireSortieTextField.text = String(nExemplaireEntree)
                }
            }
            
            if !presenceBouttonEtat {
                etatSortieButton.etat = etatEntreeButton.etat
            }
            if !presenceBouttonProprete {
                propreteSortieButton.proprete = propreteEntreeButton.proprete
            }
            if !presenceBouttonFonctionnel {
                fonctionnelSortieButton.fonctionnel = fonctionnelEntreeButton.fonctionnel
            }
            etatSortieButton.updateEtatButton()
            fonctionnelSortieButton.updateFonctionnelButton()
            propreteSortieButton.updatePropreteButton()
        }
        
        if pourEDLSortie && !estItemSortieAvecAnteriorite {
            // cas 4 et 5
            disableEntreeConfigureSortie()
            masqueEntree()
            
            etatSortieButton.updateEtatButton()
            fonctionnelSortieButton.updateFonctionnelButton()
            propreteSortieButton.updatePropreteButton()
            
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

