//
//  XCTestApplicationTests.swift
//  XCTestApplicationTests
//
//  Created by Ilham Andrian on 10/23/19.
//

import XCTest

class Swift_UnitTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test1() {
        XCTAssertFalse(true, "Should fail")
    }

    func test2() {
        XCTAssertTrue(true, "Should pass")
    }

    func test3() {
        XCTAssertFalse(true, "Should fail")
    }

    func test4() {
        XCTAssertTrue(true, "Should pass")
    }

    func test5() {
        XCTAssertFalse(true, "Should fail")
    }
}
