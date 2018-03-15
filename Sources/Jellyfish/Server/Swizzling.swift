//
//  NSURLSessionConfiguration.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 14/3/2018.
//  Copyright © 2018年 Jellyfish. All rights reserved.
//

import Foundation

// Swizzling

let swizzleDefaultSessionConfiguration: Void = {
    let defaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default))
    let swizzledDefaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.mockDefaultSessionConfiguration))
    method_exchangeImplementations(defaultSessionConfiguration!, swizzledDefaultSessionConfiguration!)
    
    let ephemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.ephemeral))
    let jellyfishEphemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.mockEphemeralSessionConfiguration))
    method_exchangeImplementations(ephemeralSessionConfiguration!, jellyfishEphemeralSessionConfiguration!)
}()

extension URLSessionConfiguration {
    /// Swizzles NSURLSessionConfiguration's default and ephermeral sessions to add jellyfish
    @objc public class func jellyfishSwizzleDefaultSessionConfiguration() {
        _ = swizzleDefaultSessionConfiguration
    }
    
    @objc public dynamic class var mockDefaultSessionConfiguration: URLSessionConfiguration {
        let configuration = self.mockDefaultSessionConfiguration
        configuration.protocolClasses?.insert(JellyfishURLProtocol.self, at: 0)
        URLProtocol.registerClass(JellyfishURLProtocol.self)
        return configuration
    }
    
    @objc public dynamic class var mockEphemeralSessionConfiguration: URLSessionConfiguration {
        let configuration = self.mockEphemeralSessionConfiguration
        configuration.protocolClasses?.insert(JellyfishURLProtocol.self, at: 0)
        URLProtocol.registerClass(JellyfishURLProtocol.self)
        return configuration
    }
}

public extension URLSessionConfiguration {
    @objc public dynamic class var jellyfishConfiguration: URLSessionConfiguration {
        let configuration = self.default
        configuration.protocolClasses?.insert(JellyfishURLProtocol.self, at: 0)
        URLProtocol.registerClass(JellyfishURLProtocol.self)
        return configuration
    }
}
