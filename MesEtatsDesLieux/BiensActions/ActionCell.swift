//
//  BiensCell.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 03/02/2023.
//

import Foundation
import UIKit

// MARK: CollectionViewCell Action

class ActionCollectionViewCell: UICollectionViewListCell {
    
    var actionBien: ActionBien!
    
    override func updateConfiguration ( using state: UICellConfigurationState) {
        
        let newConfiguration = ActionContentConfiguration(actionBien: actionBien ).updated(for: state)
        contentConfiguration = newConfiguration
    }
    
}

// MARK: ContentConfiguration Action
struct ActionContentConfiguration: UIContentConfiguration, Hashable
{
    static func == (lhs: ActionContentConfiguration, rhs: ActionContentConfiguration) -> Bool {
        return (lhs.actionBien == rhs.actionBien)
    }
    
    var actionBien: ActionBien
    
    func makeContentView() -> UIView & UIContentView {
        return ActionContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
        guard let state = state as? UICellConfigurationState else { return self }
        
        return self
    }
}

// MARK: ContentView Action

class ActionContentView: UIView, UIContentView {
    
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
    
   private lazy var buttonStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.axis = .horizontal
      stackView.alignment = .center
      stackView.distribution = .fillEqually
      stackView.spacing = 10
      stackView.backgroundColor = .systemBackground
      return stackView
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var actionButtonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private var currentConfiguration: ActionContentConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
        guard let newConfiguration = newValue as? ActionContentConfiguration else { return }
        self.apply(configuration: newConfiguration)
        }
    }
    
    init (configuration: ActionContentConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        
        loadView()
        
        apply(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



private extension ActionContentView {
    private func loadView() {
        
   
        addSubview(pageStackView)
        var detailConstraint: [NSLayoutConstraint]
     
        
        pageStackView.addArrangedSubview(buttonStackView)
        buttonStackView.addArrangedSubview(actionButton)
    //    buttonStackView.addArrangedSubview(actionButtonLabel)
        
        detailConstraint = [
            buttonStackView.widthAnchor.constraint(equalTo: pageStackView.widthAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: ActionContentView.hauteurItem * 2), 
            self.heightAnchor.constraint(equalToConstant: 60.0),
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
 
    
    private func apply(configuration: ActionContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration
        
        
        configActionButton(actionButton, actionBien: configuration.actionBien)
   //     actionButtonLabel.text = configuration.actionBien.typeAction.description
        
    }
    
    
    private func configActionButton(_ button: UIButton, actionBien: ActionBien ) {
        
        var config: UIButton.Configuration
        
        let statutAction = actionBien.statutAction
        let typeAction = actionBien.typeAction
        print("---> Config boutton", typeAction , " = ", statutAction)
        switch statutAction {
        case .aFaire:
            config = UIButton.Configuration.filled()
            config.subtitle = statutAction.description
        case .enCours:
            config = UIButton.Configuration.tinted()
            config.baseBackgroundColor = .systemGreen
            config.subtitle = statutAction.description + " " + actionBien.descStatutActionCalc()
        case .termine:
            config = UIButton.Configuration.plain()
            config.subtitle = statutAction.description
        case .actif:
            config = UIButton.Configuration.tinted()
            config.baseBackgroundColor = .lightGray
        case .inactif:
            config = UIButton.Configuration.tinted()
            config.baseBackgroundColor = .lightText
            config.subtitle = statutAction.description
            
        default:
            config = UIButton.Configuration.gray()
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        
        config.buttonSize = .medium
        config.cornerStyle = .medium
        
        config.titleTextAttributesTransformer =
        UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            return outgoing
        }
        config.image = UIImage(systemName: "chevron.right")
        config.imagePadding = 10
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        config.title = typeAction.description
        config.subtitle = statutAction.description + " " + actionBien.descStatutActionCalc()
        
        button.configuration = config
        // Le click est géré par la sélection de la cellule, il n'y a pas d'action sur le bouton
        button.isUserInteractionEnabled = false
        if statutAction == .inactif {
            button.isEnabled = false
        } else {
            button.isEnabled = true
        }
   }
}

