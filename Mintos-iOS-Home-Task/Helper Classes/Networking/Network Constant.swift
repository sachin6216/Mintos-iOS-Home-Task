//
//  Network Constant.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import Foundation


struct ApisURL {
    // Base Url
    // MARK: - App URL's
    static let baseURl = "https://mintos-mobile.s3.eu-central-1.amazonaws.com" // Local
    
    enum ServiceUrls: String {
        // MARK: - Common URLs
        // Payment
        case getBankAccounts = "/bank-accounts.json"
    }
}
