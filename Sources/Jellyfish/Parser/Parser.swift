//
//  Parser.swift
//  Jellyfish-iOS
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

public enum ParserResult<T> {
    case success(T)
    case failure(Error)
}

public typealias APIParserHandler = ((ParserResult<APIDefinition>) -> Void)

public protocol APIParser {
    func parse(content: String, completion: @escaping APIParserHandler)
}
