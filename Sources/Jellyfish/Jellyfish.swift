//
//  Jellyfish.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 6/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

public typealias JellyfishErrorHandler = ((Error) -> Void)

public enum JellyfishLogLevel: Int {
    case verbose = 0, debug, error, none
}

internal struct JellfishLogger {
    static func log(_ message: String, _ logLevel: JellyfishLogLevel) {
        if logLevel.rawValue >= Jellyfish.logLevel.rawValue {
            print(message)
        }
    }
}

public class Jellyfish {
    public static let version: String = "0.0.1"
    
    public static var logLevel: JellyfishLogLevel = .error
    
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
        ignoreHeaders: [String] = [],
        port: in_port_t = 8080,
        errorHandler: JellyfishErrorHandler? = nil) {
        if let docContent: String = try? String(contentsOfFile: docPath, encoding: .utf8) {
            self.stub(docContent: docContent, port: port, ignoreHeaders: ignoreHeaders, errorHandler: errorHandler)
        }
    }
    
    public func stub(
        docContent: String,
        port: in_port_t = 8080,
        ignoreHeaders: [String] = [],
        errorHandler: JellyfishErrorHandler? = nil) {
        self.parse(docContent: docContent) { result in
            switch result {
            case .success(let apiDefinition):
                do{
                    self.mockServer = HTTPMockServer(port)
                    try self.mockServer.start(with: apiDefinition, enableStub: true, ignoreHeaders: ignoreHeaders)
                }catch{
                    errorHandler?(error)
                }
            case .failure(let err):
                 errorHandler?(err)
            }
        }
    }
}
