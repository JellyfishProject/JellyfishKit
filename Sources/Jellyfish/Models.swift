//
//  Models.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, UPDATE
    
    static func from(string: String) -> HTTPMethod {
        return HTTPMethod(rawValue: string) ?? .GET
    }
}

public struct APIRequest {
    let headers: [String: String]?
    let body: Data?
    let method: HTTPMethod
}

public struct APIResponse {
    let headers: [String: String]?
    let responseCode: Int?
    let body: Data?
}

public struct APIExample {
    let pathParams: [String: String]
    let queryParams: [String: String]
    let requests: [APIRequest]
    let responses: [APIResponse]
}

public struct APIResource {
    let path: String
    let examples: [APIExample]
}

public struct APIDefinition {
    let title: String
    let host: String
    
    let resources: [APIResource]
}
