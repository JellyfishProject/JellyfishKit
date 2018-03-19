//
//  HTTPMock.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 13/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

fileprivate extension Dictionary where Key: ExpressibleByStringLiteral {
    mutating func lowercaseKeys() {
        for key in self.keys {
            self[String(describing: key).lowercased() as! Key] = self.removeValue(forKey: key)
        }
    }
}

fileprivate extension Data {
    func compare(with data: Data, contentType: String) -> Bool {
        if contentType == "application/json" {
            do {
                if let dataDictionary: [String: AnyHashable] = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String : AnyHashable],
                    let otherDictionary: [String: AnyHashable] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyHashable] {
                    return dataDictionary == otherDictionary
                }else{
                    return false
                }
            }catch {
                return false
            }
        }else{
            let dataString: String? = String(data: self, encoding: .utf8)
            let otherString: String? = String(data: data, encoding: .utf8)
            
            return (dataString == otherString)
        }
    }
}

fileprivate extension HttpRequest {
    
    func contentType(_ dict: [String: String]?) -> String? {
        if let dict = dict {
            if let result = dict["content-type"] {
                return result
            }else if let result = dict["Content-type"]{
                return result
            }else if let result = dict["Content-Type"]{
                return result
            }else {
                return nil
            }
        }else{
            return nil
        }
    }
    
    func matchHeader(with apiRequest: APIRequest, ignoreHeaders: [String])  -> Bool {
        
        let ignores: [String] = ignoreHeaders.map { str -> String in
            return str.lowercased()
        }
        
        var myHeaders: [String: String] = self.headers
        myHeaders.lowercaseKeys()
        
        if var requestHeader = apiRequest.headers {
            requestHeader.lowercaseKeys()
            for key: String in requestHeader.keys {
                if let value: String = self.headers[key], !ignores.contains(key) {
                    if value != requestHeader[key] {
                        return false
                    }
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func matchMethod(with apiRequest: APIRequest) -> Bool {
        return self.method == apiRequest.method.rawValue
    }
    
    func matchBody(with apiRequest: APIRequest) -> Bool {
        if let exampleBody: Data = apiRequest.body, self.body.count != 0 {
           let requestBody: Data = Data(bytes: self.body)
            
            // Get Content Type, only support JSON and plain text
            
            if let requestContentType: String = contentType(headers),
                let exampleContentType: String = contentType(apiRequest.headers) {
                if requestContentType == exampleContentType {
                    return requestBody.compare(with: exampleBody, contentType: requestContentType)
                }else{
                    return false
                }
            }
            
            return requestBody.compare(with: exampleBody, contentType: "plain/text")
        }else if apiRequest.body == nil && self.body.count == 0 {
            return true
        }
        return false
    }
    
    func mathPath(_ host: String, examplePath: String, with templateString: String, possibleValues: [String: String]?) -> Bool {
        let template: URITemplate = URITemplate(template: templateString)
        
        if let variables: [String:String] = template.extract(self.path) {
            
            if let possibleValues = possibleValues {
                for key: String in variables.keys {
                    if let value = possibleValues[key],
                        let variable = variables[key] {
                        if value != variable {
                            return false
                        }
                    }
                }
            }
            
            return true
        }else{
            guard let requestComp: URLComponents = URLComponents(string: host + self.path),
                let exampleComp: URLComponents = URLComponents(string: host + examplePath) else {
                    return false
            }
            
            if requestComp.path == exampleComp.path {
                return true
            }else{
                return false
            }
            
        }
    }
    
    func match(with definition: APIDefinition, ignoreHeaders: [String]) -> HttpResponse {
        for res in definition.resources {
            if let response = match(with: res, host: definition.host, ignoreHeaders: ignoreHeaders) {
                return response
            }
        }
        print("\(self.path) not match")
        return HttpResponse.notFound
    }
    
    func match(with res: APIResource, host: String, ignoreHeaders: [String]) -> HttpResponse? {
        for example in res.examples {
            
            for (i, request) in example.requests.enumerated() {
                let exampleUrl: String = example.examplePath(with: res.path)
                if match(with: request,
                         from: exampleUrl,
                         template: res.path,
                         host: host,
                         possibleValues: example.pathParams,
                         ignoreHeaders: ignoreHeaders) {
                    if let response: APIResponse = example.responses[safe: i] {
                        return HttpResponse.raw(response.responseCode ?? 200, "OK", response.headers, { writer in
                            if let data: Data = response.body {
                                try? writer.write(data)
                            }
                        })
                    }
                }
            }
        }
        
        return nil
    }
    
    
    func match(with apiRequest: APIRequest,
               from path: String,
               template: String,
               host: String,
               possibleValues: [String: String]?,
               ignoreHeaders: [String]
        ) -> Bool {
        
        let isPathMatched: Bool = mathPath(host, examplePath: path, with: template, possibleValues: possibleValues)
        let isMethodMached: Bool = matchMethod(with: apiRequest)
        let isHeaderMatched: Bool = matchHeader(with: apiRequest, ignoreHeaders: ignoreHeaders)
        let isBodyMatched: Bool = matchBody(with: apiRequest)
        
        return isPathMatched &&
            isMethodMached &&
            isHeaderMatched &&
            isBodyMatched
    }
}

fileprivate struct HttpTranscationPair {
    let request: APIRequest
    let response: APIResponse
}

fileprivate extension APIExample {
    func examplePath(with path: String) -> String {
        
        let uri: String = path
        let template: URITemplate = URITemplate(template: uri)
        let variables: [String] = template.variables
        
        var pathVariables: [String: String] = [:]
        
        for variable in variables {
            pathVariables[variable] = "jellyfish"
        }
        
        
        for variable in variables {
            if let examplePath = self.pathParams[variable] {
                pathVariables[variable] = examplePath
            }
        }
        
        for variable in variables {
            if let examplePath = self.queryParams[variable] {
                pathVariables[variable] = examplePath
            }
        }
        
        return template.expand(pathVariables)
    }
}

fileprivate extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class HTTPMockServer {
    var server = HttpServer()
    var port: in_port_t = 8080
    fileprivate var transactionPair: [HttpTranscationPair] = []
    var posibleValues: [String: [String]] = [:]
    
    init(_ port: in_port_t = 8080) {
        self.port = port
    }
    
    func start(with definition: APIDefinition, enableStub: Bool = false, ignoreHeaders: [String] = [], mappingHost: String = "http://localhost") throws {
        
        if enableStub {
            JellyfishURLProtocol.addStub(from: definition.host, to: "\(mappingHost):\(port)")
        }
        
        let response: ((HttpRequest) -> HttpResponse?) = {r in
            
            let response: HttpResponse = r.match(with: definition, ignoreHeaders: ignoreHeaders)
            
            return response
        }
        
        server.middleware.append(response)
        
        
        try server.start(port, priority: DispatchQoS.QoSClass.utility)
    }
    
    func stop() {
        server.stop()
    }
}
