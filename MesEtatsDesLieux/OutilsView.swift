//
//  OutilsView.swift
//  BienCollection
//
//  Created by B Grossin on 02/02/2023.
//

import Foundation
import UIKit


extension UILabel {

    // extension user defined Method
    func itemLabel() {
      self.translatesAutoresizingMaskIntoConstraints = false
      self.font = .preferredFont(forTextStyle: .body)
      self.textAlignment = .center
      self.backgroundColor = .systemBackground
      self.layer.masksToBounds = true
      self.layer.cornerRadius = 8
      self.numberOfLines = 3
      self.clipsToBounds = true
    }
  
  func itemModifiableLabel(valeur: String? = nil) {
      UIView.transition(with: self,
        duration: 1,
        options: .transitionCrossDissolve,
        animations: { [weak self] in
            self!.translatesAutoresizingMaskIntoConstraints = false
            self!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: .current)
            self!.numberOfLines = 3
            self!.backgroundColor = .secondarySystemFill
            self!.textAlignment = .center
            self!.layer.masksToBounds = true
            self!.layer.cornerRadius = 21
            self!.isUserInteractionEnabled = true
            if let string = valeur {
              self!.text = string
            }
      },
        completion: nil)
  }
  
    func itemStyleIncomplet (valeur: String? = nil) {
      
    UIView.transition(with: self,
        duration: 1,
        options: .transitionCrossDissolve,
        animations: { [weak self] in
            self!.translatesAutoresizingMaskIntoConstraints = false
            self!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: .current)
            self!.numberOfLines = 3
            self!.backgroundColor = .systemOrange.withAlphaComponent(0.3)
            self!.textAlignment = .center
            self!.layer.masksToBounds = true
            self!.layer.cornerRadius = 21
            self!.isUserInteractionEnabled = true
            if let string = valeur {
            self!.text = string
            }
        },
        completion: nil)
    }
  func itemStyleComplet (valeur: String? = nil) {
    
    UIView.transition(with: self,
        duration: 1,
        options: .transitionCrossDissolve,
        animations: { [weak self] in
            self!.translatesAutoresizingMaskIntoConstraints = false
            self!.font = .preferredFont(forTextStyle: .footnote, compatibleWith: .current)
            self!.numberOfLines = 3
            self!.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            self!.textAlignment = .center
            self!.layer.masksToBounds = true
            self!.layer.cornerRadius = 21
            self!.isUserInteractionEnabled = true
            if let string = valeur {
            self!.text = string
            }},
        completion: nil)
    }
                        
    
}





