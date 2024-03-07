//
//  SignatureViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 18/02/2023.
//

import UIKit

/// Gestion de la capture de paraphe et de signature
///
/// La séquence d'appel est
/// BiensViewController -> SignatureViewController ( surSignature = false )
///                        ->  SignatureViewController ( surSignature = true )
///                            -> PreviewController
///
///
class SignatureViewController: UIViewController {

    
    @IBOutlet var bailleurLocataireSegmentControl: UISegmentedControl!
    @IBOutlet var signatureView: SignatureView!
    @IBOutlet var jeSigneButton: UIButton!
    @IBOutlet var signatureBailleurLabel: UILabel!
    @IBOutlet var signatureBailleurImageView: UIImageView!
    @IBOutlet var signatureLocataireLabel: UILabel!
    @IBOutlet var signatureLocataireImageView: UIImageView!
    
    @IBOutlet var rightBarButton: UIBarButtonItem!
    
    var actionBien: ActionBien
    var indexPath: IndexPath!
    var delegatePreview: PrevisualiserViewControllerDelegate?
    
    var signatureBailleurPresente: Bool = false
    var signatureLocatairePresente: Bool = false
    
    var parapheBailleurPresente: Bool = false
    var parapheLocatairePresente: Bool = false
    
    var isNouvelleCapture: Bool = false
    
    @IBOutlet var dateSignatureBailleurLabel:  UILabel!
    @IBOutlet var dateSignatureLocataireLabel: UILabel!
    
    
    var surSignature: Bool = true // true = recueil de signature , false recueil de paraphe
    
    
    init?(coder: NSCoder, actionBien: ActionBien, indexPath: IndexPath, surSignature: Bool) {
            self.actionBien = actionBien
            self.indexPath = indexPath
            self.surSignature = surSignature
            self.signatureBailleurPresente = false
            self.signatureLocatairePresente = false
            self.parapheBailleurPresente = false
            self.parapheLocatairePresente = false
            super.init(coder: coder)
       }
     
     required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        signatureView.layer.borderWidth = 0
        signatureView.layer.borderColor = UIColor.black.cgColor
        signatureView.layer.cornerRadius = 10
        
        
        signatureView.setStrokeColor(color: .black)
        
        if !surSignature {
            title = "Paraphe"
            
            var config = jeSigneButton.configuration
            config?.title = "Paraphe bailleur"
            jeSigneButton.configuration = config
            
            rightBarButton.title = "Signature >"
            
        } else {
            title = "Signature"
            var config = jeSigneButton.configuration
            config?.title = "Signature bailleur"
            jeSigneButton.configuration = config
            
            rightBarButton.title = "Document >"
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sauveSignature()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        chargeSignature()
    }
    
    func chargeSignature(){
        
        if let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) {
            if surSignature {
                if let idEmetteur = edl.idEmetteur,
                   let emetteur = EmetteurController.emetteurByUUID(uuidEmetteur: idEmetteur){
                    signatureBailleurLabel.text = emetteur.libelleSignatureBailleur
                    signatureLocataireLabel.text = emetteur.libelleSignatureLocataire

                }
                
                if let signatureBailleurImageEDL = edl.signatureBailleurImageEDL {
                    if existeImage(idImage: signatureBailleurImageEDL.nomImage) {
                        signatureBailleurImageView.image = chargeImage(idImage: signatureBailleurImageEDL.nomImage)
                        dateSignatureBailleurLabel.text = signatureBailleurImageEDL.legendText
                        
                    }
                } else {
                    dateSignatureBailleurLabel.text = ""
                }
                if let signatureLocataireImageEDL = edl.signatureLocataireImageEDL {
                    if existeImage(idImage: signatureLocataireImageEDL.nomImage) {
                        signatureLocataireImageView.image = chargeImage(idImage: signatureLocataireImageEDL.nomImage)
                        dateSignatureLocataireLabel.text = signatureLocataireImageEDL.legendText
                    }
                } else {
                    dateSignatureLocataireLabel.text = ""
                }
            } else {
                signatureBailleurLabel.text = "Paraphe Bailleur"
                signatureLocataireLabel.text = "Paraphe Locataire"
                if let parapheBailleurImageEDL = edl.parapheBailleurImageEDL {
                    if existeImage(idImage: parapheBailleurImageEDL.nomImage) {
                        signatureBailleurImageView.image = chargeImage(idImage: parapheBailleurImageEDL.nomImage)
                        dateSignatureBailleurLabel.text = parapheBailleurImageEDL.legendText
                    }
                } else {
                    dateSignatureBailleurLabel.text = ""
                }
                if let parapheLocataireImageEDL = edl.parapheLocataireImageEDL {
                    if existeImage(idImage: parapheLocataireImageEDL.nomImage) {
                        signatureLocataireImageView.image = chargeImage(idImage: parapheLocataireImageEDL.nomImage)
                        dateSignatureLocataireLabel.text = parapheLocataireImageEDL.legendText
                    }
                    
                } else {
                    dateSignatureLocataireLabel.text = ""
                }
            }
        }
    }
    
    func sauveSignature(){
        
        if let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) {
            var newEDL = edl
            if surSignature {
                if signatureBailleurPresente,
                   let image = signatureBailleurImageView.image,
                   let imageRetaillee = formateSignature(signatureImage: image){
                    let nomImage = EDLsController.nomFichierSignatureBailleur(idEDL: edl.idEDL)
                    _ = sauveImage(inImage: imageRetaillee, nomImage: nomImage)
                    newEDL.signatureBailleurImageEDL = ImageEDL(legendText: dateSignatureBailleurLabel.text, nomImage: nomImage)
                }
                if signatureLocatairePresente,
                   let image = signatureLocataireImageView.image,
                   let imageRetaillee = formateSignature(signatureImage: image){
                    let nomImage = EDLsController.nomFichierSignatureLocataire(idEDL: edl.idEDL)
                    _ = sauveImage(inImage: imageRetaillee, nomImage: nomImage)
                    newEDL.signatureLocataireImageEDL = ImageEDL(legendText: dateSignatureLocataireLabel.text, nomImage: nomImage)
                }
                
                
                
            } else {
                if parapheBailleurPresente,
                   let image = signatureBailleurImageView.image,
                   let imageRetaillee = formateParaphe(signatureImage: image){
                    let nomImage = EDLsController.nomFichierParapheBailleur(idEDL: edl.idEDL)
                    _ = sauveImage(inImage: imageRetaillee, nomImage: nomImage)
                    newEDL.parapheBailleurImageEDL = ImageEDL(legendText: dateSignatureBailleurLabel.text, nomImage: nomImage)
                }
                if parapheLocatairePresente,
                   let image = signatureLocataireImageView.image,
                   let imageRetaillee = formateParaphe(signatureImage: image){
                    let nomImage = EDLsController.nomFichierParapheLocataire(idEDL: edl.idEDL)
                    _ = sauveImage(inImage: imageRetaillee, nomImage: nomImage)
                    newEDL.parapheLocataireImageEDL = ImageEDL(legendText: dateSignatureLocataireLabel.text, nomImage: nomImage)
                }
                
                
            }
            // Sauvegarde sans horodatage pour ne pas périmer les PDF
            _ = EDLsController.majEDL(edl: newEDL, false)
            
        }
    }
    
    func formateSignature (signatureImage: UIImage) -> UIImage? {
        
        let echelleSignature = signatureImage.size.width / signatureImage.size.height
        let nouvelleLargeurSignature = echelleSignature * hauteurSignature
        
        guard let selectedSignatureRetaille = signatureImage.resizeImageTo(size: CGSize(width: nouvelleLargeurSignature, height: hauteurSignature)) else {
          print("Probleme pour retailler la signature")
          return nil}
        return selectedSignatureRetaille
        
        
    }
        
    func formateParaphe (signatureImage: UIImage) -> UIImage? {
        
        let echelleSignature = signatureImage.size.width / signatureImage.size.height
        let nouvelleLargeurSignature = echelleSignature * hauteurParaphe
        
        guard let selectedSignatureRetaille = signatureImage.resizeImageTo(size: CGSize(width: nouvelleLargeurSignature, height: hauteurParaphe)) else {
          print("Probleme pour retailler le paraphe")
          return nil}
        return selectedSignatureRetaille
        
        
    }

   
    @IBAction func bailleurLocataireSegmentedChange(_ sender: UISegmentedControl) {
        signatureView.clear()
        
        var config = jeSigneButton.configuration
        config?.title = (surSignature ? "Signature " : "Paraphe") + ( sender.selectedSegmentIndex == 0 ? " bailleur" : " locataire"  )
        jeSigneButton.configuration = config
        
    }
    
    @IBAction func jeSigneAction(_ sender: UIButton, forEvent event: UIEvent) {
        
        self.isNouvelleCapture = true
        
        switch bailleurLocataireSegmentControl.selectedSegmentIndex {
        case 0:
            signatureBailleurImageView.image = signatureView.snapshotImage()
            
            
            if surSignature {
                signatureBailleurPresente = true
                dateSignatureBailleurLabel.text = "Signature bailleur recueillie le \(dateFormatter.string(from: Date()) )"
            } else {
                parapheBailleurPresente = true
                dateSignatureBailleurLabel.text = "Paraphe bailleur recueilli le \(dateFormatter.string(from: Date()) )"
            }
            
        case 1:
            signatureLocataireImageView.image = signatureView.snapshotImage()
            if surSignature {
                signatureLocatairePresente = true
                dateSignatureLocataireLabel.text = "Signature locataire recueillie le \(dateFormatter.string(from: Date()) )"
            } else {
                parapheLocatairePresente = true
                dateSignatureLocataireLabel.text = "Paraphe locataire recueilli le \(dateFormatter.string(from: Date()) )"
            }
            
        default:
            print("")
        }
        signatureView.clear()
    }
    
    @IBAction func signatureButton(_ sender: UIBarButtonItem) {
        
        // Appel du meme ViewController pour recueillir les signature
        if sender.title == "Signature >" {
            
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let signatureViewController =
            storyboard.instantiateViewController(identifier: "SignatureViewController") { [self] coder in
                return SignatureViewController(coder: coder, actionBien: actionBien, indexPath: indexPath , surSignature: true)
            }
            
            signatureViewController.isNouvelleCapture = isNouvelleCapture
            signatureViewController.delegatePreview = self.delegatePreview
            
            navigationController?.pushViewController(signatureViewController, animated: true)
        }
        
        // Appel de la génération et visualisation du document 
        if sender.title == "Document >" {
            
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let previsualiserViewController =
            storyboard.instantiateViewController(identifier: "PrevisualiserViewController") { [self] coder in
                return PrevisualiserViewController(actionBien: actionBien, indexPath: indexPath, coder: coder)
            }
            previsualiserViewController.delegate = self.delegatePreview
            previsualiserViewController.isNouvelleCapture = isNouvelleCapture
            
            navigationController?.pushViewController(previsualiserViewController, animated: true)
            
        }
    }
   
}

