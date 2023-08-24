//
//  PaymentEndPoint.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import Foundation

/// Enum representing different endpoints for payment-related API calls.
enum PaymentEndPoint: TargetType {
    
    /// Endpoint to retrieve bank account information.
    case getBankAccounts
    
    /// The relative path for the endpoint.
    var path: String  {
        switch self {
        case .getBankAccounts: return ApisURL.ServiceUrls.getBankAccounts.rawValue
        }
    }
    
    /// The HTTP method to be used for the API call.
    var method: HTTPMethod  {
        switch self {
        case .getBankAccounts:
            return .get
        }
    }
    
    /// Returns an instance of APIManager configured for the specific endpoint.
    var instance: APIManager {
        return .init(targetData: self)
    }
}
