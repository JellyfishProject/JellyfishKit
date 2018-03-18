//
//  StubbingTests.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 13/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import XCTest
@testable import Jellyfish


class StubbingTests: XCTestCase {
    
    var port: in_port_t = 8080
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        JellyfishURLProtocol.register()
        
        while !(checkTcpPortForListen(port: self.port)) {
            port = port + 1
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        JellyfishURLProtocol.removeAllStub()
    }
    
    func testStubbing() {
        JellyfishURLProtocol.stub["https://google.com"] = "\(testingHost()):\(port)"
        
        let apiDefinition: APIDefinition = APIDefinition(title: "Single Example",
                                                         host: "https://google.com",
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
        let expectation: XCTestExpectation = XCTestExpectation(description: "Wait for response on port \(self.port)")
        let mockServer: HTTPMockServer = HTTPMockServer(port)
        
        do{
            try mockServer.start(with: apiDefinition)
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "https://google.com/hello")!)
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
                
                XCTAssert(str == "Hello World!", "\(str) is incorrect")
                
                expectation.fulfill()
            }
        }catch{
            XCTFail("\(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
        
    }
    
}
