//
//  MockServerTests.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import XCTest
@testable import Jellyfish

class MockServerTests: XCTestCase {
    
    var sut: HTTPMockServer = HTTPMockServer()
    
    var port: in_port_t = 8080
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut.stop()
        
        // 49152-65535
        
        while !(checkTcpPortForListen(port: self.port)) {
            port = in_port_t(arc4random_uniform(16383) + 49152)
        }
        
        sut = HTTPMockServer(port)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut.stop()
        super.tearDown()
    }
    
    func testMockNotFound() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Not found Example",
                                                         host: "http://localhost:\(port)",
                                                         resources: [])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello")!)
            WebRequestHelper.makeRequest(request: request as URLRequest) { (_ , res , err) in
                if let error = err {
                    XCTFail("\(error)")
                    expectation.fulfill()
                    return
                }
                
                guard let response: HTTPURLResponse = res as? HTTPURLResponse else{
                    XCTFail("No Response")
                    expectation.fulfill()
                    return
                    
                }
                
                XCTAssert(response.statusCode == 404, "\(response.statusCode) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    func testMockSingle() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Single Example",
                                                         host: "http://localhost:\(port)",
                                                         resources: [APIResource(
                                                            path: "/hello",
                                                            examples:[APIExample(
                                                                pathParams: [:],
                                                                queryParams: [:],
                                                                requests: [APIRequest(
                                                                    headers: nil,
                                                                    body: nil,
                                                                    method: .GET
                                                                    )],
                                                                responses: [APIResponse(
                                                                    headers: nil,
                                                                    responseCode: 200,
                                                                    body: "Hello World!".data(using: .utf8)!
                                                                    )]
                                                                )]
                                                            )])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello")!)
            WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
                if let error = err {
                    XCTFail("\(error)")
                }
                
                guard let data: Data = data else {
                    XCTFail("Empty Response")
                    expectation.fulfill()
                    return
                }
                
                print(res ?? "No Response")
                
                let str: String = String(data: data, encoding: .utf8)!
                
                XCTAssert(str == "Hello World!", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testMockMultipleExamples() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Multiple Example",
                                                         host: "http://localhost:\(port)",
                                                         resources: [APIResource(
                                                            path: "/hello/{path}",
                                                            examples:[APIExample(
                                                                pathParams: ["path": "1"],
                                                                queryParams: [:],
                                                                requests: [APIRequest(
                                                                    headers: nil,
                                                                    body: nil,
                                                                    method: .GET
                                                                    )],
                                                                responses: [APIResponse(
                                                                    headers: nil,
                                                                    responseCode: 200,
                                                                    body: "Hello World!".data(using: .utf8)!
                                                                    )]
                                                                ),APIExample(
                                                                    pathParams: ["path": "2"],
                                                                    queryParams: [:],
                                                                    requests: [APIRequest(
                                                                        headers: nil,
                                                                        body: nil,
                                                                        method: .GET
                                                                        )],
                                                                    responses: [APIResponse(
                                                                        headers: nil,
                                                                        responseCode: 200,
                                                                        body: "Hello World2!".data(using: .utf8)!
                                                                        )]
                                                                )]
                                                            )])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello/2")!)
            WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
                if let error = err {
                    XCTFail("\(error)")
                }
                
                guard let data: Data = data else {
                    XCTFail("Empty Response")
                    expectation.fulfill()
                    return
                }
                
                print(res ?? "No Response")
                
                let str: String = String(data: data, encoding: .utf8)!
                
                XCTAssert(str == "Hello World2!", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    func testMockQuery() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Single Example",
                                                         host: "http://localhost:\(port)",
                                                         resources: [APIResource(
                                                            path: "/hello{?name,call}",
                                                            examples:[APIExample(
                                                                pathParams: [:],
                                                                queryParams: ["name": "darkcl", "call": "Mr"],
                                                                requests: [APIRequest(
                                                                    headers: nil,
                                                                    body: nil,
                                                                    method: .GET
                                                                    )],
                                                                responses: [APIResponse(
                                                                    headers: nil,
                                                                    responseCode: 200,
                                                                    body: "Hello Mr darkcl!".data(using: .utf8)!
                                                                    )]
                                                                )]
                                                            )])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello?call=Mr&name=darkcl")!)
            WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
                if let error = err {
                    XCTFail("\(error)")
                }
                
                guard let data: Data = data else {
                    XCTFail("Empty Response")
                    expectation.fulfill()
                    return
                }
                
                print(res ?? "No Response")
                
                let str: String = String(data: data, encoding: .utf8)!
                
                XCTAssert(str == "Hello Mr darkcl!", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testMockPostBody_json() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Single Example",
                                                         host: "http://localhost:\(port)",
                                                         resources: [APIResource(
                                                            path: "/hello",
                                                            examples:[APIExample(
                                                                pathParams: [:],
                                                                queryParams: [:],
                                                                requests: [APIRequest(
                                                                    headers: ["Content-type": "application/json"],
                                                                    body: try! JSONSerialization.data(withJSONObject: ["name": "darkcl", "calling": "Mr"], options: .prettyPrinted),
                                                                    method: .POST
                                                                    )],
                                                                responses: [APIResponse(
                                                                    headers: nil,
                                                                    responseCode: 200,
                                                                    body: "Hello World! Mr darkcl".data(using: .utf8)!
                                                                    )]
                                                                )]
                                                            )])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            let jsonString: String = """
                    { "calling": "Mr", "name": "darkcl" }
            """
            
            request.httpBody = jsonString.data(using: .utf8)!
            
            WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
                if let error = err {
                    XCTFail("\(error)")
                    expectation.fulfill()
                    return
                }
                
                guard let data: Data = data else {
                    XCTFail("Empty Response")
                    expectation.fulfill()
                    return
                }
                
                print(res ?? "No Response")
                
                let str: String = String(data: data, encoding: .utf8)!
                
                XCTAssert(str == "Hello World! Mr darkcl", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testMockPostBody_plain() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Single Example",
                                                         host: "http://localhost:\(port)",
                                                         resources: [APIResource(
                                                            path: "/hello",
                                                            examples:[APIExample(
                                                                pathParams: [:],
                                                                queryParams: [:],
                                                                requests: [APIRequest(
                                                                    headers: nil,
                                                                    body: "Hello World!".data(using: .utf8)!,
                                                                    method: .POST
                                                                    )],
                                                                responses: [APIResponse(
                                                                    headers: nil,
                                                                    responseCode: 200,
                                                                    body: "Hello World! Mr darkcl".data(using: .utf8)!
                                                                    )]
                                                                )]
                                                            )])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello")!)
            request.httpMethod = "POST"
            request.setValue("plain/text", forHTTPHeaderField: "content-type")
            let jsonString: String = "Hello World!"
            
            request.httpBody = jsonString.data(using: .utf8)!
            
            WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
                if let error = err {
                    XCTFail("\(error)")
                    expectation.fulfill()
                    return
                }
                
                guard let data: Data = data else {
                    XCTFail("Empty Response")
                    expectation.fulfill()
                    return
                }
                
                print(res ?? "No Response")
                
                let str: String = String(data: data, encoding: .utf8)!
                
                XCTAssert(str == "Hello World! Mr darkcl", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testMockFallback_subresources() {
        let apiDefinition: APIDefinition = APIDefinition(title: "Single Example",
                                                         host: "http://localhost:\(port)",
            resources: [APIResource(
                path: "/hello",
                examples:[APIExample(
                    pathParams: [:],
                    queryParams: [:],
                    requests: [APIRequest(
                        headers: nil,
                        body: nil,
                        method: .GET
                        )],
                    responses: [APIResponse(
                        headers: nil,
                        responseCode: 200,
                        body: "Hello World!".data(using: .utf8)!
                        )]
                    )]
                ),APIResource(
                    path: "/hello/message",
                    examples:[APIExample(
                        pathParams: [:],
                        queryParams: [:],
                        requests: [APIRequest(
                            headers: nil,
                            body: nil,
                            method: .GET
                            )],
                        responses: [APIResponse(
                            headers: nil,
                            responseCode: 200,
                            body: "Hello World in message!".data(using: .utf8)!
                            )]
                        )]
                )])
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response")
        do{
            try sut.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "http://localhost:\(port)/hello/message?q=fallback")!)
            WebRequestHelper.makeRequest(request: request as URLRequest) { (data, res , err) in
                if let error = err {
                    XCTFail("\(error)")
                }
                
                guard let data: Data = data else {
                    XCTFail("Empty Response")
                    expectation.fulfill()
                    return
                }
                
                print(res ?? "No Response")
                
                let str: String = String(data: data, encoding: .utf8)!
                
                XCTAssert(str == "Hello World in message!", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}

// MARK - Helper

fileprivate extension StubbingTests {
    
}
