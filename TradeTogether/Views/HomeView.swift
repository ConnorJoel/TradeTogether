//
//  HomeView.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct HomeView: View {
    private var currdb = Firestore.firestore()
    @FirestoreQuery(collectionPath: "watchlists", predicates: [.isEqualTo("creator", Auth.auth().currentUser?.email ?? "")]) var userWatchlists: [Watchlist]
    @EnvironmentObject var watchlistVM: WatchlistViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var addWatchlistIsPresented = false
    @State private var publicWatchlistsIsPresented = false
        
    var body: some View {
        NavigationStack {
            ZStack {
                //TODO: Load local data
                List {
                    ForEach(userWatchlists) { watchlist in
                        NavigationLink {
                            WatchlistDetailView(selectedWatchlist: watchlist)
                        } label: {
                            VStack (alignment: .leading) {
                                HStack (alignment: .center, spacing: 2){
                                    Text(watchlist.name)
                                        .font(.title2)
                                        .bold()
                                        .padding(.trailing, 5.0)
                                    Text(watchlist.isPublic ? "Public" : "Private")
                                        .font(.caption)
                                        .padding(.vertical, 2.0)
                                        .padding(.horizontal, 5.0)
                                        .foregroundColor(.white)
                                        .background(watchlist.isPublic ? Color("AccentColor") : .gray)
                                        .clipShape(Capsule())
                                }
                                Text(watchlist.listDescription)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else {return}
                        Task {
                            await watchlistVM.deleteWatchlist(watchlist: userWatchlists[index])
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("My Watchlists")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Sign Out") {
                            do {
                                try Auth.auth().signOut()
                                print("✅ Log out successful")
                                dismiss()
                            } catch {
                                print("🛑 ERROR: Could not sign out")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            addWatchlistIsPresented.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                VStack {
                    Spacer()
                    Button {
                        publicWatchlistsIsPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text("Public Watchlists")
                                .font(.title2)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .sheet(isPresented: $addWatchlistIsPresented) {
            NavigationStack {
                WatchlistDetailView(selectedWatchlist: Watchlist())
            }
        }
        .sheet(isPresented: $publicWatchlistsIsPresented) {
            NavigationStack {
                PublicWatchlistsView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(WatchlistViewModel())
        }
    }
}
