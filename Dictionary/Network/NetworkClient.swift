//
//  NetworkClient.swift
//  Dictionary
//
//  Created by Maha on 06/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import Alamofire

struct NetworkClient {
    
    static func getWordEntries(word: String, complition: @escaping ([LexicalEntrie]?, Error?) -> Void ) {
        let url = buildURL(wordId: word)
        
        var request = URLRequest(url: url)
        request.addValue(Id.AppId, forHTTPHeaderField: Id.AppIdKey)
        request.addValue(Id.AppKey, forHTTPHeaderField: Id.AppKeyKey)
        
        Alamofire.request(request).validate().responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.result.value {
                    
                    convertDataToJsonObject(objectType: ApiDictionaryResults.self, data: data) { dictionaryObject, error in
                        guard error == nil else {
                            complition(nil, error)
                            return
                        }
                        
                        complition(dictionaryObject!.results[0].lexicalEntries, nil)
                        }
                    }
                
            case .failure(let error):
                if let satusCodeError = StatusCodeError(statusCode: response.response?.statusCode) {
                    complition(nil, satusCodeError)
                    return
                }
    
                complition(nil, error)
            }
        }
    }
    
    static func convertDataToJsonObject<structName: Codable>(objectType: structName.Type, data: Data, complition: (structName?, Error?) -> Void) {
        do {
            let json = try JSONDecoder().decode(objectType, from: data)
            complition(json, nil)
        }catch {
            complition(nil,error)
        }
    }
    
    static func StatusCodeError(statusCode: Int?) -> Error? {
        if statusCode == 403 {
            let error = NSError(domain: "", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: Alert.AuthenticationFailed])
            return error
        } else if statusCode == 404 {
            let error = NSError(domain: "", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: Alert.NotFound])
            return error
        } else if statusCode == 414 {
            let error = NSError(domain: "", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: Alert.RequestURITooLong])
            return error
        } else if statusCode == 502 {
            let error = NSError(domain: "", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: Alert.BadGateway])
            return error
        } else if statusCode == 503 {
            let error = NSError(domain: "", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: Alert.ServiceUnavailable])
            return error
        } else if statusCode == 504{
            let error = NSError(domain: "", code: statusCode!, userInfo: [NSLocalizedDescriptionKey: Alert.GatewayTimeout])
            return error
        }
        return nil
    }
    
    static func buildURL(wordId: String) -> URL{
        
        // URL Components
        var components = URLComponents()
        components.scheme = Id.Scheme
        components.host = Id.Host
        components.path = "\(Id.Path)\(wordId.lowercased())"
        
        return components.url!
    }
    
}
