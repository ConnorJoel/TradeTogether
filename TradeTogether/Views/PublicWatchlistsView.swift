//
//  PublicWatchlistsView.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/24/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct PublicWatchlistsView: View {
    //TODO: filter query to ony show watchlists where isPublic == true
    @FirestoreQuery(collectionPath: "watchlists", predicates: [.isEqualTo("isPublic", true)]) var publicWatchlists: [Watchlist]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var filteredStockList: [Watchlist] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(filteredStockList) { watchlist in
                    NavigationLink {
                        WatchlistDetailView(selectedWatchlist: watchlist)
                    } label: {
                        VStack (alignment: .leading) {
                            Text(watchlist.name)
                                .font(.title2)
                                .bold()
                            Text(watchlist.listDescription)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .onChange(of: searchText, perform: { text in
                    print(text)
                    if !text.isEmpty {
                        filteredStockList = publicWatchlists.filter{$0.name.localizedCaseInsensitiveContains(searchText)}
                    } else {
                        filteredStockList = publicWatchlists
                    }
                })
                .listStyle(.plain)
                .searchable(text: $searchText)
                
                //Todo
                VStack {
                    Spacer()
                    HStack {
                        Text("Displaying \(filteredStockList.count) of \(publicWatchlists.count) public watchlists")
                            .font(.caption)
                            .foregroundColor(Color("AccentColor"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10.0)
                    .padding(.bottom, 20.0)
                    .background(.ultraThinMaterial.opacity(0.9))
                }
                .ignoresSafeArea()
            }
            .navigationTitle("Public Watchlists")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Exit")
                    }
                }
            }
        }
    }
}


struct PublicWatchlistsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PublicWatchlistsView()
        }
    }
}
