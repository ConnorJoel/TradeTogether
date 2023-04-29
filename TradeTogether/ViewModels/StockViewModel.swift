//
//  StockViewModel.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import Foundation

@MainActor
class StockViewModel: ObservableObject {
    //TODO: Request individual stock quote data
    @Published var currentStock = Stock()
    @Published var currentStockAdvanced = AdvancedStock(metric: AdvancedStockMetrics())
    @Published var isLoading = false
    @Published var advancedIsLoading = false
    
    @Published var stockSymbol = ""
    
    func getData() async {
        isLoading = true
        
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(stockSymbol)&token=ch2mqi1r01qs9g9us14gch2mqi1r01qs9g9us150"
        
        print("🕸️ We are accessing the URL \(urlString)")
        guard let url = URL(string: urlString) else {
            print("🛑 ERROR: Could not create a URL from \(urlString)")
            isLoading = false
            return
        }
        do {
            let(data, _) = try await URLSession.shared.data(from: url)
            do {
                //change
                let stock = try JSONDecoder().decode(Stock.self, from: data)
                print("JSON returned data for \(stockSymbol)")
                currentStock = stock
                //change ^^
                isLoading = false
            } catch {
                print("🛑 JSON ERROR: Could not get data from \(urlString). \(error.localizedDescription)")
                isLoading = false
            }
        } catch {
            print("🛑 JSON ERROR: Could not get data from \(urlString)")
            isLoading = false
        }
    }
    
    func getAdvancedData() async {
        advancedIsLoading = true
        
        let urlString = "https://finnhub.io/api/v1/stock/metric?symbol=\(stockSymbol)&metric=all&token=ch2mqi1r01qs9g9us14gch2mqi1r01qs9g9us150"
        
        print("🕸️ We are accessing the URL \(urlString)")
        guard let url = URL(string: urlString) else {
            print("🛑 ERROR: Could not create a URL from \(urlString)")
            advancedIsLoading = false
            return
        }
        do {
            let(data, _) = try await URLSession.shared.data(from: url)
            do {
                //change
                let advancedStock = try JSONDecoder().decode(AdvancedStock.self, from: data)
                print("JSON returned advanced data for \(stockSymbol)")
                currentStockAdvanced = advancedStock
                //change ^^
                advancedIsLoading = false
            } catch {
                print("🛑 JSON ERROR: Could not get data from \(urlString). \(error.localizedDescription)")
                advancedIsLoading = false
            }
        } catch {
            print("🛑 JSON ERROR: Could not get data from \(urlString)")
            advancedIsLoading = false
        }
    }
}
