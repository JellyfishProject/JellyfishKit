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
    
    var port: in_port_t = 8080
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        while !(checkTcpPortForListen(port: self.port)) {
            port = port + 1
        }
        
        Jellyfish.logLevel = .verbose
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut.stop()
        sut = Jellyfish(mappingHost: testingHost())
        super.tearDown()
    }
    
    func testMetadata() {
        XCTAssertEqual(Jellyfish.version, "0.0.3")
    }
    
    func testCache() {
        
    }
    
    func testJellyfish_notFound() {
        sut.stub(docPath: Bundle(for: JellyfishTests.self).path(forResource: "testing_normal_blueprint", ofType: "apib")!, port: port)
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://example.com/notFound")!)
        WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
            
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
        sut.stub(docPath: Bundle(for: JellyfishTests.self).path(forResource: "testing_normal_blueprint", ofType: "apib")!, port: port) { error in
            XCTFail("\(error)")
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
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
    
    func testJellyfish_example1_multiple_headers() {
        sut.stub(docPath: Bundle(for: JellyfishTests.self).path(forResource: "testing_normal_blueprint", ofType: "apib")!, port: port) { error in
            XCTFail("\(error)")
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://example.com/message")!)
        request.addValue("id=\"user_id_2\", token=\"user_access_token\"", forHTTPHeaderField: "Authorization")
        
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
            
            guard let data = data, let str: String = String(data: data, encoding: .utf8) else {
                XCTFail("Data is empty")
                return
            }
            
            XCTAssert("Hello World! User 2\n" == str, "\(str) is incorrect")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    func testJellyfish_example1_custom_matcher() {
        sut.stub(docPath: Bundle(for: JellyfishTests.self).path(forResource: "testing_custom_handler_blueprint", ofType: "apib")!, port: port) { error in
            XCTFail("\(error)")
        }
        
        sut.addMatcher(to: "/message") { req in
            
            let str: String = "Hello World! User 3\n"
            
            return APIResponse(headers: ["Server": "Custom Handler"], responseCode: 200, body: str.data(using: .utf8)!)
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://example.com/message")!)
        request.addValue("id=\"user_id_3\", token=\"user_access_token\"", forHTTPHeaderField: "Authorization")
        
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
            
            XCTAssert(swifterVersion == "Custom Handler")
            
            guard let data = data, let str: String = String(data: data, encoding: .utf8) else {
                XCTFail("Data is empty")
                return
            }
            
            XCTAssert("Hello World! User 3\n" == str, "\(str) is incorrect")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testJellyfish_example2() {
        sut.stub(docPath: Bundle(for: JellyfishTests.self).path(forResource: "long_blueprint", ofType: "apib")!, port: port) { error in
            XCTFail("\(error)")
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
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
    
    
    func testJellyfish_ignoreHeader() {
        sut.stub(docPath: Bundle(for: JellyfishTests.self).path(forResource: "test_ignore", ofType: "apib")!, ignoreHeaders: ["udid"], port: port) { error in
            XCTFail("\(error)")
        }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://example.com/sessions")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": "email@email.com", "token": "token", "type": "email"], options: .prettyPrinted)
        request.addValue("my_device_id", forHTTPHeaderField: "udid")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
            
            XCTAssert(response.statusCode == 201)
            
            if let data = data {
                guard let str: String = String(data: data, encoding: .utf8) else {
                    XCTFail("Empty String")
                    expectation.fulfill()
                    return
                }
                XCTAssert(str.count != 0)
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
