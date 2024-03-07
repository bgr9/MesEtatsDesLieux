//
//  ChoseController.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 16/12/2022.
//

import Foundation

protocol ChoseController {
    associatedtype Chose
    
    var archiveURL: URL { get set }
    func chargeChoseBase() -> [Chose]
    
}

func chargeChoses<Specific: ChoseController>() -> [Specific]? {
    guard let choses = try? Data(contentsOf: <Specific>.archiveURL) else { return nil}
   let propertyListDecoder = PropertyListDecoder()
   return try? propertyListDecoder.decode([Categorie].self, from: categories)


 func chargeChoses<Chose: ChoseController>() -> [Chose]? {
     guard let choses = try? Data(contentsOf: self.archiveURL) else { return nil}
    let propertyListDecoder = PropertyListDecoder()
    return try? propertyListDecoder.decode([Categorie].self, from: categories)
}

static func sauveCategories (_ categories: [Categorie]) {
    let propertyListEncoder = PropertyListEncoder()
    let categories = try? propertyListEncoder.encode(categories)
    try? categories?.write(to: archiveURL, options: .noFileProtection)
}

