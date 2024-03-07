//
//  MiseEnPageView.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 10/02/2023.
//

import UIKit


protocol MiseEnPageViewDelegate: AnyObject {
    func miseEnPageView(_ miseEnPageView: MiseEnPageView, itemMiseEnPage: ItemMiseEnPage)
}

class MiseEnPageView: UIView {
  
    var delegate: MiseEnPageViewDelegate?
    var idEmetteur: UUID!
  
  
  private static let hauteurItem: CGFloat = 60
  
  private lazy var pageStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 10
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
  
  private lazy var statutStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
  
  lazy var statutLabel: UILabel = {
    let label = UILabel()
    label.itemLabel()
    label.font = .preferredFont(forTextStyle: .title2)
    label.backgroundColor = .quaternarySystemFill
    return label
  }()
  
  
  private lazy var enTeteStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
  
  private lazy var logoView: UIView = {
    let logoview = UIView()
    logoview.translatesAutoresizingMaskIntoConstraints = false
    return logoview
  }()
  
  lazy var logoLabel: UILabel = {
    let label = UILabel()
    label.itemModifiableLabel()
    return label
  }()
 
  // UItilisé pour le retour sur l'affichage
  lazy var logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.isOpaque = false
    return imageView
  }()
  
  
  
  lazy var adresseLabel: UILabel = {
    let label = UILabel()
    label.itemModifiableLabel()
    
    return label
  }()
  
  private lazy var corpsConstatStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
  
  lazy var corpsConstatLabel: UILabel = {
    let label = UILabel()
    label.itemLabel()
    return label
  }()
  
  private lazy var clauseContractuelleBlocStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
      stackView.distribution = .fill
    stackView.spacing = 5
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
    
lazy var clauseContractuelEntreeLibelleLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.font = label.font.withSize(12)
    label.text = clauseContractuelleEntreeLibelle
    label.numberOfLines = 1
    label.textAlignment = .left
    
    return label
  }()
    
lazy var clauseContractuelEntreeLabel: UILabel = {
    let label = UILabel()
    label.itemModifiableLabel()
    return label
  }()

lazy var clauseContractuelSortieLibelleLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.font = label.font.withSize(12)
    label.text = clauseContractuelleEntreeLibelle
    label.numberOfLines = 1
    label.textAlignment = .left
    label.text = clauseContractuelleSortieLibelle
   
    return label
  }()
    
lazy var clauseContractuelSortieLabel: UILabel = {
        let label = UILabel()
        label.itemModifiableLabel()
        return label
      }()
  
  
  
  private lazy var signaturesBlocStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
   lazy var signatureBailleurLabel: UILabel = {
    let label = UILabel()
    label.itemModifiableLabel()
    return label
  }()
   lazy var signatureLocataireLabel: UILabel = {
    let label = UILabel()
    label.itemModifiableLabel()
    return label
  }()
  
  
  private lazy var piedPageStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    stackView.backgroundColor = .systemBackground
    return stackView
  }()
   lazy var piedPageLabel: UILabel = {
    let label = UILabel()
    label.itemModifiableLabel()
    return label
  }()
  init() {
    
    super.init(frame: CGRect.zero)
    backgroundColor = .secondarySystemBackground
    
    addSubview(pageStackView)
    
    pageStackView.addArrangedSubview(statutStackView)
    statutStackView.addArrangedSubview(statutLabel)
    
    pageStackView.addArrangedSubview(enTeteStackView)
    
    // Creation de la view Logo
    logoView.addSubview(logoLabel)
    logoView.addSubview(logoImageView)
    
    enTeteStackView.addArrangedSubview(logoView)
    enTeteStackView.addArrangedSubview(adresseLabel)
    
    pageStackView.addArrangedSubview(corpsConstatStackView)
    corpsConstatStackView.addArrangedSubview(corpsConstatLabel)
    
    pageStackView.addArrangedSubview(clauseContractuelleBlocStackView)
    
    clauseContractuelleBlocStackView.addArrangedSubview(clauseContractuelEntreeLibelleLabel)
    clauseContractuelleBlocStackView.addArrangedSubview(clauseContractuelEntreeLabel)
    clauseContractuelleBlocStackView.addArrangedSubview(clauseContractuelSortieLibelleLabel)
    clauseContractuelleBlocStackView.addArrangedSubview(clauseContractuelSortieLabel)
      
    pageStackView.addArrangedSubview(signaturesBlocStackView)
    signaturesBlocStackView.addArrangedSubview(signatureBailleurLabel)
    signaturesBlocStackView.addArrangedSubview(signatureLocataireLabel)
    
    pageStackView.addArrangedSubview(piedPageStackView)
    piedPageStackView.addArrangedSubview(piedPageLabel)
    
    self.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      
 //     self.heightAnchor.constraint(equalTo: pageStackView.heightAnchor),
      
      pageStackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
      pageStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
      pageStackView.heightAnchor.constraint(equalTo: readableContentGuide.heightAnchor),
      pageStackView.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor),
      
 //     pageStackView.topAnchor.constraint(equalTo: topAnchor, constant: 100),
   //   pageStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
  //    pageStackView.heightAnchor.constraint(equalTo:  safeAreaLayoutGuide.heightAnchor),
      /*
       stackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
       stackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
       stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
       stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
       stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
       
       */
      
      statutStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
      enTeteStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
      corpsConstatStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
      
      clauseContractuelleBlocStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
      clauseContractuelleBlocStackView.heightAnchor.constraint(equalToConstant:
                                                                // MiseEnPageView.hauteurItem * 3
                                                               195
                                                              ),
      
      
      signaturesBlocStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
      piedPageStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
      
      statutLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem * 2),
      
      logoView.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      logoLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      logoLabel.widthAnchor.constraint(equalTo: logoView.widthAnchor),
      logoLabel.centerXAnchor.constraint(equalTo: logoView.centerXAnchor),
      logoLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor),
      logoImageView.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      logoImageView.widthAnchor.constraint(equalTo: logoView.widthAnchor),
      logoImageView.centerXAnchor.constraint(equalTo: logoView.centerXAnchor),
      logoImageView.centerYAnchor.constraint(equalTo: logoView.centerYAnchor),
      
      adresseLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      corpsConstatLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem * 2),
      
      clauseContractuelEntreeLibelleLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem/2),
      clauseContractuelEntreeLibelleLabel.leadingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.leadingAnchor),
      clauseContractuelEntreeLibelleLabel.trailingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.trailingAnchor),
      
      clauseContractuelEntreeLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      clauseContractuelEntreeLabel.leadingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.leadingAnchor),
      clauseContractuelEntreeLabel.trailingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.trailingAnchor),
      
      clauseContractuelSortieLibelleLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem/2),
      clauseContractuelSortieLibelleLabel.leadingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.leadingAnchor),
      clauseContractuelSortieLibelleLabel.trailingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.trailingAnchor),
      
      clauseContractuelSortieLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      clauseContractuelSortieLabel.leadingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.leadingAnchor),
      clauseContractuelSortieLabel.trailingAnchor.constraint(equalTo: clauseContractuelleBlocStackView.trailingAnchor),
      
      signatureBailleurLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      signatureLocataireLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      piedPageLabel.heightAnchor.constraint(equalToConstant: MiseEnPageView.hauteurItem),
      
      
    ])
    
    
    let tapGestureRecognizerlogoLabel               = UITapGestureRecognizer (target: self, action: #selector(didTaplogoLabel(_:)))
    let tapGestureRecognizeradresseLabel            = UITapGestureRecognizer (target: self, action: #selector(didTapadresseLabel(_:)))
    let tapGestureRecognizerclauseContractuelEntreeLabel  = UITapGestureRecognizer (target: self, action: #selector(didTapclauseContractuelEntreeLabel(_:)))
    let tapGestureRecognizerclauseContractuelSortieLabel  = UITapGestureRecognizer (target: self, action: #selector(didTapclauseContractuelSortieLabel(_:)))
    let tapGestureRecognizersignatureBailleurLabel  = UITapGestureRecognizer (target: self, action: #selector(didTapsignatureBailleurLabel(_:)))
    let tapGestureRecognizersignatureLocataireLabel = UITapGestureRecognizer (target: self, action: #selector(didTapsignatureLocataireLabel(_:)))
    let tapGestureRecognizerpiedPageLabel           = UITapGestureRecognizer (target: self, action: #selector(didTappiedPageLabel(_:)))
    
    
    logoView.isUserInteractionEnabled = true
    adresseLabel.isUserInteractionEnabled = true
    clauseContractuelEntreeLabel.isUserInteractionEnabled = true
    clauseContractuelSortieLabel.isUserInteractionEnabled = true
    signatureBailleurLabel.isUserInteractionEnabled = true
    signatureLocataireLabel.isUserInteractionEnabled = true
    piedPageLabel.isUserInteractionEnabled = true
    
    logoView.addGestureRecognizer(tapGestureRecognizerlogoLabel)
    adresseLabel.addGestureRecognizer(tapGestureRecognizeradresseLabel)
    clauseContractuelEntreeLabel.addGestureRecognizer(tapGestureRecognizerclauseContractuelEntreeLabel)
    clauseContractuelSortieLabel.addGestureRecognizer(tapGestureRecognizerclauseContractuelSortieLabel)
    signatureBailleurLabel.addGestureRecognizer(tapGestureRecognizersignatureBailleurLabel)
    signatureLocataireLabel.addGestureRecognizer(tapGestureRecognizersignatureLocataireLabel)
    piedPageLabel.addGestureRecognizer(tapGestureRecognizerpiedPageLabel)
    
    
  }
  
  @IBAction func didTaplogoLabel(_ sender: UITapGestureRecognizer){
    print(" logoLabel              ")
    delegate?.miseEnPageView(self, itemMiseEnPage: .logo)
  }
  @IBAction func didTapadresseLabel(_ sender: UITapGestureRecognizer){
    print(" adresseLabel           ")
      delegate?.miseEnPageView(self, itemMiseEnPage: .adresse)
  }
  @IBAction func didTapclauseContractuelEntreeLabel(_ sender: UITapGestureRecognizer){
      delegate?.miseEnPageView(self, itemMiseEnPage: .clauseContractuelleEntree)
      
  }
  @IBAction func didTapclauseContractuelSortieLabel(_ sender: UITapGestureRecognizer){
      delegate?.miseEnPageView(self, itemMiseEnPage: .clauseContractuelleSortie)
  }

  @IBAction func didTapsignatureBailleurLabel(_ sender: UITapGestureRecognizer){
      delegate?.miseEnPageView(self, itemMiseEnPage: .signatures)
      
  }
  @IBAction func didTapsignatureLocataireLabel(_ sender: UITapGestureRecognizer){
      delegate?.miseEnPageView(self, itemMiseEnPage: .signatures)
      
  }
  @IBAction func didTappiedPageLabel(_ sender: UITapGestureRecognizer){
      delegate?.miseEnPageView(self, itemMiseEnPage: .piedPage)
      
  }
  
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    //    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
}


/*
 
 NSLayoutConstraint.activate([
   stackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
   stackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
   stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
   stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
   stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),

   informationStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
   checkoutButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
 
 
 
 stackView.addArrangedSubview(informationStackView)

 informationStackView.addArrangedSubview(costLabel)
 informationStackView.addArrangedSubview(shippingSpeedButton)
 
 
 informationStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
 
 
 
 enTeteStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 titreStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 bailleurLocataireStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 typeBienStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 itemsStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 clauseContractuelleBlocStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 signaturesBlocStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 piedPageStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 
 
 enTeteStackView
 titreStackView
 bailleurLocataireStackView
 typeBienStackView
 itemsStackView
 clauseContractuelleBlocStackView
 signaturesBlocStackView
 piedPageStackView
 
 
 
 logoLabel.text = "logoLabel"
 adresseLabel.text = " adresseLabel"
 titreLabel.text = " titreLabel"
 bailleurLabel.text = " bailleurLabel"
 locataireLabel.text = " locataireLabel"
 typeBienLabel.text = " typeBienLabel"
 compteurLabel.text = " compteurLabel"
 entretienLabel.text = " entretienLabel"
 clefLabel.text = " clefLabel"
 fournitureLabel.text = " fournitureLabel"
 pieceLabel.text = " pieceLabel"
 clauseContractuelLabel.text = " clauseContractuelLabel"
 signatureBailleurLabel.text = " signatureBailleurLabel"
 signatureLocataireLabel.text = " signatureLocataireLabel"
 piedPageLabel.text = " piedPageLabel"
        
        
 logoLabel
 adresseLabel
 titreLabel
 bailleurLabel
 locataireLabel
 typeBienLabel
 compteurLabel
 entretienLabel
 clefLabel
 fournitureLabel
 pieceLabel
 clauseContractuelLabel
 signatureBailleurLabel
 signatureLocataireLabel
 piedPageLabel
        
 logoLabel.heightAnchor.constraint(equalTo: 40),
 adresseLabel.heightAnchor.constraint(equalTo: 40),
 titreLabel.heightAnchor.constraint(equalTo: 40),
 bailleurLabel.heightAnchor.constraint(equalTo: 40),
 locataireLabel.heightAnchor.constraint(equalTo: 40),
 typeBienLabel.heightAnchor.constraint(equalTo: 40),
 compteurLabel.heightAnchor.constraint(equalTo: 40),
 entretienLabel.heightAnchor.constraint(equalTo: 40),
 clefLabel.heightAnchor.constraint(equalTo: 40),
 fournitureLabel.heightAnchor.constraint(equalTo: 40),
 pieceLabel.heightAnchor.constraint(equalTo: 40),
 clauseContractuelLabel.heightAnchor.constraint(equalTo: 40),
 signatureBailleurLabel.heightAnchor.constraint(equalTo: 40),
 signatureLocataireLabel.heightAnchor.constraint(equalTo: 40),
 piedPageLabel.heightAnchor.constraint(equalTo: 40),
       
        
        
        
 pageStackView.heightAnchor.constraint(equalTo:  safeAreaLayoutGuide.heightAnchor),
 
 enTeteStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
 
        
        
        
        
        
        
        
        
        
        
        stackView

        
        
        
        
        
      stackView.addArrangedSubview(informationStackView)
 */

