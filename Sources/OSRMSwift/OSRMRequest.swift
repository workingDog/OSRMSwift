//
//  OSRMRequest.swift
//  OSRMSwift
//
//  Created by Ringo Wathelet on 2025/08/25.
//
import Foundation


// MARK: - OSRMRequest
public struct OSRMRequest: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    // general options
    public let profile: OSRMProfile
    public let coordinates: [OSRMCoordinate]
    public var service: OSRMService
    public var version: String
    public var steps: Bool
    public var geometries: String     // "polyline", "polyline6", "geojson"
    public var overview: String       // "simplified", "full", "false"
    public var annotations: String?   // true or false, duration, distance
                                      // or "duration,distance"
    
    // route
    public var alternatives: Bool?
    public var continueStraight: Bool? // true, false, or nil = default
    
    // match
    public var timestamps: [Int]?     // seconds since UNIX epoch
    public var radiuses: [Double]?    // Standard deviation of GPS precision
    
    public var tidy: Bool?           // remove unused waypoints
    public var snapping: String?     // "default" | "any"
    public var exclude: [String]?    // ["toll", "motorway", "ferry", …]
    
    // nearest
    public var number: Int?
    
    // table
    public var sources: [Int]?
    public var destinations: [Int]?
    public var fallbackSpeed: Double?
    public var fallbackCoordinate: String?  // input (default), or snapped
    public var scaleFactor: Double?

    enum CodingKeys: String, CodingKey {
        case profile, coordinates, version, service, timestamps, steps, geometries, overview, annotations, radiuses, tidy, snapping, exclude, alternatives, continueStraight
        case number
        case sources, destinations
        case fallbackSpeed = "fallback_speed"
        case fallbackCoordinate = "fallback_coordinate"
        case scaleFactor = "scale_factor"
    }
    
    public init(profile: OSRMProfile, coordinates: [OSRMCoordinate], service: OSRMService, version: String = "v1", steps: Bool = false, geometries: String = "polyline", overview: String = "simplified", annotations: String? = nil, alternatives: Bool? = nil, continueStraight: Bool? = nil, timestamps: [Int]? = nil, radiuses: [Double]? = nil, tidy: Bool? = nil, snapping: String? = nil, exclude: [String]? = nil, number: Int? = nil, sources: [Int]? = nil, destinations: [Int]? = nil, fallbackSpeed: Double? = nil, fallbackCoordinate: String? = nil, scaleFactor: Double? = nil) {
        self.profile = profile
        self.coordinates = coordinates
        self.service = service
        self.version = version
        self.steps = steps
        self.geometries = geometries
        self.overview = overview
        self.annotations = annotations
        self.alternatives = alternatives
        self.continueStraight = continueStraight
        self.timestamps = timestamps
        self.radiuses = radiuses
        self.tidy = tidy
        self.snapping = snapping
        self.exclude = exclude
        self.number = number
        self.sources = sources
        self.destinations = destinations
        self.fallbackSpeed = fallbackSpeed
        self.fallbackCoordinate = fallbackCoordinate
        self.scaleFactor = scaleFactor
    }

}

// MARK: - Supported travel profiles
public enum OSRMProfile: String, Codable, Sendable {
    case driving
    case walking
    case cycling
}

// MARK: - Coordinate request options
public struct OSRMCoordinate: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let latitude: Double
    public let longitude: Double
    
    public var bearing: OSRMBearing?   // max 180° deviation
    public var radius: Double?         // meters, or "unlimited"
    public var hint: String?           // from previous response
    
    public init(lat: Double, lon: Double, bearing: OSRMBearing? = nil, radius: Double? = nil, hint: String? = nil) {
        self.latitude = lat
        self.longitude = lon
        self.bearing = bearing
        self.radius = radius
        self.hint = hint
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, bearing, radius, hint
    }
}

// MARK: - Bearing
public struct OSRMBearing: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let value: Int   // 0–360°
    public let range: Int   // 0–180°

    public init(value: Int, range: Int) {
        self.value = value
        self.range = range
    }
    
    enum CodingKeys: String, CodingKey {
        case value, range
    }
}

// MARK: - Service
public enum OSRMService: String, Codable, Sendable {
    case route, table, nearest, match, trip
}
