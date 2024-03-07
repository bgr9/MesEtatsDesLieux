//
//  FournitureContentView.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 25/12/2022.
//

import UIKit
import Foundation

class FournitureContentView: UIView, UIContentView {
    
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var equipementLabel: UILabel!
   
    @IBOutlet var nombreImageButton: UIButton!
    
    @IBOutlet var entreeStack: UIStackView!
    @IBOutlet var nExemplaireStack: UIStackView!
    @IBOutlet var nExemplaireLabel: UILabel!
    
    @IBOutlet var bouttonStack: UIStackView!
    @IBOutlet var etatButton: EtatButton!
    @IBOutlet var propreteButton: PropreteButton!
    @IBOutlet var fonctionnelButton: FonctionnelButton!

    @IBOutlet var observationsStack: UIStackView!
    @IBOutlet var observationsLabel: UILabel!
    
    
    
    @IBOutlet var sortieStack: UIStackView!
    @IBOutlet var nExemplaireSortieStack: UIStackView!
    @IBOutlet var nExemplaireSortieLabel: UILabel!
   
    @IBOutlet var bouttonSortieStack: UIStackView!
    @IBOutlet var etatSortieButton: EtatButton!
    @IBOutlet var propreteSortieButton: PropreteButton!
    @IBOutlet var fonctionnelSortieButton: FonctionnelButton!
    
    @IBOutlet var observationsSortieStack: UIStackView!
    @IBOutlet var observationsSortieLabel: UILabel!
    
    private var currentConfiguration: FournitureContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? FournitureContentConfiguration else { return }
            self.apply(configuration: newConfiguration)
        }
    }
    
    init (configuration: FournitureContentConfiguration) {
        super.init(frame: .zero)
        
        loadNib(configuration: configuration)
        
        apply(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



private extension FournitureContentView {
    private func loadNib(configuration: FournitureContentConfiguration) {
        // 3
        // Load SFSymbolNameContentView.xib by making self as owner of SFSymbolNameContentView.xib
        Bundle.main.loadNibNamed("\(FournitureContentView.self)", owner: self, options: nil)
        
        // 4
        // Add containerView as subview and make it cover the entire content view
        addSubview(containerView)
       containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0),
      //      containerView.heightAnchor.constraint(equalToConstant: CGFloat(calculHeight(configuration: configuration))),
        ])
     //   containerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
       
    }
    
    private func apply(configuration: FournitureContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        equipementLabel.text = configuration.equipement
        
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
        
        // Affichage des données d'entree EDL
        
        entreeStack.isHidden = true
        
        nExemplaireStack.isHidden = true
        nExemplaireLabel.isHidden = true
        if let nExemplaire = configuration.nExemplaire,
           String(nExemplaire) != "" {
            nExemplaireLabel.text = String(nExemplaire)
            nExemplaireStack.isHidden = false
            nExemplaireLabel.isHidden = false
        }
        
        bouttonStack.isHidden = true
        // Masquage si les trois boutons ont une valeur ) .nondefini ou .non applicable
        
        let afficheEtat = configuration.etat != .nondefini && configuration.etat != .nonapplicable
        let afficheProprete = configuration.proprete != .nondefini && configuration.proprete != .nonapplicable
        let afficheFonctionnel = configuration.fonctionnel != .nondefini && configuration.fonctionnel != .nonapplicable
        var nAffiche = 0
        for a in [ afficheEtat, afficheProprete, afficheFonctionnel] {
            if a { nAffiche += 1 }
        }
        var placement: NSDirectionalRectEdge = .leading
   //     if nAffiche == 3 { placement = .top }
        
        if afficheEtat || afficheProprete || afficheFonctionnel {
            
            etatButton.isHidden = !afficheEtat
            if afficheEtat {
                etatButton.etat = configuration.etat
                etatButton.displayEtatButton(placement) }
            
            propreteButton.isHidden = !afficheProprete
            if afficheProprete {
                propreteButton.proprete = configuration.proprete
                propreteButton.displayPropreteButton(placement)}
            
            fonctionnelButton.isHidden = !afficheFonctionnel
            if afficheFonctionnel {
                fonctionnelButton.fonctionnel = configuration.fonctionnel
                fonctionnelButton.displayFonctionnelButton(placement)}
            
            bouttonStack.isHidden = false
        }
       
        
        observationsStack.isHidden = true
        observationsLabel.isHidden = true
        if let observation = configuration.observations,
                    observation != "" && observation != " " {
                    observationsLabel.text = configuration.observations
                    observationsStack.isHidden = false
                    observationsLabel.isHidden = false
                    print (configuration.equipement, "Taille Demasquage observation Entree")
                }
        
        
        entreeStack.isHidden = nExemplaireStack.isHidden && bouttonStack.isHidden && observationsStack.isHidden
        
        // Affichage des données de sortie EDL
        
        sortieStack.isHidden = true
        
        nExemplaireSortieStack.isHidden = true
        nExemplaireSortieLabel.isHidden = true
        if let nExemplaireSortie = configuration.nexemplaireSortie,
           String(nExemplaireSortie) != "" {
            nExemplaireSortieLabel.text = String(nExemplaireSortie)
            nExemplaireSortieStack.isHidden = false
            nExemplaireSortieLabel.isHidden = false
        }
        
        bouttonSortieStack.isHidden = true
        // Masquage si les trois boutons ont une valeur ) .nondefini ou .non applicable
        if configuration.etatSortie != nil || configuration.propreteSortie != nil || configuration.fonctionnelSortie != nil {
            var afficheEtat = false
            var afficheProprete = false
            var afficheFonctionnel = false
            if let etatSortie = configuration.etatSortie, etatSortie != .nondefini, etatSortie != .nonapplicable {
                afficheEtat = true
            }
            if let propreteSortie = configuration.propreteSortie, propreteSortie != .nondefini, propreteSortie != .nonapplicable {
                afficheProprete = true
            }
            if let fonctionnelSortie = configuration.fonctionnelSortie, fonctionnelSortie != .nondefini, fonctionnelSortie != .nonapplicable {
                afficheFonctionnel = true
            }
            
            var nAffiche = 0
            for a in [ afficheEtat, afficheProprete, afficheFonctionnel] {
                if a { nAffiche += 1 }
            }
            var placement: NSDirectionalRectEdge = .leading
         //   if nAffiche == 3 { placement = .top }
            
            if afficheEtat || afficheProprete || afficheFonctionnel {
                
                etatSortieButton.isHidden = !afficheEtat
                if afficheEtat {
                    etatSortieButton.etat = configuration.etatSortie!
                    etatSortieButton.displayEtatButton(placement) }
                
                propreteSortieButton.isHidden = !afficheProprete
                if afficheProprete {
                    propreteSortieButton.proprete = configuration.propreteSortie!
                    propreteSortieButton.displayPropreteButton(placement)}
                
                fonctionnelSortieButton.isHidden = !afficheFonctionnel
                if afficheFonctionnel {
                    fonctionnelSortieButton.fonctionnel = configuration.fonctionnelSortie!
                    fonctionnelSortieButton.displayFonctionnelButton(placement)}
                
                bouttonSortieStack.isHidden = false
            }
            
        }
        
        
        observationsSortieStack.isHidden = true
        observationsSortieLabel.isHidden = true
        
        if let observationSortie = configuration.observationsSortie,
           observationSortie != "" && observationSortie != " " {
            observationsSortieLabel.text = observationSortie
            observationsSortieStack.isHidden = false
            observationsSortieLabel.isHidden = false
            print (configuration.equipement, "Taille Demasquage observation Sortie")
        }
        
        sortieStack.isHidden = nExemplaireSortieStack.isHidden && bouttonSortieStack.isHidden && observationsSortieStack.isHidden
    
        if !sortieStack.isHidden {
            sortieStack.layer.backgroundColor = UIColor.fondCouleurSortie.cgColor
            if !entreeStack.isHidden {
                 entreeStack.layer.backgroundColor = UIColor.fondCouleurEntree.cgColor
             }
         }
        
    
        
        
        
        
    }
    
}
