//
//  NetworkError.swift
//  NetworkError
//
//  Created by Lucas Mathielo on 27/06/24.
//

import Foundation

public enum NetworkError: Error {
    case invalidUrl
    case downloadFailed
    case timeout
    case unknown
    
    public var description: String {
        "The network could not be fetched. Reason: \(self)"
    }
}
