//
//  Extension_String.swift
//  Dictionary
//
//  Created by Maha on 07/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
