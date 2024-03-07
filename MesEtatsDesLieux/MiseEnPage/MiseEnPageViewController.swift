//
//  MiseEnPageViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 10/02/2023.
//

import UIKit



protocol MiseEnPageViewControllerDelegate : AnyObject {
    func miseEnPageViewController (_ miseEnPageViewController: MiseEnPageViewController, for actionBien: ActionBien, indexPath: IndexPath )
}


class MiseEnPageViewController: UIViewController, UIImagePickerControllerDelegate &  UINavigationControllerDelegate {
    
    
    
    var actionBien: ActionBien?
    var indexPath: IndexPath!
    var delegate: MiseEnPageViewControllerDelegate?
    
    
    
    private lazy var miseEnPageView: MiseEnPageView = {
        let view = MesEtatsDesLieux.MiseEnPageView()
          view.translatesAutoresizingMaskIntoConstraints = false
          view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
          view.layer.cornerCurve = .continuous
          view.layer.cornerRadius = 10
          return view
        }()
  
    @IBOutlet var scrollView: UIScrollView!
   
    // Init pour les actions de saisies
       init?(coder: NSCoder, actionBien: ActionBien, indexPath: IndexPath) {
           self.actionBien = actionBien
           self.indexPath = indexPath
           super.init(coder: coder)
       }
     
     required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createLayout()
        
        displayMiseEnPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
  
        
        // On appelle la deleguée de Mise en Page que si on est sur l'evenement de will disaeppear vers BienViewsController (ie on ne vas pas vers SaisieTable)
        var versBienViewController: Bool = true
        if let stack = self.navigationController?.viewControllers {
              for vc in stack where vc.isKind(of: SaisieGenericTableViewController.self) {
                versBienViewController = false
              }
            }
        if let actionBien = self.actionBien,
            versBienViewController {
            self.delegate?.miseEnPageViewController(self, for: actionBien,  indexPath: self.indexPath)
        }
   
   
    }
  
    
    
    fileprivate func createLayout() {
        title = "Mise en page"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
        
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubview(miseEnPageView)
        
        miseEnPageView.translatesAutoresizingMaskIntoConstraints = false
        // Est fait pour centrer la vue
        //   miseEnPageView.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor).isActive = true
        //   miseEnPageView.centerYAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerYAnchor).isActive = true
        
        // let contentInsets = UIEdgeInsets(top: 30.0, left: 30.0,
        //                                  bottom: 30.0, right: 30.0)
        //  scrollView.contentInset = contentInsets
        //  scrollView.scrollIndicatorInsets = contentInsets
        
        
        
        miseEnPageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        miseEnPageView.widthAnchor.constraint(equalToConstant:  scrollView.contentSize.height).isActive = true
        
        miseEnPageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 0).isActive = true
        miseEnPageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: 0).isActive = true
        miseEnPageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0).isActive = true
        miseEnPageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        miseEnPageView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor).isActive = true
        
        miseEnPageView.delegate = self
    }
    
    func displayMiseEnPage () {
        if let actionBien = self.actionBien,
           var edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) {
            if let idEmetteur = edl.idEmetteur {
                displayMiseEnPageEmetteur(idEmetteur: idEmetteur)
                miseEnPageView.idEmetteur = idEmetteur
            } else {
                // On cree un emetteur avec valeur par défaut
                displayMiseEnPageVierge()
                let nouvelEmetteur = EmetteurController.nouvEmetteur()
                _ = EmetteurController.majEmetteur(emetteur: nouvelEmetteur)
                edl.idEmetteur = nouvelEmetteur.idEmetteur
                _ = EDLsController.majEDL(edl: edl)
                miseEnPageView.idEmetteur = nouvelEmetteur.idEmetteur
            }
        }
    }
    
    func displayMiseEnPageEmetteur ( idEmetteur: UUID ) {
        
        if let emetteur = EmetteurController.emetteurByUUID(uuidEmetteur: idEmetteur){
            // On un emetteur
            // 0- Invite
            miseEnPageView.statutLabel.text = messageInviteModificationEmetteur
            
            // 1- Logo
            
            if emetteur.logoPresent {
                miseEnPageView.logoLabel.itemStyleComplet()
                let logoImage = EmetteurController.chargeLogoEmetteur(idEmetteur: emetteur.idEmetteur)
                miseEnPageView.logoImageView.image = logoImage
            } else {
                miseEnPageView.logoLabel.text = ItemMiseEnPage.logo.messageInvite
            }
            
            // 2- Adresse
            if let adresse = emetteur.adresseEmetteur,
               let codePostal = emetteur.codePostalEmetteur,
               let ville = emetteur.villeEmetteur {
                if adresse != "" && ville != "" && codePostal != "" {
                    miseEnPageView.adresseLabel.itemStyleComplet(valeur: (adresse + "\n" + codePostal + " " + ville))
                } else {
                    if  adresse != "" || ville != "" || codePostal != "" {
                        miseEnPageView.adresseLabel.itemStyleIncomplet(valeur: adresseACompleter)
                    } else
                    { print ("----", ItemMiseEnPage.adresse.messageInvite)
                        miseEnPageView.adresseLabel.itemModifiableLabel(valeur: ItemMiseEnPage.adresse.messageInvite)
                    }
                }
            } else {
                miseEnPageView.adresseLabel.text = ItemMiseEnPage.adresse.messageInvite
            }
            
            // 3- clause Contractuelle Entrée
            if emetteur.clauseContractuelleEntree != "" && emetteur.validationClauseContractuelleEntree {
                miseEnPageView.clauseContractuelEntreeLabel.itemStyleComplet(valeur: emetteur.clauseContractuelleEntree)
            } else { miseEnPageView.clauseContractuelEntreeLabel.itemModifiableLabel(valeur: ItemMiseEnPage.clauseContractuelleEntree.messageInvite)}
            
            // 3bis- clause Contractuelle Sortie
            if emetteur.clauseContractuelleSortie != "" && emetteur.validationClauseContractuelleSortie {
                miseEnPageView.clauseContractuelSortieLabel.itemStyleComplet(valeur: emetteur.clauseContractuelleSortie)
            } else { miseEnPageView.clauseContractuelSortieLabel.itemModifiableLabel(valeur: ItemMiseEnPage.clauseContractuelleSortie.messageInvite)}
            
            // 4- Signatures Bailleur
            if emetteur.libelleSignatureBailleur != "" && emetteur.validationSignature {
                miseEnPageView.signatureBailleurLabel.itemStyleComplet(valeur: emetteur.libelleSignatureBailleur)}
            else {
                miseEnPageView.signatureBailleurLabel.itemModifiableLabel(valeur: ItemMiseEnPage.signatures.messageInvite + "pour le BAILLEUR")
            }
            // 5- Signature locataire
            if emetteur.libelleSignatureLocataire != "" && emetteur.validationSignature {
                miseEnPageView.signatureLocataireLabel.itemStyleComplet(valeur: emetteur.libelleSignatureLocataire)}
            else {
                miseEnPageView.signatureLocataireLabel.itemModifiableLabel(valeur: ItemMiseEnPage.signatures.messageInvite + "pour le LOCATAIRE")
            }
            // 6- Pied de page
            if emetteur.blocPiedPage != "" && emetteur.validationBlocPiedPage {
                miseEnPageView.piedPageLabel.itemStyleComplet(valeur: emetteur.blocPiedPage)
            } else {
                miseEnPageView.piedPageLabel.itemModifiableLabel(valeur: ItemMiseEnPage.piedPage.messageInvite)
            }
            
            // 7- Label corp du constat
            miseEnPageView.corpsConstatLabel.text = messageInviteCorpsConstat
            
        }
    }
    
    func displayMiseEnPageVierge ()  {
        
        // 0- Invite
        miseEnPageView.statutLabel.text = messageInviteNouvelEmetteur
        // 1- Logo
        miseEnPageView.logoLabel.itemModifiableLabel(valeur: ItemMiseEnPage.logo.messageInvite)
        // 2- Adresse
        miseEnPageView.adresseLabel.text = ItemMiseEnPage.adresse.messageInvite
        // 3- Corps etat des lieux
        miseEnPageView.corpsConstatLabel.text = messageInviteCorpsConstat
        miseEnPageView.clauseContractuelEntreeLabel.text = ItemMiseEnPage.clauseContractuelleEntree.messageInvite
        miseEnPageView.clauseContractuelSortieLabel.text = ItemMiseEnPage.clauseContractuelleSortie.messageInvite
        miseEnPageView.signatureBailleurLabel.text = ItemMiseEnPage.signatures.messageInvite + " pour le BAILLEUR"
        miseEnPageView.signatureLocataireLabel.text = ItemMiseEnPage.signatures.messageInvite + " pour le LOCATAIRE"
        miseEnPageView.piedPageLabel.text = ItemMiseEnPage.piedPage.messageInvite
        
        
        
    }
    
    
  
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] ){
      
      guard let selectedLogo = info[.originalImage] as? UIImage else {
        print ("Pas d'image")
        return
      }
      
      
      let echelleLogo = selectedLogo.size.width / selectedLogo.size.height
      let nouvelleLargeurLogo = echelleLogo * hauteurLogo
      
      guard let selectedLogoRetaille = selectedLogo.resizeImageTo(size: CGSize(width: nouvelleLargeurLogo, height: hauteurLogo)) else {
        print("Probleme pour retailler le logo")
        return}
      
      miseEnPageView.logoImageView.image = selectedLogoRetaille
      miseEnPageView.logoLabel.backgroundColor = .systemGreen.withAlphaComponent(0.3)
      miseEnPageView.logoLabel.text = ""
      
        if let actionBien = self.actionBien,
           let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien),
           let idEmetteur = edl.idEmetteur,
           var emetteur = EmetteurController.emetteurByUUID(uuidEmetteur: idEmetteur) {
            emetteur.logoPresent = true
            _ = EmetteurController.majEmetteur(emetteur: emetteur)
            EmetteurController.sauveLogoEmetteur(idEmetteur: idEmetteur, logoEmetteur: selectedLogoRetaille)
        }
        
        
        
        
      dismiss(animated: true , completion: nil)
      
      
    }
  
}

extension MiseEnPageViewController: MiseEnPageViewDelegate {
    func miseEnPageView(_ miseEnPageView: MiseEnPageView, itemMiseEnPage: ItemMiseEnPage) {
        switch itemMiseEnPage {
        
        case .adresse, .clauseContractuelleEntree, .clauseContractuelleSortie, .signatures, .piedPage:
            let storyboard = UIStoryboard(name: "SaisieGeneric", bundle: .main)
            let saisieGenericTableViewController =
            storyboard.instantiateViewController(identifier: "SaisieGenericTableViewController") { coder in
                return MesEtatsDesLieux.SaisieGenericTableViewController(coder: coder, itemMiseEnPage: itemMiseEnPage, actionBien: self.actionBien!, indexPath: self.indexPath)
            }
            print("---- > Appel : ", itemMiseEnPage, "Self =", self)
            
            // Positionnement de la déléguée
            saisieGenericTableViewController.delegateMiseEnPage = self
            self.navigationController?.pushViewController(saisieGenericTableViewController, animated: true)
            
        case .logo:
          majLogo()
        default:
            return
        }
    }
    

  
  func majLogo () {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .photoLibrary
    self.present(imagePicker, animated: true, completion: nil)
  }
  

  
}


extension MiseEnPageViewController:  SaisieGenericTableViewControllerDelegateMiseEnPage {
    
    
    func saisieGenericTableViewControllerMiseEnPage(_ saisieGenericTableViewController: SaisieGenericTableViewController, didModifyEmetteur emetteur: Emetteur, for itemMiseEnPage: ItemMiseEnPage, indexPath: IndexPath) {
        
        
        // Si on revient d'une saisie de clauseContractuelle de signature ou de pied de paga qui ont des valeurs par défaut
        // On considère que les valeurs sont validés et donc que les items sont complets
        // pour cela on met à jour les booléens associés
        var newEmetteur = emetteur
        switch itemMiseEnPage {
        case .clauseContractuelleEntree:
            if !newEmetteur.validationClauseContractuelleEntree {
                newEmetteur.validationClauseContractuelleEntree = true
            }
        case .clauseContractuelleSortie:
            if !newEmetteur.validationClauseContractuelleSortie {
                newEmetteur.validationClauseContractuelleSortie = true
            }
        case .signatures:
            if !newEmetteur.validationSignature {
                newEmetteur.validationSignature = true
            }
        case .piedPage:
            if !newEmetteur.validationBlocPiedPage {
                newEmetteur.validationBlocPiedPage = true
            }
        default:
            print("")

        }
        // Sauvegarde emetteur
        _ = EmetteurController.majEmetteur(emetteur: newEmetteur)
        displayMiseEnPageEmetteur(idEmetteur: newEmetteur.idEmetteur)

        
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        print("unwindMiseEnPage")
    }
}
