//
//  StockLookupViewModel.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import Foundation

@MainActor
class StockLookupViewModel: ObservableObject {
    @Published var stockList: [StockResults] = []
    @Published var isLoading = false
    
    func getData() async {
        isLoading = true
        
        let urlString = "https://finnhub.io/api/v1/stock/symbol?exchange=US&token=ch2mqi1r01qs9g9us14gch2mqi1r01qs9g9us150"
        
        print("🕸️ We are accessing the URL \(urlString)")
        guard let url = URL(string: urlString) else {
            print("🛑 ERROR: Could not create a URL from \(urlString)")
            isLoading = false
            return
        }
        do {
            let(data, _) = try await URLSession.shared.data(from: url)
            do {
                let stockList = try JSONDecoder().decode([StockResults].self, from: data)
                print("JSON returned \(stockList.count) various investments")
                self.stockList = self.stockList + stockList
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
}
