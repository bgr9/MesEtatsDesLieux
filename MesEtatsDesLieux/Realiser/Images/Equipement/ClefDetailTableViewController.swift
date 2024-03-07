//
//  ClefDetailTableViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 11/01/2023.
//

import UIKit

protocol ClefDetailTableViewControllerDelegate: AnyObject {
    // Permet de mettre à jour avant de faire disparaitre le compteur (Controlleur et snapshot)
    func clefDetailTableViewController (_ clefDetailTableViewController: ClefDetailTableViewController, didModifyClef  clef: Clef )
}


class ClefDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Conformité Protocole ListImageEDL

    var imagesEDLImage: [ImageEDLImage]?
    var indexPathSegue: IndexPath?
    
  
    
    
   
    // MARK: - Properties
    var modeModif: Bool = false
    var clef: Clef?
    weak var delegate: ClefDetailTableViewControllerDelegate?
    
    
    @IBOutlet var valideBarButton: UIBarButtonItem!
    @IBOutlet var retourBarButton: UIBarButtonItem!
       
    @IBOutlet var intituleClefTextField: UITextField!
    @IBOutlet var observationClefTextField: UITextField!
    @IBOutlet var nombreClefsTextField: UITextField!
       
    @IBOutlet var prendrePhoto: UIButton!
    @IBOutlet var importerPhoto: UIButton!
       
    @IBOutlet var imagesEDLCollectionView: UICollectionView!
    

   

    // MARK: Cycle de vie
    
    init?(clef: Clef, modeModif: Bool, coder: NSCoder) {
        self.clef = clef
        self.modeModif = modeModif
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.clef = Clef( idCategorie: CategorieController.categorieUUID(nomCategorie: libelleClefs), intituleClef: "", nombreClefs: 0, observationClef: "")
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Ajout d'une clef"
        majButtonPhoto()
        updateSaveButtonState()
        displayItem()
        initCollectionEDLImage()
        if modeModif {
            // On masque le bouton droit OK et on renomme le bouton gauche en Retour
            retourBarButton.title = "Retour"
            valideBarButton.isHidden = true
            title = clef?.intituleClef
            
        } else {
            // On cree une catagorie : Bouton droit = OK et gauche "Annuler"
            retourBarButton.title = "Annuler"
            valideBarButton.title = "OK"
            valideBarButton.isHidden = false
            title = "Ajout"
        }
    }
    
    // MARK: - Fonctions
    
    func majButtonPhoto() {
        prendrePhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        importerPhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    func updateSaveButtonState() {
        let intituleClef = intituleClefTextField.text ?? ""
        valideBarButton.isEnabled = !intituleClef.isEmpty
    }
    
    
    func displayItem() {
        
        if let intituleClef = clef?.intituleClef { intituleClefTextField.text = intituleClef }
        if let observationClef = clef?.observationClef { observationClefTextField.text = observationClef}
        if let nombreClef = clef?.nombreClefs { nombreClefsTextField.text = String(nombreClef)}

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
        if let imagesEDL = clef?.images {
            if imagesEDL.count > 0 {
                for index in 0...imagesEDL.count - 1 {
                    if let nomImage = clef?.images?[index].nomImage,
                       let legende = clef?.images?[index].legendText {
                        imagesEDLImage?.append(ImageEDLImage(legende: legende, image: chargeImage(idImage: nomImage) ))
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
            
            
            //             let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:)))
            //           cell.addGestureRecognizer(tapGestureRecognizer)
            
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
        if let n = clef?.images?.count {
            indexImage = n
        } else { clef?.images = [] }
        if let imageEDL = ajoutImageEDL(inImage: selectedImage, inLegende: "Photo " + self.clef!.intituleClef + " " + String(indexImage + 1)  ) {
            clef?.images?.append(imageEDL)
            
            DispatchQueue.main.async {
                
                self.updateListeImageEDL()
            }
        }
        else { print("erreur")
            
        }
        dismiss(animated: true , completion: nil)
        
        
    }
    
    
}
