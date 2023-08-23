//
//  Mintos_iOS_Home_TaskTests.swift
//  Mintos-iOS-Home-TaskTests
//
//  Created by Sachin on 18/08/2023.
//

import XCTest

@testable import Mintos_iOS_Home_Task

final class Mintos_iOS_Home_TaskTests: XCTestCase {
    var viewModel: PaymentViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        viewModel = PaymentViewModel()

    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        try super.tearDownWithError()
    }
    
    func testBankAccountResponseHandling() {
        // Create a dummy bank account response
        let item = Item(bank: "Bank", swift: "SWIFT", currency: "USD", beneficiaryName: "Name", beneficiaryBankAddress: "Address", iban: "IBAN")
        let response = Response(paymentDetails: "123456", items: [item])
        
        viewModel.handleBankAccountResponse(response)
        
        XCTAssertEqual(viewModel.model.bankDetalisResponse, response)
        XCTAssertEqual(viewModel.model.currencyList, ["USD"])
        XCTAssertEqual(viewModel.model.bankAccountsByCurrency["USD"]?.count, 1)
    }
    
    func testSortBankAccount() {
        // Create a dummy bank account
        let item = Item(bank: "Bank", swift: "SWIFT", currency: "USD", beneficiaryName: "Name", beneficiaryBankAddress: "Address", iban: "IBAN")
        viewModel.model.bankAccountsByCurrency["USD"] = [item]
        viewModel.model.selectedCurrency = "USD"
        viewModel.sortBankAccount()
        
        XCTAssertEqual(viewModel.model.bankDetailsList.count, 1)
        XCTAssertEqual(viewModel.model.bankDetailsList.first?.bankAccounts.count, 5)
        
        
        let bankNameTitle = viewModel.model.bankDetailsList.first?.bankAccounts[0].title
        let bankNameValue = viewModel.model.bankDetailsList.first?.bankAccounts[0].value
        XCTAssertEqual(bankNameTitle, "BANKNAME".localized)
        XCTAssertEqual(bankNameValue, "Bank")
    }
    
    func testInvalidResponseHandling() {
           // Test handling an invalid response with no paymentDetails and no items
           let invalidResponse = Response(paymentDetails: nil, items: nil)
           viewModel.handleBankAccountResponse(invalidResponse)

           XCTAssertTrue(viewModel.model.currencyList.isEmpty)
           XCTAssertNil(viewModel.model.bankAccountsByCurrency["USD"])
       }

    func testSortBankAccountWithInvalidCurrency() {
        // Create a dummy bank account with an invalid currency
        let invalidCurrencyItem = Item(bank: "Bank", swift: "SWIFT", currency: nil, beneficiaryName: "Name", beneficiaryBankAddress: "Address", iban: "IBAN")
        viewModel.model.bankAccountsByCurrency["InvalidCurrency"] = [invalidCurrencyItem]
        
        // Perform the sorting operation
        viewModel.sortBankAccount()
        
        // Assert that the bankDetailsList is empty
        XCTAssertTrue(viewModel.model.bankDetailsList.isEmpty)
    }
    
    
    func testSortingWithNoSelectedCurrency() {
        // Create a dummy bank account
        let item = Item(bank: "Bank", swift: "SWIFT", currency: "USD", beneficiaryName: "Name", beneficiaryBankAddress: "Address", iban: "IBAN")
        viewModel.model.bankAccountsByCurrency["USD"] = [item]
//        viewModel.model.selectedCurrency = "USD"
        viewModel.sortBankAccount()
        
        XCTAssertEqual(viewModel.model.bankDetailsList.count, 0)
    }
    
}
