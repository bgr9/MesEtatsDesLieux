//
//  EntretienContentView.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit
import Foundation

class EntretienContentView: UIView, UIContentView {
    
    
    @IBOutlet var containerView: UIView!
    
    
    
    @IBOutlet var intituleLabel: UILabel!
    @IBOutlet var nombreImageButton: UIButton!
    @IBOutlet var realiseLabel: UILabel!
    
    @IBOutlet var dateEcheanceEntretienLabel: UILabel!
    @IBOutlet var observationEntretienLabel: UILabel!
    
    
    @IBOutlet var observationStack: UIStackView!
    @IBOutlet var echeanceStack: UIStackView!
    @IBOutlet var stackVertival: UIStackView!
    
    private var currentConfiguration: EntretienContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
        guard let newConfiguration = newValue as? EntretienContentConfiguration else { return }
        self.apply(configuration: newConfiguration)
        }
    }
    
    init (configuration: EntretienContentConfiguration) {
        super.init(frame: .zero)
  //      self.configuration = configuration
        
        loadNib()
        
        apply(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



private extension EntretienContentView {
    private func loadNib() {
        // 3
        // Load SFSymbolNameContentView.xib by making self as owner of SFSymbolNameContentView.xib
        Bundle.main.loadNibNamed("\(EntretienContentView.self)", owner: self, options: nil)
        
        // 4
        // Add containerView as subview and make it cover the entire content view
        addSubview(containerView)
       containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0)
            
        ])
        
       
    }
    
    private func apply(configuration: EntretienContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        var heightCell: Int = 0 // Ne sert pas
        intituleLabel.text = configuration.intitule
        heightCell += 34 + 5
        
        nombreImageButton.isEnabled = true
        var configButtonImage = UIButton.Configuration.plain()
        if configuration.nombrePhotos == 0 {
            configButtonImage.image = UIImage(systemName: "camera")
            configButtonImage.imagePadding = 5
            configButtonImage.imagePlacement = .trailing
            configButtonImage.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
           
            nombreImageButton.configuration = configButtonImage
        } else {
            
            configButtonImage.image = UIImage(systemName: "camera.fill")
            configButtonImage.imagePadding = 5
            configButtonImage.imagePlacement = .leading
            configButtonImage.preferredSymbolConfigurationForImage
              = UIImage.SymbolConfiguration(scale: .medium)
            configButtonImage.title = String(configuration.nombrePhotos)
            nombreImageButton.configuration = configButtonImage
        }
        
        
        observationStack.isHidden = true
        if configuration.observation != "" {
                observationEntretienLabel.text = configuration.observation
                observationStack.isHidden = false
                heightCell += 18 + 5
        }
    
        realiseLabel.text = configuration.realise ? "Actif" : "Inactif"
        heightCell += 18 + 5
            
        
        echeanceStack.isHidden = true
        if configuration.dateEcheanceEntretien != "" {
            dateEcheanceEntretienLabel.text = configuration.dateEcheanceEntretien
            echeanceStack.isHidden = false
            heightCell += 18
        }
    }
    
}
