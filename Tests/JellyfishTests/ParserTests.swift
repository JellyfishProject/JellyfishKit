//
//  ParserTests.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation
import XCTest
@testable import Jellyfish

class ParserTests: XCTestCase {
    
    var sut: Jellyfish = Jellyfish()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = Jellyfish()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseAPIBlueprintNormal() {
        let docPath: String = Bundle(for: ParserTests.self).path(forResource: "testing_normal_blueprint", ofType: "apib")!
        let docContent: String = try! String(contentsOfFile: docPath, encoding: .utf8)
        let expectation: XCTestExpectation = XCTestExpectation(description: "Parsing")
        sut.parse(docContent: docContent) { result in
            switch result {
            case .success(let apiDefinition):
                XCTAssert(apiDefinition.title == "My API", "\(apiDefinition.title) is incorrect")
                XCTAssert(apiDefinition.host == "https://example.com", "\(apiDefinition.host) is incorrect")
                XCTAssert(apiDefinition.resources.count == 2)
                
                let resource1 = apiDefinition.resources[0]
                
                XCTAssert(resource1.path == "/message")
                XCTAssert(resource1.examples[0].requests.first?.method == .GET, "\(resource1.examples[0].requests.first?.method) is incorrect")
                XCTAssert(resource1.examples[0].responses.first?.responseCode == 200, "\(String(describing: resource1.examples[0].responses.first?.responseCode)) is incorrect")
                
                if let contentType = resource1.examples[0].responses.first?.headers?["Content-type"] {
                    XCTAssert(contentType == "text/plain", "\(contentType) is incorrect")
                }
                
                if let body: Data = resource1.examples[0].responses.first?.body,
                    let str: String = String(data:body, encoding: .utf8){
                    XCTAssert(str == "Hello World! User 1\n", "\(str) is incorrect")
                }else {
                    XCTFail("Should have body")
                }
                
                XCTAssert(resource1.examples[1].requests.first?.method == .GET, "\(resource1.examples[0].requests.first?.method) is incorrect")
                XCTAssert(resource1.examples[1].responses.first?.responseCode == 200, "\(String(describing: resource1.examples[1].responses.first?.responseCode)) is incorrect")
                
                if let contentType = resource1.examples[1].responses.first?.headers?["Content-type"] {
                    XCTAssert(contentType == "text/plain", "\(contentType) is incorrect")
                }
                
                if let body2: Data = resource1.examples[1].responses.first?.body,
                    let str: String = String(data:body2, encoding: .utf8){
                    XCTAssert(str == "Hello World! User 2\n", "\(str) is incorrect")
                }else {
                    XCTFail("Should have body2")
                }
                
                
                let resource2 = apiDefinition.resources[1]
                
                XCTAssert(resource2.path == "/message2")
                XCTAssert(resource2.examples[0].requests.first?.method == .POST, "\(resource2.examples[0].requests.first?.method) is incorrect")
                XCTAssert(resource2.examples[0].responses.first?.responseCode == 200, "\(String(describing: resource2.examples[0].responses.first?.responseCode)) is incorrect")
            case .failure(let err):
                XCTFail("Should not fail \(err)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testParseAPIBlueprint_long() {
        let docPath: String = Bundle(for: ParserTests.self).path(forResource: "long_blueprint", ofType: "apib")!
        let docContent: String = try! String(contentsOfFile: docPath, encoding: .utf8)
        let expectation: XCTestExpectation = XCTestExpectation(description: "Parsing")
        sut.parse(docContent: docContent) { result in
            switch result {
            case .success(let apiDefinition):
                XCTAssert(apiDefinition.title == "Real World API", "\(apiDefinition.title) is incorrect")
                XCTAssert(apiDefinition.host == "https://alpha-api.app.net", "\(apiDefinition.host) is incorrect")
                XCTAssert(apiDefinition.resources.count == 3, "\(apiDefinition.resources.count) is incorrect")
                
                
            case .failure(let err):
                XCTFail("Should not fail \(err)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30.0)
    }
}
