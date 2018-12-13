//
//  Alert.swift
//  Virtual Tourist
//
//  Created by Maha on 26/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    
    static let AlertDismiss = "Ok"
    static let ErrorTitle = "Error"
    static let EmptyText = "Please enter a word"
    
    // Http response errors
    static let AuthenticationFailed = "The request failed due to invalid credentials, or you have reached your Application allowance."
    static let NotFound = "No information available or the requested URL was not found on the server."
    static let RequestURITooLong = "Your word_id exceeds the maximum 128 characters. Reduce the string that is passed to the API by calling only individual words."
    static let BadGateway = "Oxford Dictionaries API is down or being upgraded."
    static let ServiceUnavailable = "The Oxford Dictionaries API servers are up, but overloaded with requests. Please try again later."
    static let GatewayTimeout = "The Oxford Dictionaries API servers are up, but the request couldn’t be serviced due to some failure within our stack. Please try again later."
    
    static func createUIAlert(title: String = "", message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.AlertDismiss, style: .cancel, handler: nil))
        
        return alert
    }
}
