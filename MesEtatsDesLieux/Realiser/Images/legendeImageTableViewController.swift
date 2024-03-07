//
//  legendeImageTableViewController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 26/12/2022.
//

import UIKit

class legendeImageTableViewController: UITableViewController, UITextFieldDelegate {
    var imageEDLImage: ImageEDLImage?
    var aSupprimer = false
    
    @IBAction func endEditingLegende() {
        
        print("----- Edit legende")
        self.imageEDLImage?.legende = self.legendTextField.text!
            
        
    }
    
    @IBAction func changedEditing() {
        print("----- Edit legende")
        self.imageEDLImage?.legende = self.legendTextField.text!
    }
    
    @IBOutlet var supprimerButton: UIButton!
    @IBOutlet var validerButton: UIButton!
    
    
   
    
    init(coder: NSCoder, imageEDLImage: ImageEDLImage) {
        
        self.imageEDLImage = imageEDLImage
        super.init(coder: coder)!
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet var scrollViewImage: UIScrollView!
    @IBOutlet var imageEDLImageView: UIImageView!
    @IBOutlet var legendTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageEDLImageView.image = imageEDLImage?.image
        legendTextField.text = imageEDLImage?.legende
        scrollViewImage.delegate = self
        legendTextField.delegate = self
        legendTextField.returnKeyType = .done
        
        // Creating a constraint using NSLayoutConstraint
        NSLayoutConstraint(item: imageEDLImageView as Any,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: scrollViewImage,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        
        // Creating a constraint using NSLayoutConstraint
        NSLayoutConstraint(item: imageEDLImageView as Any,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: scrollViewImage,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewForZooming ( in scrollView: UIScrollView ) -> UIView? {
        if scrollView == scrollViewImage {
            return imageEDLImageView }
        else {
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let senderButton = sender as? UIButton {
            if senderButton == supprimerButton {
                    self.aSupprimer = true
                }
            }
            
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        super.resignFirstResponder()
        legendTextField.resignFirstResponder()
        return false
    }
    
    
}

