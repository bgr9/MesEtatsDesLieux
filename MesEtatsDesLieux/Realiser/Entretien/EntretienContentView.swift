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
    
    @IBOutlet var stackVertival: UIStackView!
    
    @IBOutlet var realiseLabel: UILabel!
    @IBOutlet var dateEcheanceEntretienLabel: UILabel!
    @IBOutlet var echeanceStack: UIStackView!

    @IBOutlet var observationStack: UIStackView!
    @IBOutlet var observationEntreeStack: UIStackView!
    @IBOutlet var observationEntretienLabel: UILabel!
    @IBOutlet var observationSortieStack: UIStackView!
    @IBOutlet var observationEntretienSortieLabel: UILabel!
    
    
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
        
        intituleLabel.text = configuration.intitule
        
        
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
        
        // Affichage des données de l'EDL Entree
        
        observationStack.isHidden = true
        if configuration.observation != "" {
                observationEntretienLabel.text = configuration.observation
                observationStack.isHidden = false
        }
    
        realiseLabel.text = configuration.realise ? "Actif" : "Inactif"
        
        echeanceStack.isHidden = true
        if configuration.dateEcheanceEntretien != "" || configuration.realise {
            dateEcheanceEntretienLabel.text = configuration.dateEcheanceEntretien
            echeanceStack.isHidden = false
        }
        
        observationStack.isHidden = true
        
        observationEntreeStack.isHidden = true
        var presenceObservationEntree: Bool = false
        if let observationEntree = configuration.observation,
           observationEntree != "" {
            observationStack.isHidden = false
            observationEntreeStack.isHidden = false
            observationEntretienLabel.text = observationEntree
            presenceObservationEntree = true
        }
        
        // Affichage des données de l'EDL Sortie
        observationSortieStack.isHidden = true
        var presenceObservationSortie: Bool = false
        if let observationSortie = configuration.observationSortie,
           observationSortie != "" {
            observationStack.isHidden = false
            observationSortieStack.isHidden = false
            observationEntretienSortieLabel.text = observationSortie
            presenceObservationSortie = true
            
        }
        observationSortieStack.layer.backgroundColor = UIColor.fondCouleurDefaut.cgColor
        observationEntreeStack.layer.backgroundColor =  UIColor.fondCouleurDefaut.cgColor
        if presenceObservationSortie {
            observationSortieStack.layer.backgroundColor = UIColor.fondCouleurSortie.cgColor
             if presenceObservationEntree {
                 observationEntreeStack.layer.backgroundColor = UIColor.fondCouleurEntree.cgColor
             }
         }
        
        
    }
    
}
