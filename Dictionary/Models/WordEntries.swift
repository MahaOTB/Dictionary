//
//  WordEntries.swift
//  Dictionary
//
//  Created by Maha on 06/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation

struct Lexical {
    let category: String
    let definitions: [String]
}

class Word {
    var lexicals = [Lexical]()
    
    static func getWordDefinitions(word: String, complition: @escaping (Word?, Error?) -> Void) {
        NetworkClient.getWordEntries(word: word) { ( lexicalEntries, error) in
            guard error == nil else {
                complition(nil, error!)
                return
            }
            
            let wordObject = Word()
            for entrie in lexicalEntries! {
                let category = entrie.lexicalCategory
                var categoryDefinitions = [String]()
                
                for entrie in entrie.entries {
                    for sense in entrie.senses {
                        guard let definitions = sense.definitions else {continue}
                        for definition in definitions {
                            categoryDefinitions.append(definition)
                        }
                    }
                }
                
                let lexical = Lexical(category: category, definitions: categoryDefinitions)
                wordObject.lexicals.append(lexical)
            }
            
            complition(wordObject, nil)
        }
    }
    
    
}
