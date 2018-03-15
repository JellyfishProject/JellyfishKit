//
//  HTTPStub.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 13/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

var registered: Bool = false

@objc public class JellyfishURLProtocol: URLProtocol {
    
    static var stub: [String: String] = [:]
    
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    
    static func register() {
        if !registered {
            URLProtocol.registerClass(JellyfishURLProtocol.self)
        }
    }
    
    static func addStub(from: String, to: String) {
        register()
        stub[from] = to
    }
    
    static func removeAllStub() {
        JellyfishURLProtocol.stub = [:]
    }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        let newRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
        
        if let url = newRequest.url?.absoluteString {
            var result: String = url
            
            for key: String in JellyfishURLProtocol.stub.keys {
                if let value = JellyfishURLProtocol.stub[key] {
                    if let loc = url.range(of: key) {
                        // Only replace url on startIndex
                        if loc.lowerBound == url.startIndex {
                            result = url.replacingOccurrences(of: key, with: value)
                        }
                    }
                }
            }
            
            newRequest.url = URL(string: result)
        }
        
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
    }
    
    override public func stopLoading() {
        sessionTask?.cancel()
    }
}

extension JellyfishURLProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
    }
}


