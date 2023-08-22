//
//  PaymentModel.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import Foundation
class PaymentModel {
    var bankDetailsList = [(currencySection: Int, bankAccounts: [(title: String, value: String)])]()
    var currencyList = [String]()
    var bankDetalisResponse: Response?
    var investorId: String?
    var bankAccountsByCurrency = [String: [Item]]()
var selectedCurrency = ""
}
// MARK: - GetBankAccountResponse
struct GetBankAccountResponse: Codable {
    let response: Response?
}

// MARK: - Response
struct Response: Codable, Equatable {
    static func == (lhs: Response, rhs: Response) -> Bool {
        return true
    }
    
    let paymentDetails: String?
    let items: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let bank, swift, currency, beneficiaryName: String?
    let beneficiaryBankAddress, iban: String?
}
