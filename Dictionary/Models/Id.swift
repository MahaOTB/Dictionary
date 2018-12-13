//
//  Id.swift
//  Dictionary
//
//  Created by Maha on 07/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation

struct Id {
    
    // API Constants
    static let AppId = "fdad54ce"
    static let AppKey = "08252a5d35d5c3e719e91056fe83d411"
    static let AppIdKey = "app_id"
    static let AppKeyKey = "app_key"
    
    // URL
    static let Scheme = "https"
    static let Host = "od-api.oxforddictionaries.com"
    static let Path = "/api/v1/entries/en/"
    
    // CellReuseidentifier
    static let DefinitionsCellReuseidentifier = "DefinitionsCellReuseidentifier"
    static let FavoritesCellReuseidentifier = "FavoritesCellReuseidentifier"
    
    // Segue ID
    static let SegueToFavoriteDetails = "SegueToFavoriteDetails"
    static let FavoritesDetailsCellReuseidentifier = "FavoritesDetailsCellReuseidentifier"
    
    // CoreData Attrebute
    static let WordText = "text"
    static let WordEntity = "WordEntity"
    
}
