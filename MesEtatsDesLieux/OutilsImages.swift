//
//  OutilsImages.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 26/12/2022.
//

import Foundation
import UIKit
import AVFoundation
import MessageUI

let evaluationMonEtatDesLieux: Bool = true

// formatage date JJ/MM/AAAA HH:MM
// Pour formater en chaine dateFormatter.string(from: Date())
// Pour formater en date   dateFormatter.date(from:"JJ/MM/AAAA HH:MM")
// Date du jour à 00:00 : let minuitAujourdhui = Calendar.current.startOfDay(for: Date())
//var dateFormatter: DateFormatter = {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateStyle = .short
//    dateFormatter.timeStyle = .short
//    dateFormatter.locale = Locale(identifier: "fr_FR")
//    return dateFormatter
// }()


func ajoutImageEDL (inImage: UIImage, inLegende: String) -> ImageEDL? {
    
    
    // Génération du nom de fichier unique en fonction de la date ou du paramètre donné
    // A faire ajout d'un parametre nom de fichier unique
    // Solution 1 à retourner
    // Solution 2 à à stocker dans l'équipement fourni via le controller en entrée
    
    // A faire ajout d'un fichier étiquette de taille réduite ?
    
    // Retourne l'image modifiée ou l'image systeme photo si probleme
    
    let scale = UIScreen.main.scale
    print ("Echelle format device :", scale)
    
    if inImage.size.width > inImage.size.height {
        // Paysage
        // 1 On retaille pour rentrer dans 300 en largeur
        guard let inImageRetaille = inImage.resizeImageTo(size: CGSize(width: 300, height: 300 * inImage.size.height / inImage.size.width)) else {
            print("Probleme pour retailler le logo")
            return nil }
        // 2 On incruste la legende
        let imageRetailleAvecLegende = formatImageAvecLegende(inImage: inImageRetaille)
        let nomImage = nomImage()
        
        // 3 On recadre pour centrer l'image verticalement dans 300
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 300, height: 300), false, scale)
        imageRetailleAvecLegende.draw(at: CGPoint(x: 0, y: (300 - imageRetailleAvecLegende.size.height)/2))
        if let imageFinale = UIGraphicsGetImageFromCurrentImageContext(),
           sauveImage(inImage: imageFinale, nomImage: nomImage) {
            UIGraphicsEndImageContext()
            return  ImageEDL(legendText: inLegende, nomImage: nomImage)
        }
        UIGraphicsEndImageContext()
        return nil
    } else {
        // Portrait
        // 1 On retaille pour rentrer dans 300 en largeur
        guard let inImageRetaille = inImage.resizeImageTo(size: CGSize(width: 300 * inImage.size.width / inImage.size.height, height: 300.0 )) else {
            print("Probleme pour retailler le logo")
            return nil }
        // 2 On incruste la legende
        let imageRetailleAvecLegende = formatImageAvecLegende(inImage: inImageRetaille)
        let nomImage = nomImage()
        
        // 3 On recadre pour centrer l'image verticalement dans 300
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 300, height: 300), false, scale)
        imageRetailleAvecLegende.draw(at: CGPoint( x: ((300 - imageRetailleAvecLegende.size.width)/2), y: 0))
        
        if let imageFinale = UIGraphicsGetImageFromCurrentImageContext(),
           sauveImage(inImage: imageFinale, nomImage: nomImage) {
            UIGraphicsEndImageContext()
            return  ImageEDL(legendText: inLegende, nomImage: nomImage)
        }
        UIGraphicsEndImageContext()
        return nil
        
    }
                                      
     /*
                                      
                                      else {
            return ImageEDL(legendText: inLegende, nomImage: nomImage) }
        UIGraphicsEndImageContext()
        
        
        
        
    }
    print ("En deb Taille image :", inImage.size)
    print ("En deb Echelle image :", inImage.scale)
    
    let echelleImage = inImage.size.width / inImage.size.height
    let nouvelleLargeurImage = echelleImage * hauteurImage
    
    guard let inImageRetaille = inImage.resizeImageTo(size: CGSize(width: nouvelleLargeurImage, height: hauteurImage)) else {
        print("Probleme pour retailler le logo")
        return nil }
    print ("Apres retaille Taille image :", inImageRetaille.size)
    print ("Apres retaille Echelle image :", inImageRetaille.scale)
    let imageRetailleAvecLegende = formatImageAvecLegende(inImage: inImageRetaille)
    let nomImage = nomImage()
    print ("En fin Taille image :", imageRetailleAvecLegende.size)
    print ("En fin Echelle image :", imageRetailleAvecLegende.scale)
    if sauveImage(inImage: imageRetailleAvecLegende, nomImage: nomImage) {
        
        return  ImageEDL(legendText: inLegende, nomImage: nomImage)
    } else {
        print ("Erreur dans l'ecriture de l'image")
               return nil } */
}

func nomImage () -> String {
    return "imageEDL_" + UUID().uuidString
    
}
func formatImageAvecLegende(inImage: UIImage) -> UIImage{

    // Formate l'image :
    // - Retaillage en 300/300
    // - Si version évaluation, ajout "MonEtatDesLIEUX"
    // - Ajout Horodatage
    
    // TODO: Echelle image
    
    // Setup the image context using the passed image
    print ("En deb format Taille image :", inImage.size)
    print ("En deb format Echelle image :", inImage.scale)
    
    
    let scale = UIScreen.main.scale
    print ("Echelle format device :", scale)
    
    UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
    /*
    if inImage.size.height > inImage.size.width {
        inImage.draw(in: CGRectMake(0, 0, inImage.size.width, inImage.size.width))
    } else {
    */
        // Put the image into a rectangle as large as the original image
    inImage.draw(in: CGRectMake(0, 0, inImage.size.width, inImage.size.height))
    
    if evaluationMonEtatDesLieux {
        let rect = CGRectMake(inImage.size.width/2 - 50 , inImage.size.height / 2 - 50 , 100 , 100 )
   
        let filigrane = UIImage(named: "filigrane")
        filigrane?.draw(in: rect)
    }
    
    // Legende horodatage
    let rectangleHoro = CGRect(x: 0, y: inImage.size.height - 15, width: 300, height: 300)
    let horoTexte = "\(dateFormatter.string(from: Date()))"
    let fontHoro = UIFont(name: "Courier New", size: 15)!
    let attributesHoro: [NSAttributedString.Key: Any] = [
        .font: fontHoro,
        .foregroundColor: UIColor.white,
        .backgroundColor: UIColor.black]
    let horoFormatte = NSAttributedString(string: horoTexte, attributes: attributesHoro)
    
    horoFormatte.draw(in: rectangleHoro)

    // Create a new image out of the images we have created
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
        return inImage }

    // End the context now that we have the image we need
    UIGraphicsEndImageContext()
    
    /*
    
    print ("En fin Taille image :", newImage.size)
    print ("En fin Echelle image :", newImage.scale)
    
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 300, height: 300), true, 1)
    
    let largeurImage = newImage.size.width
    let coordX = 300 - largeurImage / 2
    newImage.draw(at: CGPoint(x: coordX, y: 0))
    guard let imageNormalise = UIGraphicsGetImageFromCurrentImageContext() else {
        return newImage }
    UIGraphicsEndImageContext()
     */
    
  /*
    let maxSize = CGSize(width: 300, height: 300)

    let availableRect = AVFoundation.AVMakeRect(aspectRatio: newImage.size, insideRect: .init(origin: .zero, size: maxSize))
    let targetSize = availableRect.size

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

    let resized = renderer.image { (context) in
        newImage.draw(in: CGRect(origin: .zero, size: targetSize))
   */
    
    print ("En fin format Taille image :", newImage.size)
    print ("En fin format Echelle image :", newImage.scale)
    return newImage
    }
    

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        print ("scale \(scale), image.size.height \(image.size.height ) , image.size.width \(image.size.width)")
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resizeImageTo(size: CGSize) -> UIImage? {
           
           UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
           self.draw(in: CGRect(origin: CGPoint.zero, size: size))
           let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()
           return resizedImage
       }
    
}

extension UIColor {
    static func rgbColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    static func colorFromHex(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        if hexString.count != 6 {
            return UIColor.magenta
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
                       green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
                       blue: CGFloat(rgb & 0x0000FF) / 255,
                       alpha: 1.0)
    }
}

func getDocumentsDirectory() -> URL {
    let paths = documentsDirectory

//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths }




func sauveImage (inImage: UIImage, nomImage: String) -> Bool{
    
    if let data = inImage.pngData() {
           
           let filename = getDocumentsDirectory().appendingPathComponent(nomImage)
           try? data.write(to: filename)
           return true
        } else { return false}
    }

func existeImage (idImage: String) -> Bool {
    let imageUrl = getDocumentsDirectory().appendingPathComponent(idImage)
    
    let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: imageUrl.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return false
            }else{
                return true
            }
        }
    return false
    
}

func chargeImage (idImage: String) -> UIImage {
    
    let imageUrl = getDocumentsDirectory().appendingPathComponent(idImage)
    print("On charge : \(imageUrl)")
    if let image = UIImage(contentsOfFile: imageUrl.path)
    {   print("image chargee")
        return image
    } else {
        print("erreur")
        return UIImage(systemName: "photo")! }
    
    
}

func supprImage (idImage: String) {
   supprFichier(nomFichier: idImage)
}

func duplicateImage (idImage: String) -> String {
    var newIdImage = nomImage()
    do {
        let imageUrl = getDocumentsDirectory().appendingPathComponent(idImage)
        let destImageURL = getDocumentsDirectory().appendingPathComponent(newIdImage)
        try FileManager().copyItem(at: imageUrl, to: destImageURL)
    } catch {
        print("Erreur duplicateImage")
        newIdImage = ""
    }
    return newIdImage
}

//func convertImageToBase64String (img: UIImage) -> String {
//    return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
// }

//func convertBase64StringToImage (imageBase64String:String) -> UIImage {
//    let imageData = Data(base64Encoded: imageBase64String)
//    let image = UIImage(data: imageData!)
//    return image!
// }

