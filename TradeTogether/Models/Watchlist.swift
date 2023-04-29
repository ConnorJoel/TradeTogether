//
//  Watchlist.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Watchlist: Identifiable, Decodable, Encodable {
    @DocumentID var id: String?
    var creator = Auth.auth().currentUser?.email ?? ""
    var isPublic = true
    var name = ""
    var listDescription = ""
    var stocksList: [String] = []
    
    var dictionary: [String: Any] {
        return ["creator": creator, "isPublic": isPublic, "name": name, "listDescription": listDescription, "stocksList": stocksList]
    }
}
