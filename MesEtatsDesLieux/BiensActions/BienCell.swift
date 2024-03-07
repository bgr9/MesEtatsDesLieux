//
//  BiensCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 03/02/2023.
//

import Foundation
import UIKit

// MARK: CollectionViewCell Bien

class BienCollectionViewCell: UICollectionViewListCell {
    
    var bien: Bien!
    
  
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        let newConfiguration = BienContentConfiguration(bien: bien  ).updated(for: state)
        contentConfiguration = newConfiguration
    }
    
}

// MARK: ContentConfiguration Bien
struct BienContentConfiguration: UIContentConfiguration, Hashable
{
    static func == (lhs: BienContentConfiguration, rhs: BienContentConfiguration) -> Bool {
        return (lhs.bien == rhs.bien)
    }
    
    var bien: Bien
   
    
    func makeContentView() -> UIView & UIContentView {
        return BienContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
        guard let state = state as? UICellConfigurationState else { return self }
     
        return self
    }
}

// MARK: ContentView Bien
class BienContentView: UIView, UIContentView {
    
 //   var containerView: UIView = UIView()
    private static let hauteurItem: CGFloat = 40
    
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
    
    private lazy var bienStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.axis = .horizontal
      stackView.alignment = .center
      stackView.distribution = .fillEqually
      stackView.spacing = 10
      stackView.backgroundColor = .systemBackground
      return stackView
    }()
    
    lazy var bienLabel: UILabel = {
      let label = UILabel()
      label.itemLabel()
      label.numberOfLines = 3
      label.font = .preferredFont(forTextStyle: .title2)
      label.backgroundColor = .quaternarySystemFill
      return label
    }()
    
    private var currentConfiguration: BienContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
        guard let newConfiguration = newValue as? BienContentConfiguration else { return }
        self.apply(configuration: newConfiguration)
        }
    }
    
    init (configuration: BienContentConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        
        loadView()
        
        apply(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



private extension BienContentView {
    private func loadView() {
        
        addSubview(pageStackView)
        var detailConstraint: [NSLayoutConstraint]
        
        pageStackView.addArrangedSubview(bienStackView)
        bienStackView.addArrangedSubview(bienLabel)
        detailConstraint = [
            bienStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
            bienLabel.heightAnchor.constraint(equalToConstant: BienContentView.hauteurItem * 2),
            self.heightAnchor.constraint(equalToConstant: 80.0),
        ]
            
       
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
       
        pageStackView.centerXAnchor.constraint(equalTo: readableContentGuide.centerXAnchor),
        pageStackView.centerYAnchor.constraint(equalTo: readableContentGuide.centerYAnchor),
            
        pageStackView.heightAnchor.constraint(equalTo: readableContentGuide.heightAnchor),
        pageStackView.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor)
        ])
        NSLayoutConstraint.activate(detailConstraint)
        
        self.translatesAutoresizingMaskIntoConstraints = true
    }
 
    
    private func apply(configuration: BienContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        bienLabel.text = configuration.bien.nomBien
        
    }
    
    
  
}

