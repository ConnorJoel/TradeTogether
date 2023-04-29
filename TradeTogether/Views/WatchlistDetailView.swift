//
//  WatchlistDetailView.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct WatchlistDetailView: View {
    enum Field {
        case title, description
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var watchlistVM: WatchlistViewModel
    @EnvironmentObject var stockVM: StockViewModel
    
    @State var selectedWatchlist: Watchlist
    @State private var stockColor = Color(.black)
    @State private var stockSearch = ""
    @State private var searchSheetIsPresented = false
    @State private var showPublicAlert = false
    @State private var alertMessage = ""
    @State private var stockDetailIsPresented = false
    @State private var selectedStock = ""
    
    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack {
            TextField("Watchlist Name", text: $selectedWatchlist.name)
                .font(.title)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.1), lineWidth: 1)
                }
                .padding([.top, .leading, .trailing])
                .disabled(selectedWatchlist.creator != Auth.auth().currentUser?.email && selectedWatchlist.id != nil)
                .focused($focusField, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    focusField = .description
                }
            
            TextField("Watchlist description (optional)", text: $selectedWatchlist.listDescription)
                .font(.caption)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .disabled(selectedWatchlist.creator != Auth.auth().currentUser?.email && selectedWatchlist.id != nil)
                .submitLabel(.done)
                .focused($focusField, equals: .description)
                .onSubmit {
                    focusField = nil
                }
            
            if selectedWatchlist.creator != Auth.auth().currentUser?.email && selectedWatchlist.id != nil {
                Text("Created By: \(selectedWatchlist.creator)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Divider()
            //Message to display for empty watchlists
            if selectedWatchlist.id == nil && selectedWatchlist.stocksList.count == 0 {
                VStack {
                    Spacer()
                    Text("You have not added any investments to this watchlist. \nWhen you add investments they will appear here.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25.0)
                    Spacer()
                }
            } else {
                List {
                    ForEach(selectedWatchlist.stocksList, id: \.self) { stock in
                        HStack {
                            Text(stock)
                                .bold()
                            Spacer()
                            if watchlistVM.tickerData[stock] == "N/A" {
                                Text("N/A")
                                    .bold()
                                    .font(.title)
                            } else {
                                Text("\(watchlistVM.tickerData[stock] ?? "N/A")%")
                                    .bold()
                                    .font(.title)
                                    .foregroundColor(setTickerColor(change: watchlistVM.tickerData[stock] ?? "N/A"))
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0.0, leading: 8.0, bottom: 0.0, trailing: 8.0))
                        .onTapGesture {
                            selectedStock = stock
                            stockVM.stockSymbol = stock
                            print("Opened stock view for \(stock)")
                            stockDetailIsPresented = true
                        }
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else {return}
                        let stockDeleted = selectedWatchlist.stocksList[index]
                        if selectedWatchlist.id != nil {
                            Task {
                                await watchlistVM.deleteInvestment(watchlist: selectedWatchlist, stock: stockDeleted)
                            }
                        } else {
                            selectedWatchlist.stocksList.removeAll { $0 == stockDeleted}
                        }
                    }
                }
                .onAppear {
                    Task {
                        await watchlistVM.getTickerData(watchlist: selectedWatchlist.stocksList)
                    }
                }
                .refreshable {
                    let _ = await watchlistVM.getTickerData(watchlist: selectedWatchlist.stocksList)
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $searchSheetIsPresented) {
            StockLookupView(stockName: $selectedWatchlist.stocksList, currentWatchlist: selectedWatchlist)
        }
        .sheet(isPresented: $stockDetailIsPresented) {
            StockDetailView(stockTicker: selectedStock)
        }
        .toolbar {
            if selectedWatchlist.id == nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        alertMessage = "Would you like to make '\(selectedWatchlist.name)' public or private?"
                        showPublicAlert = true //Save occurs in alert after privacy selection
                    }
                    .disabled(selectedWatchlist.stocksList.isEmpty || selectedWatchlist.name.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
            if selectedWatchlist.id != nil && selectedWatchlist.isPublic == true && selectedWatchlist.creator != Auth.auth().currentUser?.email {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add To Lists") {
                        var newWatchlist = selectedWatchlist
                        newWatchlist.creator = (Auth.auth().currentUser?.email!)!
                        newWatchlist.isPublic = false
                        newWatchlist.id = nil
                        Task {
                            await watchlistVM.saveWatchlist(watchlist: newWatchlist)
                        }
                        dismiss()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            //Code to display stock lookup if user is watchlist creator
            if selectedWatchlist.creator == Auth.auth().currentUser?.email || selectedWatchlist.id == nil {
                ToolbarItem(placement: .status) {
                    Button {
                        searchSheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                        Text("Add Investments")
                    }
                }
            }
        }
        //Alert to select private/public availability of watchlist upon creation
        .alert(isPresented: $showPublicAlert) {
            Alert(
                title: Text("Watchlist Privacy"),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Private")) {
                    selectedWatchlist.isPublic = false
                    Task {
                        await watchlistVM.saveWatchlist(watchlist: selectedWatchlist)
                    }
                    dismiss()
                },
                secondaryButton: .cancel(Text("Public")) {
                    selectedWatchlist.isPublic = true
                    Task {
                        await watchlistVM.saveWatchlist(watchlist: selectedWatchlist)
                    }
                    dismiss()
                }
            )
        }
    }
    
    //Function to set the color of watchlist % change tickers
    func setTickerColor(change: String) -> Color {
        if change == "N/A" {
            return Color(.black)
        } else if Double(change)! > 0 {
            return Color("BetterGreen")
        } else if Double(change)! < 0 {
            return Color(.red)
        } else {
            return Color(.black)
        }
    }
}

struct WatchlistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchlistDetailView(selectedWatchlist: Watchlist(name: "First watchlist", listDescription: "This is a watch list description. This is a watch list description. This is a watch list description. This is a watch list description.", stocksList: ["AAPL", "GOOGL", "ADBE"]))
                .environmentObject(WatchlistViewModel())
                .environmentObject(StockViewModel())
        }
    }
}
