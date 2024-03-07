//
//  CustomPrintPageRenderer.swift
//  MesEtatsDesLieux
//
//  Created by BD2B on 16/01/2023.
//

import UIKit

protocol EntetePiedPageCustomPrintPageRendererDelegate:  AnyObject {
    func enteteRender (_ customPrintPageRenderer: CustomPrintPageRenderer, enteteAtPage numPage : Int , nombrePages nPages: Int) -> String
    func piedPageRender (_ customPrintPageRenderer: CustomPrintPageRenderer, piedAtPage numPage : Int , nombrePages nPages: Int ) -> String
    func piedPageRender (_ customPrintPageRenderer: CustomPrintPageRenderer, imagePiedAtPage numPage : Int , nombrePages nPages: Int ) -> [Int : UIImage]
}
/*
 
 protocol EquipementDetailTableViewControllerDelegate: AnyObject {
     // Permet de mettre à jour avant de faire disparaitre le compteur (Controlleur et snapshot)
     func equipementDetailTableViewController (_ equipementDetailTableViewController: EquipementDetailTableViewController, didModifyEquipement  equipement: Equipement )
 }

 
 */
class CustomPrintPageRenderer: UIPrintPageRenderer {

     let A4PageWidth: CGFloat = 612
     let A4PageHeight: CGFloat = 792
    
    var delegate: EntetePiedPageCustomPrintPageRendererDelegate?
    
        
    // let A4PageWidth: CGFloat = 595.2
    //    let A4PageHeight: CGFloat = 841.8
    
    override init() {
        super.init()

        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)

        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")

        // Set the horizontal and vertical insets (that's optional).
        self.setValue(NSValue(cgRect: CGRectInset(pageFrame, 10.0, 10.0)), forKey: "printableRect")
        
        self.headerHeight = 20
        self.footerHeight = 60
        
        
        
    }
    
        
        
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        // Specify the header text.
        let headerText: NSString = "Mes Etats des Lieux"

        // Set the desired font.
        let font = UIFont(name: "OpenDyslexic-Regular", size: 9.0)

        // Specify some text attributes we want to apply to the header text.
      //  let textAttributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor(red: 243.0/255, green: 82.0/255.0, blue: 30.0/255.0, alpha: 1.0), NSAttributedString.Key.kern: 7.5] as [NSAttributedString.Key : Any]
        let textAttributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor.vertEDL ?? .black, NSAttributedString.Key.kern: 1] as [NSAttributedString.Key : Any]

        
        // Calculate the text size.
        let textSize = headerText.size(withAttributes: textAttributes)
        

        // Determine the offset to the right side.
        let offsetX: CGFloat = 10.0

        // Specify the point that the text drawing should start from.
        let pointX = headerRect.size.width - textSize.width - offsetX
        let pointY = headerRect.size.height/2 - textSize.height/2

        // Draw the header text.
        headerText.draw(at: CGPointMake(pointX, pointY), withAttributes: textAttributes)
        
        
        let logoEDLRetaille = UIImage(named: "filigrane")!.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        logoEDLRetaille.draw(at: CGPoint(x: 10, y: 0))
    }
        
   
    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        
        
       print ("---0>",footerRect)
        guard let delegate = self.delegate,
            let
                textePiedPageAttribute = try? NSAttributedString (htmlString: delegate.piedPageRender(self, piedAtPage: pageIndex, nombrePages: self.numberOfPages))
        else {return}
        
        let dictImageParaph = delegate.piedPageRender(self, imagePiedAtPage: pageIndex, nombrePages: self.numberOfPages)
 
        print ("---1>",textePiedPageAttribute)
        
        

        let textSize = textePiedPageAttribute.size()
        
        
        let font = UIFont(name: "OpenDyslexic-Bold", size: 8.0)
        let textAttributes = [NSAttributedString.Key.font: font!]
        
       
        
        print ("---2>",textSize)
        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        print ("---3>",centerX , centerY)
    //    textePiedPageAttribute.draw(at: CGPointMake(centerX + 85 , centerY)) */
        
        textePiedPageAttribute.draw(in: footerRect)
   //     textePiedPageAttribute.draw(at: CGPointMake(footerRect.origin.x , footerRect.origin.y))
        
      /*
        
        let footerText: NSString = "Merci!"
       "OpenDyslexic-Regular"
        let font = UIFont(name: "OpenDyslexic-Bold", size: 14.0)
        let textAttributes = [NSAttributedString.Key.font: font!]
        let textSize = footerText.size(withAttributes: textAttributes)

        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        let attributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)]

        footerText.draw(at: CGPointMake(centerX, centerY), withAttributes: attributes)
        
        */
        // Draw a horizontal line.
        let lineOffsetX: CGFloat = 20.0
        let context = UIGraphicsGetCurrentContext()
        
        
        context!.setStrokeColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)
        context!.move(to: CGPoint(x: lineOffsetX, y: footerRect.origin.y))
        context!.addLine(to: CGPoint(x: footerRect.size.width - lineOffsetX, y:  footerRect.origin.y))
        
        
        context!.strokePath()
        
        
    
    
       
        if pageIndex < self.numberOfPages - 1 {
        
        // Set the rectangle outerline-width
            context?.setLineWidth( 0.5)

        // Set the rectangle outerline-colour
        UIColor.black.set()

        context!.move(to: CGPoint(x: lineOffsetX, y: footerRect.origin.y + 20 ))
        
        
        // Create Rectangle de paraphes 
        let bailleurCGRect = CGRect(x: footerRect.size.width - 100 - 20 , y: footerRect.origin.y + 15, width: 100, height: 35)
            
        context?.addRect( bailleurCGRect)
        if dictImageParaph[0] != nil {
            dictImageParaph[0]?.draw(in: bailleurCGRect)
        }
        
        let locataireCGRect = CGRect(x: footerRect.size.width - 100 - 20 - 100 - 20 , y: footerRect.origin.y + 15, width: 100, height: 35)
            
        context?.addRect( locataireCGRect)
            
        if dictImageParaph[1] != nil {
            dictImageParaph[1]?.draw(in: locataireCGRect)
        }
            

        // Draw
        context?.strokePath()
        
        
            let parapheText: NSString = "Paraphes"
            
            let fontParaph = UIFont(name: "OpenDyslexic-Regular", size: 8.0)
            let textAttributesParaph = [NSAttributedString.Key.font: fontParaph!, NSAttributedString.Key.kern: 3, NSAttributedString.Key.foregroundColor: UIColor(ciColor: .gray)] as [NSAttributedString.Key : Any]
    
            
            parapheText.draw(at: CGPointMake(footerRect.size.width - 20 - 20 - 100 - 20, footerRect.origin.y + 1 ), withAttributes: textAttributesParaph)
        }
        
    }
    
}


extension NSAttributedString {

    convenience init(htmlString html: String) throws {
        try self.init(data: Data(html.utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
            
        ], documentAttributes: nil)
        
    }

}
