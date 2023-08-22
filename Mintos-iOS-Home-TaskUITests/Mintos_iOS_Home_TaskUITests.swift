//
//  Mintos_iOS_Home_TaskUITests.swift
//  Mintos-iOS-Home-TaskUITests
//
//  Created by Sachin on 18/08/2023.
//

import XCTest

final class Mintos_iOS_Home_TaskUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch() // Launch your app
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    func testCopyInvestorButton() {
            // Perform UI actions to navigate to the view controller
        
        
            // Tap on the copy investor button
        app.tables.cells.containing(.staticText, identifier:"Beneficiary bank account number/IBAN").buttons["content copy FILL0 wght400 GRA"].tap()
        app.alerts.scrollViews.otherElements.buttons["Ok"].tap()

                                    // Check if the pasteboard contains the expected text
            XCTAssertEqual(UIPasteboard.general.string, "GB29NWBK60161331926819")
        }
}
