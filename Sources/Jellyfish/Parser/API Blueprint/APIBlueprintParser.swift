//
//  APIBlueprintParser.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 9/3/2018.
//  Copyright © 2018年 Jellyfish. All rights reserved.
//

import Foundation

fileprivate extension APIElement {
    func title() -> String {
        if let title: String = self.contentArray?[0].meta?.title?.contentString {
            return title
        }else{
            return ""
        }
    }
    
    func host() -> String {
        if let attributes: [APIElement] = self.contentArray?[0].attributes?["meta"]?.contentArray {
            for elem in attributes {
                if let dict = elem.contentDictionary,
                    let key = dict["key"]?.contentString,
                    let value = dict["value"]?.contentString,
                    key == "HOST" {
                    return value
                }
            }
            return ""
        }else{
            return ""
        }
    }
    
    // MARK - API Resources
    
    func method() -> HTTPMethod {
        return .GET
    }
    
    func headers() -> [String: String]? {
        
        guard let headers: [APIElement] = self.attributes?["headers"]?.contentArray else {
            return nil
        }
        
        var result: [String: String] = [:]
        
        for elem in headers {
            if let dict = elem.contentDictionary,
                let key = dict["key"]?.contentString,
                let value = dict["value"]?.contentString {
                result[key] = value
            }
        }
        
        return result
    }
    
    func pathsVariable() -> [String: String] {
        guard let contents: [APIElement] = self.contentArray else {
            return [:]
        }
        
        var result: [String: String] = [:]
        
        for elem in contents {
            if let dict = elem.contentDictionary,
                let key = dict["key"]?.contentString,
                let value = dict["value"]?.contentString {
                result[key] = value
            }
        }
        
        return result
    }
    
    func queryParam() -> [String: String] {
        return [:]
    }
    
    func body() -> Data? {
        
        if let contents: [APIElement] = self.contentArray?.filter({ elem -> Bool in
            
            guard let classes: [APIElement] = elem.meta?.classes else {
                return false
            }
            
            if (classes.contains(where: { elem -> Bool in
                return elem.contentString == "messageBody"
            })) {
                return true
            }else{
                return false
            }
        }),
            let contentString: String = contents.first?.contentString {
            return contentString.data(using: .utf8)
        }
        
        return nil
    }
    
    func requests() -> [APIRequest] {
        guard let elements: [APIElement] = self.contentArray else {
            return []
        }
        
        return elements.filter({ elem -> Bool in
            return elem.element == "httpRequest"
        }).map({ elem -> APIRequest in
            return APIRequest(headers: elem.headers(),
                              body: elem.body(),
                              method: HTTPMethod(rawValue: elem.attributes?["method"]?.contentString ?? "GET") ?? .GET)
        })
    }
    
    func statusCode() -> Int? {
        if let statusCode: String = self.attributes?["statusCode"]?.contentString {
            return Int(statusCode)
        }else{
            return nil
        }
    }
    
    func responses() -> [APIResponse] {
        guard let elements: [APIElement] = self.contentArray else {
            return []
        }
        
        return elements.filter({ elem -> Bool in
            return elem.element == "httpResponse"
        }).map({ elem -> APIResponse in
            return APIResponse(headers: self.headers() ?? elem.headers(),
                               responseCode: elem.statusCode(),
                               body: elem.body())
        })
    }
    
    func httpTransactionExamples(_ pathsVariable: [String: String]? = nil) -> [APIExample] {
        guard let elements: [APIElement] = self.contentArray else {
            return []
        }
        
        return elements.filter({ elem -> Bool in
            return elem.element == "httpTransaction"
        }).map({ elem -> APIExample in
            return APIExample(pathParams: pathsVariable ?? [:],
                              queryParams: elem.queryParam(),
                              requests: elem.requests(),
                              responses: elem.responses())
        })
    }
    
    func examples(_ pathVariables: [String: String]? = nil) -> [APIExample] {
        guard let elements: [APIElement] = self.contentArray else {
            return []
        }
        
        var result: [APIExample] = []
        
        for elem in elements {
            if elem.element == "transition" {
                result.append(contentsOf: elem.httpTransactionExamples(pathVariables))
            }
        }
        
        return result
    }
    
    func resource() -> APIResource {
        if let hrefVariable: [String: String] = self.attributes?["hrefVariables"]?.pathsVariable() {
            return APIResource(path: self.attributes?["href"]?.contentString ?? "",
                               examples: self.examples(hrefVariable))
        }else{
            return APIResource(path: self.attributes?["href"]?.contentString ?? "",
                               examples: self.examples())
        }
        
        
        
    }
    
    func resources() -> [APIResource] {
        guard let elements: [APIElement] = self.contentArray?[0].contentArray else {
            return []
        }
        
        var result: [APIResource] = []
        
        for elem in elements {
            
            if elem.element == "category" && elem.attributes == nil,
                let contentArray = elem.contentArray {
                result.append(contentsOf: contentArray.filter({ subElem -> Bool in
                    return subElem.element == "resource"
                }).map({ resourceGroupElem -> APIResource in
                    return resourceGroupElem.resource()
                }))
            }else if elem.element == "resource" {
                result.append(elem.resource())
            }
        }
        
        return result
    }
}

enum APIBlueprintParserError: Error {
    case emptyData
}

public class APIBlueprintParser: APIParser {
    public init() {
        
    }
    
    public func parse(content: String, completion: @escaping APIParserHandler) {
        ObjectiveDrafter().parseDocument(inJS: content, completion: { result in
            completion(ParserResult.success(APIDefinition(title: result.title(),
                                                          host: result.host(),
                                                          resources: result.resources())))
        }) { err in
            completion(ParserResult.failure(err))
        }
    }
}
