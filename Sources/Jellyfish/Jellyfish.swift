//
//  Jellyfish.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 6/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

public typealias JellyfishErrorHandler = ((Error) -> Void)

public class Jellyfish {
    public static let version: String = "0.0.1"
    
    var parser: APIParser
    var mockServer: HTTPMockServer = HTTPMockServer()
    
    public init(_ parser: APIParser = APIBlueprintParser()) {
        self.parser = parser
    }
    
    public func parse(docContent: String, completion: @escaping ((ParserResult<APIDefinition>)->())) {
        self.parser.parse(content: docContent) { result in
            completion(result)
        }
    }
    
    
    public func stop() {
        self.mockServer.stop()
        JellyfishURLProtocol.removeAllStub()
    }
    
    public func stub(
        docPath: String,
        port: in_port_t = 8080,
        errorHandler: JellyfishErrorHandler? = nil) {
        if let docContent: String = try? String(contentsOfFile: docPath, encoding: .utf8) {
            self.stub(docContent: docContent, port: port, errorHandler: errorHandler)
        }
    }
    
    public func stub(
        docContent: String,
        port: in_port_t = 8080,
        errorHandler: JellyfishErrorHandler? = nil) {
        self.parse(docContent: docContent) { result in
            switch result {
            case .success(let apiDefinition):
                do{
                    self.mockServer = HTTPMockServer(port)
                    try self.mockServer.start(with: apiDefinition, enableStub: true)
                }catch{
                    errorHandler?(error)
                }
            case .failure(let err):
                 errorHandler?(err)
            }
        }
    }
}
