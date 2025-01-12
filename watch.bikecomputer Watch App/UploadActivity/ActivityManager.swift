//
//  ActivityManager.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 11/01/2025.
//


import CoreLocation

struct ActivityManager {
  var locations: [CLLocation] = []
  var accessToken: String = "9c2a7b382962d0ca71f61c75be1f7a641d2f0c34" //"YOUR_ACCESS_TOKEN"
  
  func stopActivity() async {
    guard let gpxFileURL = GPXGenerator.generateGPX(from: locations, activityName: "My Activity") else {
      print("Failed to generate GPX file.")
      return
    }
    
    do {
      let response = try await StravaAPI.uploadGPX(fileURL: gpxFileURL, accessToken: accessToken, activityName: "My Activity")
      print("Uploaded to Strava successfully: \(response)")
    } catch {
      print("Error uploading to Strava: \(error)")
    }
  }
}

//error 401

//Uploaded to Strava successfully: <NSHTTPURLResponse: 0x6000002c38a0> { URL: https://www.strava.com/api/v3/uploads } { Status Code: 401, Headers {
//  "Cache-Control" =     (
//    "no-cache"
//  );
//  "Content-Type" =     (
//    "application/json; charset=utf-8"
//  );
//  Date =     (
//    "Sat, 11 Jan 2025 12:20:51 GMT"
//  );
//  Server =     (
//    "istio-envoy"
//  );
//  Status =     (
//    "401 Unauthorized"
//  );
//  Vary =     (
//    "Accept, Origin"
//  );
//  Via =     (
//    "1.1 062c88d8648a5203fe3532a01a7b5f34.cloudfront.net (CloudFront)"
//  );
//  "referrer-policy" =     (
//    "strict-origin-when-cross-origin"
//  );
//  "x-amz-cf-id" =     (
//    "OxwdRwyWyfbx36THFtwN10joHPwIVUER9B3sCUoEGaW0GM-18EIh5w=="
//  );
//  "x-amz-cf-pop" =     (
//    "TXL50-P6"
//  );
//  "x-cache" =     (
//    "Error from cloudfront"
//  );
//  "x-content-type-options" =     (
//    nosniff
//  );
//  "x-download-options" =     (
//    noopen
//  );
//  "x-envoy-upstream-service-time" =     (
//    129
//  );
//  "x-frame-options" =     (
//    DENY
//  );
//  "x-permitted-cross-domain-policies" =     (
//    none
//  );
//  "x-ratelimit-limit" =     (
//    "200,2000"
//  );
//  "x-ratelimit-usage" =     (
//    "1,1"
//  );
//  "x-readratelimit-limit" =     (
//    "100,1000"
//  );
//  "x-readratelimit-usage" =     (
//    ","
//  );
//  "x-request-id" =     (
//    "2ad0457b-9cbe-4227-b739-22a4bbde6ad9"
//  );
//  "x-xss-protection" =     (
//    "1; mode=block"
//  );
//} }
