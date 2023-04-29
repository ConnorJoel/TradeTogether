//
//  TradeTogetherApp.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct TradeTogetherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var watchlistVM = WatchlistViewModel()
    @StateObject var stockVM = StockViewModel()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(watchlistVM)
                .environmentObject(stockVM)
        }
    }
}
