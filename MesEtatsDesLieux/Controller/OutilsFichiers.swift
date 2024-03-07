//
//  OutilsFichiers.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 23/12/2022.
//

import Foundation


func sauveElements<T>(_ elements: [T], nomFic: String) where T : Encodable  {
    print ("----- Repertoire de sauvegarde")
    let archiveURL = documentsDirectory.appendingPathComponent(nomFic).appendingPathExtension("plist")
    let propertyListEncoder = PropertyListEncoder()
    let categories = try? propertyListEncoder.encode(elements)
    try? categories?.write(to: archiveURL, options: .noFileProtection)
}


func downloadFichier(nomFic: String, extFic: String) {
    var codeRetour = HTTPURLResponse()
    if let url = URL(string: "https://bd2db.com/tagada/\(nomFic).\(extFic)") {
        
        let destinationFichierURL = documentsDirectory.appendingPathComponent(nomFic).appendingPathExtension(extFic)
        // Utilisation d'une session sans cache
        
        let task = URLSession(configuration: .ephemeral).dataTask(with: url) { (data, response, error) in
            switch error {
            case .some(let error):
                print("Impossible de récupérer : \(nomFic).\(extFic) -", error)
            case .none:
                var message: String = ""
                if let data = data,
                   let httpResponse = response as? HTTPURLResponse {
                    codeRetour = httpResponse
                    message = "Mise à jour de \(nomFic).\(extFic) (\(String(codeRetour.statusCode)))"
                    if codeRetour.statusCode == 200 {
                        message += " - > Data = \(data.description)"
                        do {
                            try data.write(to: destinationFichierURL)
                            message += " -> Ecriture du fichier téléchargé"
                        }
                        catch {
                            message += " -> Ecriture du fichier en ERREUR"
                        }
                    } else {
                        if let sourceFichierBundle = Bundle.main.path(forResource: nomFic, ofType: extFic) {
                            
                            do {
                                let content = try String(contentsOfFile: sourceFichierBundle)
                                message += " -> Lecture du fichier Bind : OK"
                                try content.write(to: destinationFichierURL, atomically: true, encoding: .utf8)
                                message += " -> Ecriture du fichier Document : OK"
                            } catch {
                                message += "-> Recopie de fichier Bind en erreur"
                                
                            }}
                        else {
                            message += "-> Fichier Bundle inexistant"
                        }
                    }
                    // Message de trace
                    print(message)
                }
            }
        }
        task.resume()
    }
}

func downloadAllFichiers() {
    
    
    
    var listeFichiers: [[String]] = [[]]
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let listeFichiersURL = documentsDirectory.appendingPathComponent("listeFicSynchro").appendingPathExtension("json")
    do {
        let jsonDecoder = JSONDecoder()
        let dataListeFic = try Data(contentsOf: listeFichiersURL)
        listeFichiers = try jsonDecoder.decode(Array<Array<String>>.self, from: dataListeFic)
    } catch {
        print("Impossible de télécharger la liste des fichiers à synchroniser et pas de liste dans le Bundle")
    }
    
    for nomFichier in listeFichiers {
        downloadFichier(nomFic: nomFichier[0], extFic: nomFichier[1])
    }
}
    
func downloadListeFichiers () {
    downloadFichier(nomFic: "listeFicSynchro", extFic: "json")
}


func supprFichier (nomFichier: String , extensionFichier: String? = "") {
    var fichierUrl = getDocumentsDirectory().appendingPathComponent(nomFichier)
    if let extensionFichier = extensionFichier,
       extensionFichier != "" {
        fichierUrl = getDocumentsDirectory().appendingPathComponent(nomFichier).appendingPathExtension(extensionFichier)
    }
    print ("URL du fichier: \(fichierUrl)")
    do {
        try FileManager.default.removeItem(at: fichierUrl) }
    catch {
        print("Impossible de supprimer: \(error)") }
    
}

func supprFichier ( listeURL: [URL]) {
    for u in listeURL {
        do {
            try FileManager.default.removeItem(at: u) }
        catch {
            print("Impossible de supprimer: \(error)") }
    }
}

func listeFichier (_ textePresent: String? = "" ) -> [URL] {
   
    let documentsURL = getDocumentsDirectory()
    var fileURLs: [URL] = [ ]
    
    do {
        fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
    } catch {
        print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
    }
    if let chaine = textePresent,
       chaine != "" {
        fileURLs = fileURLs.filter { $0.absoluteString.contains(chaine)}
    }
    return fileURLs
}

// TODO: à modifier pour faire les deux types de fichier
func duplicatePDF (nomFichierPDF: String) -> String {
    var newPDFNomFichier = EDLsController.nomFichierEDLPDFAvecSignature(idEDL: EDLsController.selectedEDLUUID()!)
    do {
        let sourceUrl = getDocumentsDirectory().appendingPathComponent(nomFichierPDF).appendingPathExtension("pdf")
        let destURL = getDocumentsDirectory().appendingPathComponent(newPDFNomFichier).appendingPathExtension("pdf")
        try FileManager().copyItem(at: sourceUrl, to: destURL)
    } catch {
        print("Erreur duplicateImage")
        newPDFNomFichier = ""
    }
    return newPDFNomFichier
}
