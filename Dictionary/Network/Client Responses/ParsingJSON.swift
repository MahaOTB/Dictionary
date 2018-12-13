//
//  ParsingJSON.swift
//  Dictionary
//
//  Created by Maha on 06/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation

struct ApiDictionaryResults: Codable {
    let results: [SearchResult]
}

struct SearchResult: Codable {
    let lexicalEntries: [LexicalEntrie]
    let word: String //
}

struct LexicalEntrie: Codable {
    let entries: [Entrie]
    let lexicalCategory: String //
}

struct Entrie: Codable {
    let senses: [Definition]
}

struct Definition: Codable {
    let definitions: [String]? //
}
