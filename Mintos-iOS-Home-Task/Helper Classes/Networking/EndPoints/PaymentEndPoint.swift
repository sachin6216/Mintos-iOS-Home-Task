//
//  PaymentEndPoint.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import Foundation
enum PaymentEndPoint: TargetType {
    
    case getBankAccounts
    
    var path: String  {
        switch self {
        case .getBankAccounts: return ApisURL.ServiceUrls.getBankAccounts.rawValue
        }
    }
    
    var method: HTTPMethod  {
        switch self {
        case .getBankAccounts:
            return .get
        }
    }
    
    var instance: APIManager {
        return .init(targetData: self)
    }
}
