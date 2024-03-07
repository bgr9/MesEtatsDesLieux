//
//  previsualiserViewController.swift
//  MesEtatsDesLieux
//
//  Created by BD2B on 15/01/2023.
//

import UIKit
import WebKit
import MessageUI


protocol PrevisualiserViewControllerDelegate: AnyObject {
    // Pour la mise en page
    func previsualiserViewController (_ previsualiserViewController: PrevisualiserViewController, didPublishDoc  edl: EDL, for actionBien: ActionBien, indexPath: IndexPath )
}

/// Visualisation du document d'abord en HTML puis en fichier PDF
///
/// Cas d'appel
/// * **.actionBien == nil**  Prévisualiser l'état des lieux directement depuis la réalisation de l'état des lieux, pas de génération du PDF
/// * **.actionBien.typeAction == .genererDocSigne** Apres le recueil de paraphe, de signature,
///     * Si statut == .aFaire, on visualise le HTML et génére le PDF
///     * sinon :
///         * Si il y a eu nouvelle capture, on visualise le rendu HTML et générer le PDF **isNouvelleCapture == true** positionné avant l'appel par SIgnatureViewController
///         * Si pas de nouvelle capture, on visualise le PDF **isNouvelleCapture == false** positionné avant l'appel par SIgnatureViewController
/// * **.actionBien.typeAction == .genererDocVierge** Action de génération d'un document pour signature manuelle
///     * Si statut == .aFaire, on visualise le HTML et génére le PDF
///     * sinon, on affiche le PDF uniquement
/// * **.actionBien.typeAction == .visuDocDefinitifSigne** Action de visualisation du document signé PDF
/// * **.actionBien.typeAction == .visuDocDefinitifVierge** Action de visualisation du document signé PDF
///
///Au final on doit faire :
///* Cas1: Visualiser HTML sans signature et ne rien faire d'autre
///* Cas2: Visualiser HTML avec signature, générer PDF associe, visualiser et partager
///* Cas3: Visualiser HTML sans signature et générer PDF associe et visualiser et partager
///* Cas4: Visualiser PDF sans signature et partager
///* Cas5: Visualiser PDF avec signature et partager
///
class PrevisualiserViewController: UIViewController, UINavigationControllerDelegate, WKNavigationDelegate {
    
    
    enum CasVisualisation {
    case HTMLSansSignature  // Visualiser HTML sans signature et ne rien faire d'autre
    case HTMLAvecSignatureGenererPDFVisuPartage  // Visualiser HTML avec signature, générer PDF associe, visualiser et partager
    case HTMLSansSignatureGenererPDFVisuPartage  // Visualiser HTML sans signature et générer PDF associe et visualiser et partager
    case PDFSansSignatureVisuPartage  // Visualiser PDF sans signature et partager
    case PDFAvecSignatureVisuPartage  // Visualiser PDF avec signature et partager
    }
    
    var casAppel: CasVisualisation!
        
    @IBOutlet var webViewEDL: WKWebView!
    
    var edlComposer: EDLComposer!
    var edl: EDL!
    var actionBien: ActionBien?
    var indexPath: IndexPath!
    
    var delegate: PrevisualiserViewControllerDelegate?
    
    var isNouvelleCapture: Bool? // nouvelle capture de signature
    
    var genereEtDisplayPDF: (() -> Void) = {}
    var mustExecuteGenereEtDisplayPDF: Bool = false
    
    var urlPDFToMail: URL!
    
    var envoiMail = false {
        didSet {
            if self.envoiMail {
                if urlPDFToMail != nil {
                    self.sendEmail(urlPDF: urlPDFToMail)
                }
                self.envoiMail = false
            }
        }
        
    }
    
    @IBOutlet var rightBarButton: UIBarButtonItem!
    
 // Init n°1 : Appelé par la réalisation de l'état des lieux
    init? (edl: EDL, coder: NSCoder ) {
        super.init(coder: coder)
        self.edl = edl
        self.actionBien = nil
        self.indexPath = nil
        
        
    }
    
// Init n°2: Appelé par les quatres actionsBiens
    init? (actionBien: ActionBien, indexPath: IndexPath, coder: NSCoder ) {
        super.init(coder: coder)
        self.actionBien = actionBien
        self.indexPath = indexPath
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) pas d'init avec EDL")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewEDL.navigationDelegate = self
        if actionBien == nil {
            casAppel = .HTMLSansSignature
        } else if let actionBien = actionBien {
            // On charge edl qui n'est pas passé en paramètre de l'init n°2
            if let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) {
                self.edl = edl
            }
            
            switch actionBien.typeAction {
            case .genererDocSigne:
                if actionBien.statutAction == .aFaire {
                    casAppel = .HTMLAvecSignatureGenererPDFVisuPartage
                } else {
                    if let isNouvelleCapture = isNouvelleCapture,
                       isNouvelleCapture {
                        casAppel = .HTMLAvecSignatureGenererPDFVisuPartage
                    } else {
                        casAppel = .PDFAvecSignatureVisuPartage
                    }
                }
            case .genererDocVierge:
                if actionBien.statutAction == .aFaire {
                    casAppel = .HTMLSansSignatureGenererPDFVisuPartage
                } else {
                    casAppel = .PDFSansSignatureVisuPartage
                }
            case .visuDocDefinitifVierge:
                casAppel = .PDFSansSignatureVisuPartage
            case .visuDocDefinitifSigne:
                casAppel = .PDFAvecSignatureVisuPartage
            default:
                print("Cas non prévu")
            }
        }
        
        // 1 : Rechargement de l'EDL selectionné pour que les appels aux controlleurs se fassent sur les bonnes données
        if [ .HTMLSansSignature, .HTMLSansSignatureGenererPDFVisuPartage, .HTMLAvecSignatureGenererPDFVisuPartage ].contains(casAppel) {
            _ = EDLsController.selectEDLbyUUID(id: edl.idEDL)
            CategorieController.reChargeCategorie()
            CompteurController.reChargeCompteur()
            EntretienController.reChargeEntretien()
            ClefController.reChargeClef()
            EquipementController.reChargeEquipement()
            FournitureController.reChargeFourniture()
            EmetteurController.reChargeEmetteur()
            
            // Appel de l'EDLComposer avec  le parametre de selection des signature ou pas
            if casAppel == .HTMLAvecSignatureGenererPDFVisuPartage {
                edlComposer = EDLComposer(edl: self.edl, isAvecSignature: true)
            } else if casAppel == .HTMLSansSignatureGenererPDFVisuPartage{
                edlComposer = EDLComposer(edl: self.edl, isAvecSignature: false)
            } else {
                edlComposer = EDLComposer(edl: self.edl, isAvecSignature: false)
            }
            
            
        }
        // Positionnement du libellé du bouton haut droit
        if casAppel == .HTMLSansSignature {
            rightBarButton.title = ""
            rightBarButton.isEnabled = false
        } else {
            rightBarButton.title = "Diffuser >"
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch casAppel {
        case .HTMLSansSignature:
            displayEDLAsHTML(isDocSigne: false)
            
        case .HTMLSansSignatureGenererPDFVisuPartage:
            // Masquage de la webview le temps de générer le HTML
            webViewEDL.isHidden = true
            
            // Mise à jour des actions de génération de PDF après que le HTML est rendu dans la WebView
            mustExecuteGenereEtDisplayPDF = true
            genereEtDisplayPDF = { [self] in
                if let idEDL = actionBien?.idBien,
                   var newEDL = EDLsController.edlFromUUID(idEDL: idEDL) {
                    
                    let nomFichierSansSignature = EDLsController.nomFichierEDLPDFSansSignature(idEDL: newEDL.idEDL)
                    let urlPDF = documentsDirectory.appendingPathComponent(nomFichierSansSignature).appendingPathExtension("pdf")
                    genererEDLAsPDF(urlPDF: urlPDF)
                    newEDL.dernierFichierViergeNomFichier = nomFichierSansSignature
                    newEDL.dateDernierFichierVierge = Date()
                    _ = EDLsController.majEDL(edl: newEDL, false)
                    displayEDLAsPDF(urlPDF: urlPDF)
                }
                
            }
            
            displayEDLAsHTML(isDocSigne: false)
            
        case .HTMLAvecSignatureGenererPDFVisuPartage:
           // Suppression des deux VC SignatureViewController pour revenir à BiensViewController
            if let stack = self.navigationController?.viewControllers {
                self.navigationController?.viewControllers = stack.filter { element in
                guard element is SignatureViewController else { return true}
                return false }
            }
            
            // Masquage de la webview le temps de générer le HTML
            webViewEDL.isHidden = true
           
            // Mise à jour des actions de génération de PDF après que le HTML est rendu dans la WebView
            mustExecuteGenereEtDisplayPDF = true
            genereEtDisplayPDF = { [self] in
                if let idEDL = actionBien?.idBien,
                    var newEDL = EDLsController.edlFromUUID(idEDL: idEDL) {
                    let nomFichierAvecSignature = EDLsController.nomFichierEDLPDFAvecSignature(idEDL: idEDL)
                    let urlPDF = documentsDirectory.appendingPathComponent(nomFichierAvecSignature).appendingPathExtension("pdf")
                    genererEDLAsPDF(urlPDF: urlPDF )
                    newEDL.dernierFichierSigneNomFichier = nomFichierAvecSignature
                    newEDL.dateDernierFichierSigne = Date()
                    _ = EDLsController.majEDL(edl: newEDL, false)
                    
                    displayEDLAsPDF(urlPDF: urlPDF)
                }
                
            }
            displayEDLAsHTML(isDocSigne: true)
            
        case .PDFSansSignatureVisuPartage:
            if let nomFichierSansSignature = edl.dernierFichierViergeNomFichier {
                let urlPDF = documentsDirectory.appendingPathComponent(nomFichierSansSignature).appendingPathExtension("pdf")
                displayEDLAsPDF( urlPDF: urlPDF )
            }
            
        case .PDFAvecSignatureVisuPartage:
            if let nomFichierAvecSignature = edl.dernierFichierSigneNomFichier {
                let urlPDF = documentsDirectory.appendingPathComponent(nomFichierAvecSignature).appendingPathExtension("pdf")
                displayEDLAsPDF( urlPDF: urlPDF )
            }
            
        default:
            print ("Erreur CasAppel")
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Appel de la delegue BiensViewController si on a génére le fichier
         if casAppel == .HTMLAvecSignatureGenererPDFVisuPartage || casAppel == .HTMLSansSignatureGenererPDFVisuPartage {
            if let actionBien = self.actionBien,
               let indexPath = self.indexPath,
               let edl = EDLsController.edlFromUUID(idEDL: actionBien.idBien) {
                // Il faut mettre à jour les actions en retour
                delegate?.previsualiserViewController(self, didPublishDoc: edl, for: actionBien, indexPath: indexPath )
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func rightBarButtonClick(_ sender: UIBarButtonItem) {
        
        switch casAppel {
        case .HTMLSansSignatureGenererPDFVisuPartage, .PDFSansSignatureVisuPartage :
            if let nomFichier = edl.dernierFichierViergeNomFichier {
                showOptionsAlert(nomFichier: nomFichier)
            }
        case .HTMLAvecSignatureGenererPDFVisuPartage, .PDFAvecSignatureVisuPartage:
            
            if let nomFichier = edl.dernierFichierSigneNomFichier {
                showOptionsAlert(nomFichier: nomFichier)
                
            }
            
        default:
            print ("Erreur cas Appel")
            
        }
    }
    
    
    // MARK: - Génération et Affichage HTML et PDF
    /// Le passage de l'affichage à la génération se fait via la webView
    /// La génération du PDF est faite par la fonction didFinsish de la webView sur le chargement du HTML
    
    func webView(_ webViewEDL: WKWebView, didFinish navigation: WKNavigation!) {
        if mustExecuteGenereEtDisplayPDF {
            // Pour n'exécuter qu'une fois le lancement de l'affichage du PDF
            mustExecuteGenereEtDisplayPDF = false
            
            // Actions prévues pour générer le PDF et mettre à jour l'EDL
            genereEtDisplayPDF()
            webViewEDL.isHidden = false
            
        }
        
      }
    
    /// Affichage du fichier HTML fusionné avec présence ou non d ela signature
    func displayEDLAsHTML ( isDocSigne: Bool) {
        
        if let nomFichierHTMLFusionne = edlComposer.renderEDL(),
               let urlFichierHTMLFusionne = URL(string: nomFichierHTMLFusionne) {
            // Appel de la Webview avec, l'URL de Base
            // webViewEDL.loadHTMLString(edlHTML, baseURL: edlComposer.documentsDirectory)
            // webViewEDL.loadHTMLString(edlHTML, baseURL: nil)
            
            _ = self.webViewEDL.loadFileURL(urlFichierHTMLFusionne, allowingReadAccessTo: self.edlComposer.documentsDirectory)
            
        }
    }
    
    /// Génération du PDF à partir de la Webview comprenant le fichier HTML fusionné en indiquant l'URL du fichier PDF à créer
    func genererEDLAsPDF (urlPDF : URL) {
            self.edlComposer.exportHTMLContentToPDF(webViewPrintFormatter: self.webViewEDL.viewPrintFormatter(), urlPDF: urlPDF)
    }
    
    
    /// Affichage du fichier PDF indiqué par l'URL
    func displayEDLAsPDF ( urlPDF : URL ) {
            let request = NSURLRequest(url: urlPDF)
            self.webViewEDL.load(request as URLRequest)
    }
    
    var feedBackManager: Feedback!
    
    // MARK: - Exploitation PDF
    
    /// Deux options : envoi par mail ou affichage du controlleur de partage de document standard
    func showOptionsAlert(nomFichier: String) {
        let alertController = UIAlertController(title: "C'est fini !", message: "Le document est disponible en format PDF.\n\nQue voulez-vous en faire", preferredStyle: UIAlertController.Style.alert)

        let urlPDF = documentsDirectory.appendingPathComponent(nomFichier).appendingPathExtension("pdf")
        
        if MFMailComposeViewController.canSendMail() {
            
            let actionEmail = UIAlertAction(title: "L'envoyer par email au locataire", style: UIAlertAction.Style.default) { (action) in
                self.envoiMail = true
            }
            alertController.addAction(actionEmail)
        }
        
        
        
        let actionPartage = UIAlertAction(title: "Le partager", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                let activityController = UIActivityViewController(activityItems: [urlPDF], applicationActivities: nil)
                activityController.popoverPresentationController?.sourceView = alertController.parent?.view
                self.present(activityController, animated: true, completion: nil)
            }
        }
        alertController.addAction(actionPartage)
            let actionNothing = UIAlertAction(title: "Ne rien faire", style: UIAlertAction.Style.default) { (action) in
                
               self.navigationController?.popToRootViewController(animated: true)
                
                
            }
            alertController.addAction(actionNothing)
        
        
        
            
        present(alertController, animated: true, completion: nil)
        
    }
    
    /// Présentation du mail d'envoi, activation via la variable envoiMail
    func sendEmail(urlPDF: URL) {
            
            var subjectMail: String = "Constat d'état des lieux"
            var recipientMail: [String] = []
            let messageBody: String = "Bonjour,\n Veuillez trouver en P.J. le constat d'état des lieux établi ce jour"
            var nomFichier: String = ""
            
            if let edl = self.edl ,
               let refEDL = edl.refEDL,
               refEDL != "" {
                subjectMail += " - Ref: \(refEDL)"
                nomFichier = "Constat-"+" - Ref: \(refEDL)"
                subjectMail += " pour \(edl.nomBien)"
            }
            if let email = edl?.emailLocataire {
                recipientMail.append(email)
            }
        
        let feedBack =  FeedbackManager(feedBack: Feedback(recipients: recipientMail, subject: subjectMail, body: messageBody, urlPDF: urlPDF, nomFicPDF: nomFichier))
        
        feedBack.sendEmailFeedBack(presentingViewController: self)
    }
    
   
}


struct Feedback {
    let recipients: [String]
    let subject: String
    let body: String
    let urlPDF: URL
    let nomFicPDF: String
}

class FeedbackManager: NSObject, MFMailComposeViewControllerDelegate {
    
    var feedBack: Feedback
    
    init(feedBack: Feedback) {
        self.feedBack = feedBack
    }
    func sendEmailFeedBack(presentingViewController: UIViewController) {
        
        
       
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(self.feedBack.recipients)
            mail.setSubject(self.feedBack.subject)
            mail.addAttachmentData(NSData(contentsOf: feedBack.urlPDF)! as Data, mimeType: "application/pdf", fileName: feedBack.nomFicPDF)
            mail.setMessageBody(feedBack.body, isHTML: false)
            
            
            presentingViewController.present(mail, animated: true)
            
        } else {
            print("else:")
            mailFailed(presentingViewController: presentingViewController)
        }
    }
    
    func mailFailed(presentingViewController: UIViewController) {
        print("mailFailed():")
        let failedMenu = UIAlertController(title: "Please Email Me!", message: nil, preferredStyle: .alert)
        let okAlert = UIAlertAction(title: "Ok!", style: .default)
        failedMenu.addAction(okAlert)
        presentingViewController.present(failedMenu, animated: true, completion: nil)
    }
    
    

    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        print ("Resultat = ",result.rawValue)
        if let error = error {
                print ("Erreur :", error.localizedDescription)
            }
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
