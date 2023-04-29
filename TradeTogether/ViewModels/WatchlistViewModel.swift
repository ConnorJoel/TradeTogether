//
//  WatchlistViewModel.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/24/23.
//

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class WatchlistViewModel: ObservableObject {
    @Published var watchlist = Watchlist()
    @Published var tickerData: [String:String] = [:]
    
    func getTickerData(watchlist: [String]) async {
        for ticker in watchlist {
            let urlString = "https://finnhub.io/api/v1/quote?symbol=\(ticker)&token=ch2mqi1r01qs9g9us14gch2mqi1r01qs9g9us150"
            
            print("🕸️ We are accessing the URL \(urlString)")
            guard let url = URL(string: urlString) else {
                print("🛑 ERROR: Could not create a URL from \(urlString)")
                return
            }
            do {
                let(data, _) = try await URLSession.shared.data(from: url)
                do {
                    //change
                    let stock = try JSONDecoder().decode(Stock.self, from: data)
                    tickerData[ticker] = String(round(stock.dp*100)/100)
                    print("JSON returned data for \(stock.id)")
                } catch {
                    print("🛑 JSON ERROR: Could not get data from \(urlString). \(error.localizedDescription)")
                    tickerData[ticker] = "N/A"
                }
            } catch {
                print("🛑 JSON ERROR: Could not get data from \(urlString)")
                return
            }
        }
    }
    
    func saveWatchlist(watchlist: Watchlist) async -> Bool {
        let db = Firestore.firestore()
        if watchlist.isPublic == true {print("👨‍👩‍👧‍👦 Attempting to save public watchlist")} else {print("🔒 Attempting to save private watchlist")}
        if let id = watchlist.id {
            do {
                try await db.collection("watchlists").document(id).setData(watchlist.dictionary)
                print("✅ Data updated successfully!")
                return true
            } catch {
                print("🛑 ERROR: Could not updated data 'watchlists' \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                let documentRef = try await db.collection("watchlists").addDocument(data: watchlist.dictionary)
                self.watchlist = watchlist
                self.watchlist.id = documentRef.documentID
                print("✅ Data added successfully!")
                return true
            } catch {
                print("🛑 ERROR: Could not create a new watchlist 'watchlists' \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func deleteWatchlist(watchlist: Watchlist) async -> Bool {
        let db = Firestore.firestore()
        guard let watchlistID = watchlist.id else {
            print("🛑 ERROR: watchlist.id = \(watchlist.id ?? "nil")")
            return false
        }
        do {
            print("Deleting '\(watchlist.name)' from 'watchlists'")
            let _ = try await db.collection("watchlists").document(watchlistID).delete()
            print("🗑️ Document successfully deleted")
            return true
        } catch {
            print("🛑 ERROR: removing document \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteInvestment(watchlist: Watchlist, stock: String) async -> Bool {
        let db = Firestore.firestore()
        guard let watchlistID = watchlist.id else {
            print("🛑 ERROR: watchlist.id = \(watchlist.id ?? "nil")")
            return false
        }
        do {
            print("Deleting '\(stock)' from '\(watchlist.name)' in 'watchlists")
            var tempWatchlist = watchlist
            tempWatchlist.stocksList.removeAll {$0 == stock}
            try await db.collection("watchlists").document(watchlistID).setData(tempWatchlist.dictionary)
            print("🗑️ Document successfully deleted")
            return true
        } catch {
            print("🛑 ERROR: removing '\(stock)' from '\(watchlist.name)'. \(error.localizedDescription)")
            return false
        }
    }
}
