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
                    // self.errorSubject.send("\(response.message ?? "")")
                    // print(responseData)
                }
            case .failure(let error):
                self.handleAPIError(error)
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Handles the bank account response from the API.
    private func handleBankAccountResponse(_ response: Response) {
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
    private func handleAPIError(_ error: Error) {
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
}
