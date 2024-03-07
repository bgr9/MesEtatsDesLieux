//
//  UICollectionViewDiffableDataSource+ViewModel.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 06/12/2022.
//

import Foundation
import UIKit

extension UICollectionViewDiffableDataSource {
    func applySnapshotUsing ( sectionIDs: [ SectionIdentifierType], itemsBySection: [SectionIdentifierType: [ItemIdentifierType]], sectionRetainsIfEmpry: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        
        applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection, animatingDifferences: true, sectionRetainsIfEmpry: sectionRetainsIfEmpry)
        
    }
    func applySnapshotUsing ( sectionIDs: [ SectionIdentifierType], itemsBySection: [SectionIdentifierType: [ItemIdentifierType]],animatingDifferences: Bool, sectionRetainsIfEmpry: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        for sectionID in sectionIDs {
            guard let sectionItems = itemsBySection[sectionID],
                  sectionItems.count > 0 || sectionRetainsIfEmpry.contains(sectionID) else { continue}
            snapshot.appendSections([sectionID])
            snapshot.appendItems(sectionItems, toSection: sectionID)
            snapshot.reloadItems(sectionItems)
        }
        self.apply(snapshot, animatingDifferences: animatingDifferences)
        
        
    }
}


extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Ajouter",
                         cancelTitle:String? = "Annuler",
                         inputPlaceholder:String? = nil,
                         inputDefaultValue: String? = nil,
                         indexPath: IndexPath? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ nomChange: String? , _ nomActuel: String? , _ indexPath: IndexPath? ) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
            textField.text = inputDefaultValue
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil, nil, nil)
                return
            }
            actionHandler?(textField.text , inputDefaultValue, indexPath)
        }
                                     ))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}
    

