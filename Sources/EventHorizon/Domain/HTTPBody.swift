//
//  HTTPBody.swift
//  EventHorizon
//
//  Created by Egzon Pllana on 22.3.25.
//

import Foundation

/// Represents different types of HTTP request bodies.
public enum HTTPBody {
    /// A raw data HTTP body.
    case data(Data)

    /// A multipart form-data HTTP body.
    case multipartFormData(MultipartFormData)

    /// Returns the raw `Data` representation of the HTTP body, if applicable.
    public var asData: Data? {
        switch self {
            case .data(let data):
                return data
            case .multipartFormData(let formData):
                return formData.asData
        }
    }

    /// Returns the content type header value corresponding to the HTTP body type.
    public var contentType: String {
        switch self {
            case .data:
                return "application/octet-stream"
            case .multipartFormData(let formData):
                return "multipart/form-data; boundary=\(formData.boundary)"
        }
    }
}
