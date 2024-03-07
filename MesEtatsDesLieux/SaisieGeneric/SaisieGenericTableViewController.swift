//
//  SaisieGenericTableViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 05/02/2023.
//

import UIKit

protocol SaisieGenericTableViewControllerDelegate: AnyObject {
    // Mise à jour d'un EDL
    func saisieGenericTableViewController (_ saisieGenericTableViewController: SaisieGenericTableViewController, didModifyEDL  edl: EDL, for actionBien: ActionBien, indexPath: IndexPath )
    
    // Ajout un EDL
    func saisieGenericTableViewController (_ saisieGenericTableViewController: SaisieGenericTableViewController, willAddEDL  edl: EDL, for actionBien: ActionBien, from typeModele: TypeModele , nomModele: String, indexPath: IndexPath )
}
protocol SaisieGenericTableViewControllerDelegateMiseEnPage: AnyObject {
    // Pour la mise en page
    func saisieGenericTableViewControllerMiseEnPage (_ saisieGenericTableViewController: SaisieGenericTableViewController, didModifyEmetteur  emetteur: Emetteur, for itemMiseEnPage: ItemMiseEnPage, indexPath: IndexPath )
}

class SaisieGenericTableViewController: UITableViewController {

    
    @IBOutlet var indicationLabel: UILabel!
    @IBOutlet var adresseEmetteur: UITextView!
    @IBOutlet var villeEmetteurTextField:                   UITextField!
    @IBOutlet var codePostalEmetteurTextField:              UITextField!
    
    
    @IBOutlet var clauseEntreeTextView: UITextView!
    @IBOutlet var valideClauseEntree: UISwitch!
    
    @IBOutlet var clauseSortieTextView: UITextView!
    @IBOutlet var valideClauseSortie: UISwitch!
    
    @IBOutlet var signatureBailleurTextView: UITextView!
    @IBOutlet var signatureLocataireTextView: UITextView!
    @IBOutlet var piedPageTextView: UITextView!

    @IBOutlet var nomBienTextField:                     UITextField!
    @IBOutlet var typeBienTextField:                    UITextField!
    @IBOutlet var localisationBienTextField:            UITextField!
        
    @IBOutlet var adresseBienTextView:                  UITextView!
    @IBOutlet var villeBienTextField:                   UITextField!
    @IBOutlet var codePostalBienTextField:              UITextField!
        
    @IBOutlet var nomProprietaireTextField:             UITextField!
    @IBOutlet var nomMandataireTextField:               UITextField!
    @IBOutlet var adresseMandataire:                    UITextView!
    @IBOutlet var villeMandataireTextField:             UITextField!
    @IBOutlet var codePostalMandataireTextField:        UITextField!
        
    @IBOutlet var nomLocataireTextField:                UITextField!
    @IBOutlet var emailLocataireTextField:              UITextField!
        
    @IBOutlet var entreeSortieSegmentControl:           UISegmentedControl!
    @IBOutlet var refEDLTextField:                      UITextField!
    @IBOutlet var dateRealisationDatePicker:            UIDatePicker!
    @IBOutlet var nomExecutantEDLTextFieldTextField:    UITextField!
    
    @IBOutlet var nouveauNomBienTextField:              UITextField!
    
    @IBOutlet var typeModeleButton: ModeleButton!
    
    @IBOutlet var sortieNomBienTextField:               UITextField!
    
    @IBOutlet var nouvelEDLNomBienTextField:            UITextField!
    
 /*
  
    nomBien: String
    typeBien: String?
    localisationBien: String
    adresseBien: String
    villeBien: String
    codePostalBien: String
  
    nomProprietaire: String
    nomMandataire: String?
    adresseMandataire: String?
    villeMandataire: String?
    codePostalMandataire: String?
   
    nomLocataire: String
    emailLocataire: String
    
    typeEDL: TypeEDL
    refEDL: String?
    dateEDL: Date
    nomExecutantEDL: String

  
  */
    
    
    var itemMiseEnPage : ItemMiseEnPage?
    var actionBien: ActionBien?
    var indexPath: IndexPath!
    
    weak var delegate: SaisieGenericTableViewControllerDelegate?
    weak var delegateMiseEnPage: SaisieGenericTableViewControllerDelegateMiseEnPage?
    
    var modeModif = false
  
  func indicationSaisie () -> String {
      if let itemMiseEnPage = self.itemMiseEnPage
      { if itemMiseEnPage != .indefini {
          return itemMiseEnPage.indicationSaisie
      } else {
          if let actionBien = self.actionBien
          {
              return actionBien.typeAction.indicationSaisie
          }
      }
      }
      return ""
  }
  
    func hauteurCelulle (indexPath: IndexPath) -> CGFloat {
        return tabHauteurCelulle[indexPath]!
    }
 
  let tabHauteurCelulle: [ IndexPath : CGFloat] = [
    IndexPath(row: 0, section: 0) : 80 ,  // Indication
    IndexPath(row: 0, section: 1) : 90 ,  // Adresse
    IndexPath(row: 1, section: 1) : 90 ,  // Ville CodePostal
    IndexPath(row: 0, section: 2) : 500 , // Clause Contractuelle Entree
    IndexPath(row: 1, section: 2) : 100 , // Validation Clause Entree
    IndexPath(row: 0, section: 3) : 500 , // Clause Contractuelle Sortie
    IndexPath(row: 1, section: 3) : 100 , // Validation Clause Sortie
    IndexPath(row: 0, section: 4) : 70 ,  // Signature Locataire
    IndexPath(row: 1, section: 4) : 70 ,  // Signature Bailleur
    IndexPath(row: 0, section: 5) : 120,  // Pied de page
    IndexPath(row: 0, section: 6) : 80,  // DecrireBien
    IndexPath(row: 1, section: 6) : 80,  // DecrireBien
    IndexPath(row: 2, section: 6) : 80,  // DecrireBien
    IndexPath(row: 3, section: 6) : 80,  // DecrireBien
    IndexPath(row: 4, section: 6) : 80,  // DecrireBien
    IndexPath(row: 5, section: 6) : 80,  // DecrireBien
    IndexPath(row: 0, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 1, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 2, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 3, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 4, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 5, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 6, section: 7) : 80,  // IdentActeurs
    IndexPath(row: 0, section: 8) : 80,   // planifEDL
    IndexPath(row: 1, section: 8) : 80,   // planifEDL
    IndexPath(row: 2, section: 8) : 80,   // planifEDL
    IndexPath(row: 3, section: 8) : 80,   // planifEDL
    IndexPath(row: 0, section: 9) : 100,  // Ajout EDL
    IndexPath(row: 0, section: 10) : 100, // EDL de sortie
    IndexPath(row: 0, section: 11): 100  // EDL Nouveau sur le meme bien
   ]
    
 
    let tabHauteurSection: [ Int : CGFloat] = [
      0 : 0 ,  // Indication
      1 : 40 ,  // Adresse
      2 : 40 ,  // Clause Contractuelle Entree
      3 : 40 ,  // Clause Contractuelle Sortie
      4 : 40,   // Signature Locataire
      5 : 40,   // Pied de page
      6 : 40,   // DecrireBien
      7 : 40,   // IdentActeurs
      8 : 40,   // planifEDL
      9 : 40,   // Ajout EDL
      10: 40,   // EDL de sortie
      11: 40,   // Nouvel EDL
     ]
    
  let tabMasquageMiseEnPage: [ IndexPath : ItemMiseEnPage] = [
    IndexPath(row: 0, section: 0) : .indefini , // Indication
    IndexPath(row: 0, section: 1) : .adresse , // Adresse
    IndexPath(row: 1, section: 1) : .adresse , // Ville CodePostal
    IndexPath(row: 0, section: 2) : .clauseContractuelleEntree,  // Clause Contractuelle Entree
    IndexPath(row: 1, section: 2) : .clauseContractuelleEntree ,  // Valisation Clause Entree
    IndexPath(row: 0, section: 3) : .clauseContractuelleSortie ,  // Clause Contractuelle Sortie
    IndexPath(row: 1, section: 3) : .clauseContractuelleSortie ,  // Valisation Clause Sortie
    IndexPath(row: 0, section: 4) : .signatures ,  // Signature Locataire
    IndexPath(row: 1, section: 4) : .signatures ,
    IndexPath(row: 0, section: 5) : .piedPage ]
    
let tabMasquageTypeAction : [ IndexPath : TypeAction] = [
    
    IndexPath(row: 0, section: 6) : .decrireBien,
    IndexPath(row: 1, section: 6) : .decrireBien,
    IndexPath(row: 2, section: 6) : .decrireBien,
    IndexPath(row: 3, section: 6) : .decrireBien,
    IndexPath(row: 4, section: 6) : .decrireBien,
    IndexPath(row: 5, section: 6) : .decrireBien,
    
    IndexPath(row: 0, section: 7) : .identActeurs,
    IndexPath(row: 1, section: 7) : .identActeurs,
    IndexPath(row: 2, section: 7) : .identActeurs,
    IndexPath(row: 3, section: 7) : .identActeurs,
    IndexPath(row: 4, section: 7) : .identActeurs,
    IndexPath(row: 5, section: 7) : .identActeurs,
    IndexPath(row: 6, section: 7) : .identActeurs,
    
    IndexPath(row: 0, section: 8) : .planifEDL,
    IndexPath(row: 1, section: 8) : .planifEDL,
    IndexPath(row: 2, section: 8) : .planifEDL,
    IndexPath(row: 3, section: 8) : .planifEDL,
    
    IndexPath(row: 0, section: 9) : .ajoutEDL,
    IndexPath(row: 0, section: 10) : .ajoutSortieEDLEntree,
    IndexPath(row: 0, section: 11) : .repriseNouvelEDL
    
  
  ]
  
  
 
// Init pour les actions de saisies
    init?(coder: NSCoder, actionBien: ActionBien, indexPath: IndexPath) {
        self.actionBien = actionBien
        self.itemMiseEnPage = .indefini
        self.indexPath = indexPath
        super.init(coder: coder)
    }
// Init pour la mise en page
    init?(coder: NSCoder, itemMiseEnPage: ItemMiseEnPage, actionBien: ActionBien, indexPath: IndexPath) {
        self.actionBien = actionBien
        self.itemMiseEnPage = itemMiseEnPage
        self.indexPath = indexPath
        super.init(coder: coder)
    }
    
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicationLabel.text = indicationSaisie()
        displaySaisieItem()
     
    }
    
    func displaySaisieItem () {
        
        if let actionBien = self.actionBien,
           let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien){
            // on est sur la saisie d'actions
            if self.itemMiseEnPage == .indefini {
                // on est sur la saisie d'actions
                switch self.actionBien?.typeAction {
                case .decrireBien:
                    nomBienTextField.text = edl.nomBien
                    typeBienTextField.text = edl.typeBien
                    localisationBienTextField.text = edl.localisationBien
                    adresseBienTextView.text = edl.adresseBien
                    villeBienTextField.text = edl.villeBien
                    codePostalBienTextField.text = edl.codePostalBien
                case .identActeurs:
                    nomProprietaireTextField.text = edl.nomProprietaire
                    nomMandataireTextField.text = edl.nomMandataire
                    adresseMandataire.text = edl.adresseMandataire
                    villeMandataireTextField.text = edl.villeMandataire
                    codePostalMandataireTextField.text = edl.codePostalMandataire
                    nomLocataireTextField.text = edl.nomLocataire
                    emailLocataireTextField.text = edl.emailLocataire
                case .planifEDL:
                    if edl.typeEDL == .entree {
                        entreeSortieSegmentControl.selectedSegmentIndex = 0 }
                    else {
                        entreeSortieSegmentControl.selectedSegmentIndex = 1
                    }
                    refEDLTextField.text = edl.refEDL
                    dateRealisationDatePicker.date = edl.dateEDL
                    nomExecutantEDLTextFieldTextField.text = edl.nomExecutantEDL
                    
                    
                case .ajoutSortieEDLEntree:
                    sortieNomBienTextField.text = edl.nomBien + " - Sortie"
                    print ("")
                    
                case .repriseNouvelEDL:
                    nouvelEDLNomBienTextField.text = edl.nomBien + " - Nouveau"
                default:
                    print("Non applicable")
                }
                return
            } else {
                // On est sur la saisie de la mise en page
                if let emetteurId = edl.idEmetteur,
                   let emetteur = EmetteurController.emetteurByUUID(uuidEmetteur: emetteurId)
                {
                    switch self.itemMiseEnPage {
                    case .adresse:
                        adresseEmetteur.text = emetteur.adresseEmetteur
                        codePostalEmetteurTextField.text = emetteur.codePostalEmetteur
                        villeEmetteurTextField.text = emetteur.villeEmetteur
                    case .clauseContractuelleEntree:
                        clauseEntreeTextView.text = emetteur.clauseContractuelleEntree
                        valideClauseEntree.isOn = emetteur.validationClauseContractuelleEntree
                    case .clauseContractuelleSortie:
                        clauseSortieTextView.text = emetteur.clauseContractuelleSortie
                        valideClauseSortie.isOn = emetteur.validationClauseContractuelleSortie
                    case .signatures:
                        signatureBailleurTextView.text = emetteur.libelleSignatureBailleur
                        signatureLocataireTextView.text = emetteur.libelleSignatureLocataire
                    
                    case .piedPage:
                        piedPageTextView.text = emetteur.blocPiedPage
                    default:
                        print("")
                    }
                }
                
            }
        } else {
            // On est sur un nouveau EDL via ajout EDL
            // Le message d'invitation pourra être recréé ou si c'est le premier EDL, aide à l'utilisation...
            typeModeleButton.showsMenuAsPrimaryAction = true
            typeModeleButton.typeModele = .vide
            typeModeleButton.updateModeleButton()
            
        }
    }

    
    @IBAction func annuleSaisieItem(_ sender: UIBarButtonItem) {
        print ("Annule")
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveSaisieItem(_ sender: UIBarButtonItem) {
        guard let actionBien = self.actionBien else { return }
        
        if let itemMiseEnPage = self.itemMiseEnPage,
           var edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien){
            // on est sur la saisie d'actions
            if itemMiseEnPage == .indefini {
                switch actionBien.typeAction {
                case .decrireBien:
                    edl.nomBien = nomBienTextField.text ?? ""
                    edl.typeBien = typeBienTextField.text
                    edl.localisationBien = localisationBienTextField.text ?? ""
                    edl.adresseBien =   adresseBienTextView.text
                    edl.villeBien =    villeBienTextField.text ?? ""
                    edl.codePostalBien = codePostalBienTextField.text ?? ""
                    delegate?.saisieGenericTableViewController(self, didModifyEDL: edl, for: actionBien, indexPath: indexPath)
                case .identActeurs:
                    edl.nomProprietaire =   nomProprietaireTextField.text ?? ""
                    edl.nomMandataire =    nomMandataireTextField.text
                    edl.adresseMandataire =  adresseMandataire.text
                    edl.villeMandataire =   villeMandataireTextField.text
                    edl.codePostalMandataire =  codePostalMandataireTextField.text
                    edl.nomLocataire =   nomLocataireTextField.text ?? ""
                    edl.emailLocataire =   emailLocataireTextField.text ?? ""
                    delegate?.saisieGenericTableViewController(self, didModifyEDL: edl, for: actionBien, indexPath: indexPath)
                case .planifEDL:
                    edl.validationPlanifEDL = true
                    edl.typeEDL =  entreeSortieSegmentControl.selectedSegmentIndex == 0 ? .entree : .sortie
                    edl.refEDL = refEDLTextField.text
                    edl.dateEDL = dateRealisationDatePicker.date
                    edl.nomExecutantEDL =   nomExecutantEDLTextFieldTextField.text ?? ""
                    delegate?.saisieGenericTableViewController(self, didModifyEDL: edl, for: actionBien, indexPath: indexPath)
                    
                case .ajoutSortieEDLEntree , .repriseNouvelEDL :
                    
                    var nouveauNom: String
                    if actionBien.typeAction == .ajoutSortieEDLEntree,
                    let nom = sortieNomBienTextField.text {
                        nouveauNom = nom
                    } else if actionBien.typeAction == .repriseNouvelEDL,
                              let nom = nouvelEDLNomBienTextField.text {
                        nouveauNom = nom
                    } else {
                        return
                    }
                    
                    if nouveauNom.count > 5 {
                        
                        // On créé un EDL de toute pièce
                        var nouvelEDL = EDL(idEDL: UUID())
                        nouvelEDL.nomBien = nouveauNom
                        
                        // On rattache l'EDL en court comme EDL de sortie
                        nouvelEDL.idEDLEntree = actionBien.idBien
                        
                        if actionBien.typeAction == .ajoutSortieEDLEntree  {
                            nouvelEDL.typeEDL = .sortie
                            self.delegate?.saisieGenericTableViewController(self, willAddEDL: nouvelEDL, for: actionBien, from: .sortieApresEntree , nomModele: "", indexPath: self.indexPath)
                        }
                        
                        if actionBien.typeAction == .repriseNouvelEDL  {
                            self.delegate?.saisieGenericTableViewController(self, willAddEDL: nouvelEDL, for: actionBien, from: .reprise , nomModele: "", indexPath: self.indexPath)
                        }
                    }
                    else {
                        let alertController = UIAlertController(title: "Attention !", message: "Le nom du bien doit comporter au moins 5   caractères: corrigez ou tapez sur Annuler", preferredStyle: UIAlertController.Style.alert)
                        let actionNothing = UIAlertAction(title: "J'ai compris", style: UIAlertAction.Style.default) { (action) in }
                        alertController.addAction(actionNothing)
                        
                        present(alertController, animated: true, completion: nil)
                        return
                    }
               default:
                    print("Non Applicable")
                }
                
            } else {
                // Mise en page
                if let emetteurId = edl.idEmetteur,
                   var emetteur = EmetteurController.emetteurByUUID(uuidEmetteur: emetteurId)
                {
                    switch itemMiseEnPage {
                    case .adresse:
                        emetteur.adresseEmetteur = adresseEmetteur.text
                        emetteur.villeEmetteur = villeEmetteurTextField.text
                        emetteur.codePostalEmetteur = codePostalEmetteurTextField.text
                    case .clauseContractuelleEntree:
                        emetteur.clauseContractuelleEntree = clauseEntreeTextView.text
                        emetteur.validationClauseContractuelleEntree = valideClauseEntree.isOn
                    case .clauseContractuelleSortie:
                        emetteur.clauseContractuelleSortie = clauseSortieTextView.text
                        emetteur.validationClauseContractuelleSortie = valideClauseSortie.isOn
                    case .signatures:
                        emetteur.libelleSignatureBailleur = signatureBailleurTextView.text
                        emetteur.libelleSignatureLocataire = signatureLocataireTextView.text
                    case .piedPage:
                        emetteur.blocPiedPage = piedPageTextView.text
                    default:
                        print("Non Applicable")
                    }
                    delegateMiseEnPage?.saisieGenericTableViewControllerMiseEnPage(self, didModifyEmetteur: emetteur, for: itemMiseEnPage, indexPath: indexPath)
                }
            }
        } else {
            // edl inexistant -> Nouvel EDL
            if actionBien.typeAction == .ajoutEDL {
                if let nouveauNom = nouveauNomBienTextField.text,
                   nouveauNom.count > 5,
                   let actionBien = self.actionBien {
                    
                    // On ajoute l'EDL avec l'UUID généré initialement et le nom saisie
                    var nouvelEDL = EDL(idEDL: actionBien.idBien)
                    nouvelEDL.nomBien = nouveauNom
                    
                    self.delegate?.saisieGenericTableViewController(self, willAddEDL: nouvelEDL, for: actionBien, from: typeModeleButton.typeModele, nomModele: typeModeleButton.nomModeleType, indexPath: self.indexPath)
                }
                else {
                    let alertController = UIAlertController(title: "Attention !", message: "Le nom du bien doit comporter au moins 5   caractères: corrigez ou tapez sur Annuler", preferredStyle: UIAlertController.Style.alert)
                    let actionNothing = UIAlertAction(title: "J'ai compris", style: UIAlertAction.Style.default) { (action) in }
                    alertController.addAction(actionNothing)
                    
                    present(alertController, animated: true, completion: nil)
                    return
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
        
    }
  
    @IBAction func typeModeleTrigerred(_ sender: ModeleButton) {
        DispatchQueue.main.async {
            
            
            self.typeModeleButton.updateModeleButton()
        }
    }
    
    // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
      if let itemMiseEnPage = self.itemMiseEnPage {
          if tabMasquageMiseEnPage[indexPath] == itemMiseEnPage || tabMasquageMiseEnPage[indexPath] == .indefini  {
              return tabHauteurCelulle [indexPath]!
          } else {
              // On n'est pas dans une saisie de mise en page donc on regarde actionBien
              if let actionBien = self.actionBien {
                  if actionBien.typeAction == tabMasquageTypeAction[indexPath] {
                      return tabHauteurCelulle [indexPath]!
                  } else { return 0 }
              }
          }
      }
      return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
      if let itemMiseEnPage = self.itemMiseEnPage {
          if  tabMasquageMiseEnPage[IndexPath(row: 0, section: section)] == itemMiseEnPage
                || tabMasquageMiseEnPage[IndexPath(row: 0, section: section)] == .indefini
                || tabMasquageMiseEnPage [IndexPath(row: 1, section: section), default: .logo] == .indefini {
              print("-- Section", section, ":", tabHauteurSection[section]!)
              return tabHauteurSection[section]!
          } else {
              // On n'est pas dans une saisie de mise en page donc on regarde actionBien
              if let actionBien = self.actionBien {
                  if actionBien.typeAction == tabMasquageTypeAction[IndexPath(row: 0, section: section)] {
                      print("-- Section",section, ":", tabHauteurSection[section]!)
                      return tabHauteurSection[section]!
                  } else { return 0 }
            }
          }
      }
      print("-- Section", section, ":",0," ????")
     return 0
  }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if let itemMiseEnPage = self.itemMiseEnPage {
            if  tabMasquageMiseEnPage[IndexPath(row: 0, section: section)] == itemMiseEnPage
                  || tabMasquageMiseEnPage[IndexPath(row: 0, section: section)] == .indefini {
                print("-- Section Footer", section, ":", tabHauteurSection[section]!)
                return tabHauteurSection[section]!
            } else {
                // On n'est pas dans une saisie de mise en page donc on regarde actionBien
                if let actionBien = self.actionBien {
                    if actionBien.typeAction == tabMasquageTypeAction[IndexPath(row: 0, section: section)] {
                        print("-- Section Footer",section, ":", tabHauteurSection[section]!)
                        return tabHauteurSection[section]!
                    } else { return 0 }
              }
            }
        }
        print("-- Section Footer", section, ":",0," ????")
       return 0
    }
    

    
    
   /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tabHauteurSection[section, default: 0]))
        headerView.backgroundColor = .red.withAlphaComponent(0.5)
        let labelTitre = UILabel(frame: headerView.frame)
        labelTitre.text = "toto"
        headerView.addSubview(labelTitre)
            return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tabHauteurSection[section, default: 0]))
        footerView.backgroundColor = .green.withAlphaComponent(0.5)
            return footerView
    }
    
   */
    
}

