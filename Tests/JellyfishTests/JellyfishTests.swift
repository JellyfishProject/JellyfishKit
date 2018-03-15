//
//  JellyfishTests.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 6/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation
import XCTest
import Jellyfish

class JellyfishTests: XCTestCase {
    
    var sut: Jellyfish = Jellyfish()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut.stop()
        sut = Jellyfish()
        super.tearDown()
    }
    
    func testMetadata() {
        XCTAssertEqual(Jellyfish.version, "0.0.1")
    }
    
    func testJellyfish_notFound() {
        sut.stub(docPath: Bundle(for: ParserTests.self).path(forResource: "testing_normal_blueprint", ofType: "apib")!, port: 8081)
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://example.com/notFound")!)
        WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
            if let error = err {
                XCTFail("\(error)")
                expectation.fulfill()
                return
            }
            
            guard let response: HTTPURLResponse = res as? HTTPURLResponse else {
                XCTFail("Empty Response")
                expectation.fulfill()
                return
            }
            
            XCTAssert(response.statusCode == 404)
            
            guard let swifterVersion: String = response.allHeaderFields["Server"] as? String else{
                XCTFail("Wrong Header")
                expectation.fulfill()
                return
            }
            
            XCTAssert(swifterVersion == "Swifter 1.3.3")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testJellyfish_example1() {
        sut.stub(docPath: Bundle(for: ParserTests.self).path(forResource: "testing_normal_blueprint", ofType: "apib")!, port: 8082) { error in
            XCTFail("\(error)")
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://example.com/message")!)
        WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
            if let error = err {
                XCTFail("\(error)")
                expectation.fulfill()
                return
            }
            
            guard let response: HTTPURLResponse = res as? HTTPURLResponse else {
                XCTFail("Empty Response")
                expectation.fulfill()
                return
            }
            
            XCTAssert(response.statusCode == 200)
            
            guard let swifterVersion: String = response.allHeaderFields["Server"] as? String else{
                XCTFail("Wrong Header")
                expectation.fulfill()
                return
            }
            
            XCTAssert(swifterVersion == "Swifter 1.3.3")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testJellyfish_example2() {
        sut.stub(docPath: Bundle(for: ParserTests.self).path(forResource: "long_blueprint", ofType: "apib")!, port: 8083) { error in
            XCTFail("\(error)")
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://alpha-api.app.net/stream/0/posts/1")!)
        WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
            if let error = err {
                XCTFail("\(error)")
                expectation.fulfill()
                return
            }
            
            guard let response: HTTPURLResponse = res as? HTTPURLResponse else {
                XCTFail("Empty Response")
                expectation.fulfill()
                return
            }
            
            XCTAssert(response.statusCode == 200)
            
            if let data = data {
                guard let str: String = String(data: data, encoding: .utf8) else {
                    XCTFail("Empty String")
                    expectation.fulfill()
                    return
                }
                XCTAssert(str.count != 0)
                print(str)
            }
            
            
            guard let swifterVersion: String = response.allHeaderFields["Server"] as? String else{
                XCTFail("Wrong Header")
                expectation.fulfill()
                return
            }
            
            XCTAssert(swifterVersion == "Swifter 1.3.3")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
