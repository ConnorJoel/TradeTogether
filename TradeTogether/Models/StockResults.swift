//
//  StockResults.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import Foundation

struct StockResults: Codable, Identifiable {
    let id = UUID().uuidString
    var description = ""
    var displaySymbol = ""
    var figi = ""
    var symbol = ""
    var type = ""
}
