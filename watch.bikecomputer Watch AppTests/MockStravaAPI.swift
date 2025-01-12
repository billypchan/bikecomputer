//
//  MockStravaAPI.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 11/01/2025.
//


import XCTest
import CoreLocation

@testable import watch_bikecomputer_Watch_App

class MockStravaAPI {
    static func uploadGPX(fileURL: URL, accessToken: String, activityName: String) async throws -> URLResponse {
        // Mock a successful upload response
        return HTTPURLResponse(
            url: StravaAPI.uploadURL,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
