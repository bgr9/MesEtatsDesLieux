//
//  Tools.swift
//  MesEtatsDesLieux
//
//  Created by B Grossin on 05/12/2022.
//

import Foundation

// MARK: Formattage Date

// formatage date JJ/MM/AAAA HH:MM
// Pour formater en chaine dateFormatter.string(from: Date())
// Pour formater en date   dateFormatter.date(from:"JJ/MM/AAAA HH:MM")
// Date du jour à 00:00 : let minuitAujourdhui = Calendar.current.startOfDay(for: Date())
var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.locale = Locale(identifier: "fr_FR")
    return dateFormatter
}()

var dateFormatterSecondes: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
    dateFormatter.locale = Locale(identifier: "fr_FR")
    return dateFormatter
}()

func chaineDateOrdonnee () -> String {
    let chaine = "\(dateFormatterSecondes.string(from: Date()))".replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "")
  //  let chaine = "220220231620"

    let pindex1 = chaine.index (chaine.startIndex, offsetBy: 2)
    let pindex2 = chaine.index (chaine.startIndex, offsetBy: 4)
    let pindex3 = chaine.index (chaine.startIndex, offsetBy: 8)
    let pindex4 = chaine.index (chaine.startIndex, offsetBy: 10)
    let pindex5 = chaine.index (chaine.startIndex, offsetBy: 12)
    let pindex6 = chaine.index (chaine.startIndex, offsetBy: 14)

    let pannee = chaine[pindex2..<pindex3]
    let pmois = chaine[pindex1..<pindex2]
    let pjours = chaine[..<pindex1]
    let pheure = chaine[pindex3..<pindex4]
    let pmin = chaine[pindex4..<pindex5]
    let psec = chaine[pindex5..<pindex6]

    return String(pannee + pmois + pjours + pheure + pmin + psec)
}

// formatage date JJ/MM/AAAA
// Pour formater en chaine dateDayFormatter.string(from: Date())
// Pour formater en date   dateDayFormatter.date(from:"JJ/MM/AAAA")
// Date du jour à 00:00 : let minuitAujourdhui = Calendar.current.startOfDay(for: Date())
var dateDayFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale(identifier: "fr_FR")
    return dateFormatter
}()


// MARK: Repertoire sauvegarde
let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

// static let archiveURL = documentsDirectory.appendingPathComponent("TypesLieux").appendingPathExtension("plist")


