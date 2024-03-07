//
//  CompteurContentView.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit
import Foundation

class CompteurContentView: UIView, UIContentView {
    
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var nomCompteurLabel: UILabel!
    @IBOutlet var nombreImageButton: UIButton!
    
    
    
    @IBOutlet var localisationLabel: UILabel!
    @IBOutlet var localisationStack: UIStackView!
    
    @IBOutlet var entreeStack: UIStackView!
    
    @IBOutlet var releveEntreeStack: UIStackView!
    @IBOutlet var valeurLabel: UILabel!
    @IBOutlet var enServiceLabel: UILabel!
    
    @IBOutlet var motifEntreeStack: UIStackView!
    @IBOutlet var motifNonPresentationLabel: UILabel!
    
    
    @IBOutlet var sortieStack: UIStackView!
    
    @IBOutlet var releveSortieStack: UIStackView!
    @IBOutlet var valeurSortieLabel: UILabel!
    @IBOutlet var enServiceSortieLabel: UILabel!
    
    @IBOutlet var motifSortieStack: UIStackView!
    @IBOutlet var motifNonPresentationSortieLabel: UILabel!
    
    

    
    private var currentConfiguration: CompteurContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
        guard let newConfiguration = newValue as? CompteurContentConfiguration else { return }
        self.apply(configuration: newConfiguration)
        }
    }
    
    init (configuration: CompteurContentConfiguration) {
        super.init(frame: .zero)
 //       self.configuration = configuration
        
        loadNib()
        
        
        apply(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    override func updateConstraints() {
//        print ("Contrainte modifié")
//    }
}



private extension CompteurContentView {
    private func loadNib() {
        // 3
        // Load SFSymbolNameContentView.xib by making self as owner of SFSymbolNameContentView.xib
        Bundle.main.loadNibNamed("\(CompteurContentView.self)", owner: self, options: nil)
        
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
    
    private func apply(configuration: CompteurContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        
        nomCompteurLabel.text = configuration.nomCompteur
        
        print ( "#### \(configuration.nomCompteur) = Debut" )
        
        
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
        
        
        
        
        localisationStack.isHidden = true
        
        if configuration.localisationCompteur != "" {
            localisationLabel.text = configuration.localisationCompteur
            localisationStack.isHidden = false
        }
        
        // Affichage des données de l'EDL Entree
        var presenceEntree: Bool = false
        
        entreeStack.isHidden = true
        releveEntreeStack.isHidden = true
        motifEntreeStack.isHidden = true
        
        if let indexCompteur = configuration.indexCompteur,
           indexCompteur > 0 {
            valeurLabel.text = "Releve : \(String(indexCompteur)) " + (configuration.uniteCompteur ?? "")
            entreeStack.isHidden = false
            releveEntreeStack.isHidden = false
            presenceEntree = true
        }
        else {
            valeurLabel.text = "Pas de relevé"
            entreeStack.isHidden = false
            releveEntreeStack.isHidden = false
         }
        enServiceLabel.text = configuration.enServicePresent ?? true ? "En service" : "Hors service"
        
        if let motifEntree = configuration.motifNonReleve,
            motifEntree != "" {
            motifNonPresentationLabel.text = motifEntree
            entreeStack.isHidden = false
            motifEntreeStack.isHidden = false
            presenceEntree = true
            
        }
        
        // Affichage des données de l'EDL Sortie
        var presenceSortie: Bool = false
        
        sortieStack.isHidden = true
        releveSortieStack.isHidden = true
        motifSortieStack.isHidden = true
        
        if let indexCompteur = configuration.indexCompteurSortie {
            valeurSortieLabel.text = "Releve : \(String(indexCompteur)) " + (configuration.uniteCompteurSortie ?? "")
            sortieStack.isHidden = false
            releveSortieStack.isHidden = false
            presenceSortie = true
        }
        else {
            valeurSortieLabel.text = "Pas de relevé"
        }
        print ( "#### ", configuration.enServicePresentSortie ?? "Pas de valeur")
        if configuration.enServicePresentSortie != nil
        {
            enServiceSortieLabel.text = configuration.enServicePresentSortie! ? "En service" : "Hors service"
            sortieStack.isHidden = false
            releveSortieStack.isHidden = false
            presenceSortie = true
        }
        
        if let motifSortie = configuration.motifNonReleveSortie,
            motifSortie != "" {
            motifNonPresentationSortieLabel.text = motifSortie
            sortieStack.isHidden = false
            motifSortieStack.isHidden = false
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
