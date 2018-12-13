//
//  Extension_TextView.swift
//  Dictionary
//
//  Created by Maha on 10/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    var numberOfLines: Int {
        let numberOfGlyphs = self.layoutManager.numberOfGlyphs
        
        var index = 0, numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)

        while index < numberOfGlyphs {
            self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
    
}
