//
//  StockLookupView.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import SwiftUI

struct StockLookupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stockName: [String]
    @StateObject var StockLookupVM = StockLookupViewModel()
    @StateObject var watchlistVM = WatchlistViewModel()
    @State var currentWatchlist: Watchlist
    @State private var searchText = ""
    @State private var filteredStockList: [StockResults] = []
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(filteredStockList) { stock in
                                VStack (alignment: .leading) {
                                    HStack {
                                        Text(stock.symbol)
                                            .bold()
                                        Spacer()
                                        Text(stock.type)
                                            .foregroundColor(.gray)
                                    }
                                    Text(stock.description)
                                    Divider()
                                }
                                .onTapGesture {
                                    stockName.append(stock.displaySymbol)
                                    currentWatchlist.stocksList.append(stock.displaySymbol)
                                    if currentWatchlist.id != nil {
                                        Task {
                                            await watchlistVM.saveWatchlist(watchlist: currentWatchlist)
                                        }
                                    }
                                    dismiss()
                                }
                                .padding(.horizontal)
                            }
                            .onChange(of: searchText, perform: { text in
                                if !text.isEmpty {
                                    filteredStockList = StockLookupVM.stockList.filter{$0.description.localizedCaseInsensitiveContains(searchText) || $0.symbol.localizedCaseInsensitiveContains(searchText)}
                                } else {
                                    filteredStockList = StockLookupVM.stockList
                                }
                            })
                        }
                        .searchable(text: $searchText)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Text("Displaying \(filteredStockList.count) of \(StockLookupVM.stockList.count) returned investments")
                            .font(.caption)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10.0)
                    .padding(.bottom, 20.0)
                    .background(.ultraThinMaterial.opacity(0.9))
                }
                .ignoresSafeArea()
                
                if StockLookupVM.isLoading == true {
                    ProgressView()
                        .scaleEffect(4)
                        .tint(Color("AccentColor"))
                }
            }
            .navigationTitle("Add Investments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await StockLookupVM.getData()
                filteredStockList = StockLookupVM.stockList
            }
        }
    }
}

struct StockLookupView_Previews: PreviewProvider {
    static var previews: some View {
        StockLookupView(stockName: .constant([String()]), currentWatchlist: Watchlist())
            .environmentObject(StockViewModel())
            .environmentObject(WatchlistViewModel())
    }
}
