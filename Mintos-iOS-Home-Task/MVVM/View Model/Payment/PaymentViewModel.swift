//
//  PaymentViewModel.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//
import Foundation
import Combine

/// View model responsible for managing bank account data and API requests related to payments.
class PaymentViewModel {
    // MARK: - Properties
    
    var model = PaymentModel()
    
    /// Publisher for receiving bank account information.
    var bankAccountPublisher: AnyPublisher<String, Never> {
        bankAccountSubject.eraseToAnyPublisher()
    }
    let bankAccountSubject = PassthroughSubject<String, Never>()
    
    /// Publisher for sorting bank account information.
    var sortingBankAccountPublisher: AnyPublisher<String, Never> {
        sortingBankAccountSubject.eraseToAnyPublisher()
    }
    let sortingBankAccountSubject = PassthroughSubject<String, Never>()
    
    /// Publisher for receiving error messages.
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    let errorSubject = PassthroughSubject<String, Never>()
    
    // MARK: - API Request
    
    /// Fetches bank account information using an API request.
    func getBankAccountAPI() {
        PaymentEndPoint.getBankAccounts.instance.executeRequest { [weak self] (result: Result<GetBankAccountResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let responseData = response.response {
                    self.handleBankAccountResponse(responseData)
                } else {
                    // Handle empty response
                    self.errorSubject.send(APIError.invalidURL.localizedDescription)
                }
            case .failure(let error):
                self.handleAPIError(error)
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Handles the bank account response from the API.
    func handleBankAccountResponse(_ response: Response) {
        self.model.bankDetalisResponse = response
        
        // Extract unique currencies from the response
        let uniqueCurrencies = Set(response.items?.map { $0.currency ?? "" } ?? [])
        self.model.currencyList = Array(uniqueCurrencies)
        
        if let bankAccounts = response.items {
            self.populateBankAccountsByCurrency(bankAccounts)
        }
        
        // Notify subscribers about the bank account update
        self.bankAccountSubject.send("")
    }
    
    /// Populates bank accounts grouped by currency in the model.
    private func populateBankAccountsByCurrency(_ bankAccounts: [Item]) {
        for bankAccount in bankAccounts {
            if var accountsForCurrency = self.model.bankAccountsByCurrency[bankAccount.currency ?? ""] {
                accountsForCurrency.append(bankAccount)
                self.model.bankAccountsByCurrency[bankAccount.currency ?? ""] = accountsForCurrency
            } else {
                self.model.bankAccountsByCurrency[bankAccount.currency ?? ""] = [bankAccount]
            }
        }
    }
    
    /// Handles API errors and sends appropriate error messages.
    func handleAPIError(_ error: Error) {
        if let apiError = error as? APIError {
            if let message = apiError.errorMessage {
                self.errorSubject.send(message)
            } else {
                self.errorSubject.send(error.localizedDescription)
            }
        } else {
            self.errorSubject.send(error.localizedDescription)
        }
    }
    
    
    /// Sorts and updates the bank details list for the selected currency.
    ///
    /// This function retrieves the bank accounts for the selected currency from the view model,
    /// transforms the data into a list of tuples containing relevant details, and updates the
    /// view model's `bankDetailsList` property. The table view is then reloaded to reflect the changes.
    ///
    /// - Complexity: The time complexity of this function is O(n), where 'n' is the number of bank
    /// accounts in the selected currency's bank account array. The dominant factor is the enumeration
    /// through the bank account array. Other operations, such as creating tuples and reloading the
    /// table view, are constant time. This time complexity is suitable for most practical scenarios.
    ///
    func sortBankAccount() {
        // Retrieve the bank accounts for the selected currency from the view model
        guard let bankAccount = self.model.bankAccountsByCurrency[model.selectedCurrency] else {
            return
        }
        
        // Transform the bank account data into a list of tuples
        let bankDetailsList = bankAccount.enumerated().map { (section, item) in
            return (
                currencySection: section,
                bankAccounts: [
                    ("BANKNAME".localized, item.bank ?? ""),
                    ("BENEFICIARYBANKACCOUNT".localized, item.iban ?? ""),
                    ("BIICODE".localized, item.swift ?? ""),
                    ("BENEFICIARYNAEM".localized, item.beneficiaryName ?? ""),
                    ("BENEFICIARYBANKADDRESS".localized, item.beneficiaryBankAddress ?? "")
                ]
            )
        }
        
        // Update the view model's bank details list and reload the table view
        self.model.bankDetailsList = bankDetailsList
        self.sortingBankAccountSubject.send("")
    }
}
