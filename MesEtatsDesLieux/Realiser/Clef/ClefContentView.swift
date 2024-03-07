//
//  ClefContentView.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit
import Foundation

class ClefContentView: UIView, UIContentView {
    
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var intituleClefLabel: UILabel!
    @IBOutlet var nombreImageButton: UIButton!
    
    @IBOutlet var entreeStack: UIStackView!
    @IBOutlet var observationStack: UIStackView!
    @IBOutlet var observationClefLabel: UILabel!
    @IBOutlet var nombreClefLabel: UILabel!
    
    @IBOutlet var sortieStack: UIStackView!
    @IBOutlet var observationSortieStack: UIStackView!
    @IBOutlet var observationClefSortieLabel: UILabel!
    @IBOutlet var nombreClefSortieLabel: UILabel!
    @IBOutlet var nombreSortieStack: UIStackView!
   
    @IBOutlet var nombreExemplaireEntreeStack: UIStackView!
    
    
    private var currentConfiguration: ClefContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? ClefContentConfiguration else { return }
            self.apply(configuration: newConfiguration)
        }
    }
    
    init (configuration: ClefContentConfiguration) {
        super.init(frame: .zero)
  //      self.configuration = configuration
        
        loadNib()
        
        apply(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



private extension ClefContentView {
    private func loadNib() {
        // 3
        // Load SFSymbolNameContentView.xib by making self as owner of SFSymbolNameContentView.xib
        Bundle.main.loadNibNamed("\(ClefContentView.self)", owner: self, options: nil)
        
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
    
    private func apply(configuration: ClefContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        intituleClefLabel.text = configuration.intituleClef
        
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
        
        
        // Affichage des données de l'EDL Entrée
        var presenceEntree: Bool = false
        
        entreeStack.isHidden = true
        observationStack.isHidden = true
        observationClefLabel.isHidden = true
        nombreExemplaireEntreeStack.isHidden = true
        
        if let observationClef = configuration.observationClef,
           observationClef != "" {
            observationClefLabel.text = observationClef
            entreeStack.isHidden = false
            observationStack.isHidden = false
            observationClefLabel.isHidden = false
            presenceEntree = true
        }
        if configuration.nombreClefs != nil,
            let nombreClef = configuration.nombreClefs {
            nombreClefLabel.text = String(nombreClef)
            entreeStack.isHidden = false
            observationStack.isHidden = false
            nombreExemplaireEntreeStack.isHidden = false
            presenceEntree = true
        }
            
        // Affichage des données de l'EDL Sortie
        var presenceSortie: Bool = false
        
        sortieStack.isHidden = true
        observationSortieStack.isHidden = true
        observationClefSortieLabel.isHidden = true
        nombreSortieStack.isHidden = true
        
        if let observationSortie = configuration.observationClefsSortie,
           observationSortie != "" {
            observationClefSortieLabel.text = observationSortie
            sortieStack.isHidden = false
            observationSortieStack.isHidden = false
            observationClefSortieLabel.isHidden = false
            presenceSortie = true
        }
        
        if let nombreClefSortie = configuration.nombreClefsSortie {
            nombreClefSortieLabel.text = String(nombreClefSortie)
            sortieStack.isHidden = false
            observationSortieStack.isHidden = false
            nombreSortieStack.isHidden = false
            presenceSortie = true
            
        }
    
        sortieStack.layer.backgroundColor = UIColor.fondCouleurDefaut.cgColor
        entreeStack.layer.backgroundColor = UIColor.fondCouleurDefaut.cgColor
        
       if presenceSortie {
            sortieStack.layer.backgroundColor = UIColor.fondCouleurSortie.cgColor
            if presenceEntree {
                entreeStack.layer.backgroundColor = UIColor.fondCouleurEntree.cgColor
            }
        }
    }
    
}
