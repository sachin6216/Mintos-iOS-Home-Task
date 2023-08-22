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
        
        // Tap on the copy investor button
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).buttons["content copy FILL0 wght400 GRA"].tap()
        app.alerts.scrollViews.otherElements.buttons["Ok"].tap()
        
        
        // Check if the pasteboard contains the expected text
        
        XCTAssertEqual(app.staticTexts["54361338 - Investor"].label, "\(UIPasteboard.general.string ?? "") - Investor")
        
    }
    
}
