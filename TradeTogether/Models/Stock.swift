//
//  Stock.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import Foundation

struct Stock: Codable, Identifiable {
    let id = UUID().uuidString
    var c = 0.00 // current price
    var d = 0.00 // change in $
    var dp = 0.00 // percent change
    var h = 0.00 // high price today
    var l = 0.00 // low price today
    var o = 0.00 // opening price today
    var pc = 0.00 //previous close price
    var t = 0 // total volume traded??
    
    private enum CodingKeys: CodingKey {
        case c, d, dp, h, l, o, pc, t
    }
}

struct AdvancedStock: Codable, Identifiable {
    let id = UUID().uuidString
    var metric: AdvancedStockMetrics
    
    enum CodingKeys: CodingKey {
        case metric
    }
}

struct AdvancedStockMetrics: Codable {
    var assetTurnoverAnnual: Double?
    var beta: Double?
    var dividendYieldIndicatedAnnual: Double?
    var enterpriseValue: Double?
    var epsAnnual: Double?
    var grossMarginAnnual: Double?
    var netProfitMarginAnnual: Double?
    var operatingMarginAnnual: Double?
    var peAnnual: Double?
    var yearToDatePriceReturnDaily: Double?
}
