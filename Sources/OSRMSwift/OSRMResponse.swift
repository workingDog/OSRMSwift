//
//  OSRMResponse.swift
//  OSRMSwift
//
//  Created by Ringo Wathelet on 2025/08/25.
//
import Foundation
import CoreLocation


// MARK: - OSRMMatchResponse
public struct OSRMMatchResponse: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let code: String
    public let matchings: [OSRMRoute]
    public let tracepoints: [OSRMPoint?]
    
    enum CodingKeys: String, CodingKey {
        case code, matchings, tracepoints
    }
    
    public init(code: String, matchings: [OSRMRoute], tracepoints: [OSRMPoint?]) {
        self.code = code
        self.matchings = matchings
        self.tracepoints = tracepoints
    }
}

// MARK: - OSRMRouteResponse
public struct OSRMRouteResponse: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let code: String
    public let routes: [OSRMRoute]
    public let waypoints: [OSRMPoint?]
    
    enum CodingKeys: String, CodingKey {
        case code, routes, waypoints
    }
    
    public init(code: String, routes: [OSRMRoute], waypoints: [OSRMPoint?]) {
        self.code = code
        self.routes = routes
        self.waypoints = waypoints
    }
}

// MARK: - OSRMTripResponse
public struct OSRMTripResponse: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let code: String
    public let trips: [OSRMRoute]
    public let waypoints: [OSRMPoint?]
    
    enum CodingKeys: String, CodingKey {
        case code, trips, waypoints
    }
    
    public init(code: String, trips: [OSRMRoute], waypoints: [OSRMPoint?]) {
        self.code = code
        self.trips = trips
        self.waypoints = waypoints
    }
}

// MARK: - OSRMNearestResponse
public struct OSRMNearestResponse: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let code: String
    public let waypoints: [OSRMPoint]
    
    enum CodingKeys: String, CodingKey {
        case code, waypoints
    }
    
    public init(code: String, waypoints: [OSRMPoint]) {
        self.code = code
        self.waypoints = waypoints
    }
    
    public var coordinates2D: [CLLocationCoordinate2D] {
        waypoints.compactMap { $0.coordinates2D }
    }
}

// MARK: - OSRMTableResponse
public struct OSRMTableResponse: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let code: String
    public let durations: [[Double?]]
    public let distance: Double?
    public let sources: [OSRMPoint]
    public let destinations: [OSRMPoint]
    public let fallbackSpeedCells: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case code, durations, distance, sources, destinations
        case fallbackSpeedCells = "fallback_speed_cells"
    }
    
public init(code: String, durations: [[Double?]], distance: Double?, sources: [OSRMPoint], destinations: [OSRMPoint], fallbackSpeedCells: [Int]? = nil) {
        self.code = code
        self.durations = durations
        self.distance = distance
        self.sources = sources
        self.destinations = destinations
        self.fallbackSpeedCells = fallbackSpeedCells
    }
    
    public var sourcesCoordinates2D: [CLLocationCoordinate2D] {
        sources.compactMap { $0.coordinates2D }
    }
    
    public var destinationsCoordinates2D: [CLLocationCoordinate2D] {
        destinations.compactMap { $0.coordinates2D }
    }
    
}

// MARK: - OSRMRoute
public struct OSRMRoute: Codable, Identifiable, Sendable {
    public let id = UUID()

    public let geometry: OSRMGeometry
    public let legs: [OSRMLeg]
    public let weightName: String
    public let weight, duration, distance: Double
    public let confidence: Double?

    enum CodingKeys: String, CodingKey {
        case confidence, legs, geometry, weight, duration, distance
        case weightName = "weight_name"
    }
    
    public init(confidence: Double, legs: [OSRMLeg], weightName: String, geometry: OSRMGeometry, weight: Double, duration: Double, distance: Double) {
        self.confidence = confidence
        self.legs = legs
        self.weightName = weightName
        self.geometry = geometry
        self.weight = weight
        self.duration = duration
        self.distance = distance
    }
}

// MARK: - OSRMGeometry
public struct OSRMGeometry: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let coordinates: [[Double]]
    public let type: String
    
    enum CodingKeys: String, CodingKey {
        case coordinates, type
    }
    
    public init(coordinates: [[Double]], type: String) {
        self.coordinates = coordinates
        self.type = type
    }

    public var coordinates2D: [CLLocationCoordinate2D] {
        coordinates.compactMap { coord in
            guard coord.count >= 2 else { return nil }
            return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        }
    }

}

// MARK: - OSRMLeg
public struct OSRMLeg: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let summary: String
    public let weight: Double
    public let duration: Double
    public let steps: [OSRMStep]
    
    enum CodingKeys: String, CodingKey {
        case summary, weight, duration, steps
    }
    
    public init(summary: String, weight: Double, duration: Double, steps: [OSRMStep]) {
        self.summary = summary
        self.weight = weight
        self.duration = duration
        self.steps = steps
    }
}

// MARK: - OSRMStep
public struct OSRMStep: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let intersections: [OSRMIntersection]?
    public let drivingSide: String
    public let geometry: OSRMGeometry
    public let maneuver: OSRMManeuver
    public let name, mode: String
    public let weight, duration, distance: Double
    
    enum CodingKeys: String, CodingKey {
        case intersections
        case drivingSide = "driving_side"
        case geometry, maneuver, name, mode, weight, duration, distance
    }
    
    public init(intersections: [OSRMIntersection]?, drivingSide: String, geometry: OSRMGeometry, maneuver: OSRMManeuver, name: String, mode: String, weight: Double, duration: Double, distance: Double) {
        self.intersections = intersections
        self.drivingSide = drivingSide
        self.geometry = geometry
        self.maneuver = maneuver
        self.name = name
        self.mode = mode
        self.weight = weight
        self.duration = duration
        self.distance = distance
    }
}

// MARK: - OSRMManeuver
public struct OSRMManeuver: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let location: [Double]
    public let bearingBefore: Double?
    public let bearingAfter: Double?
    public let type: String
    public let modifier: String?

    enum CodingKeys: String, CodingKey {
        case location, type, modifier
        case bearingBefore = "bearing_before"
        case bearingAfter = "bearing_after"
    }
    
    public init(location: [Double], bearingBefore: Double?, bearingAfter: Double?, type: String, modifier: String?) {
        self.location = location
        self.bearingBefore = bearingBefore
        self.bearingAfter = bearingAfter
        self.type = type
        self.modifier = modifier
    }
    
    public var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
    
}

// MARK: - OSRMLane
public struct OSRMLane: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let valid: Bool
    public let indications: [String]
    
    enum CodingKeys: String, CodingKey {
        case valid, indications
    }
    
    public init(valid: Bool, indications: [String]) {
        self.valid = valid
        self.indications = indications
    }
}

// MARK: - OSRMIntersection
public struct OSRMIntersection: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let location: [Double]
    public let bearings: [Int]
    public let entry: [Bool]

    // match
    public let out: Int?
    public let intersectionIn: Int?
    public let lanes: [OSRMLane]?
    
    enum CodingKeys: String, CodingKey {
        case location, bearings, entry, out, lanes
        case intersectionIn = "in"
    }
    
    public init(out: Int?, entry: [Bool], bearings: [Int], location: [Double], intersectionIn: Int?, lanes: [OSRMLane]?) {
        self.out = out
        self.entry = entry
        self.bearings = bearings
        self.location = location
        self.intersectionIn = intersectionIn
        self.lanes = lanes
    }
    
    public var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
}

// MARK: - OSRMPoint
public struct OSRMPoint: Codable, Identifiable, Sendable {
    public let id = UUID()
    
    public let name: String
    public let location: [Double]
    
    // macth
    public let alternativesCount, waypointIndex: Int?
    public let distance: Double?
    public let hint: String?
    public let matchingsIndex: Int?
    
    // trip
    public let tripIndex: Int?

    enum CodingKeys: String, CodingKey {
        case distance, name, location, hint
        case alternativesCount = "alternatives_count"
        case waypointIndex = "waypoint_index"
        case matchingsIndex = "matchings_index"
        case tripIndex = "trips_index"
    }
    
    public init(name: String, location: [Double], alternativesCount: Int? = nil, waypointIndex: Int? = nil, distance: Double? = nil,  hint: String? = nil, matchingsIndex: Int? = nil, tripIndex: Int? = nil) {
        self.alternativesCount = alternativesCount
        self.waypointIndex = waypointIndex
        self.distance = distance
        self.name = name
        self.location = location
        self.hint = hint
        self.matchingsIndex = matchingsIndex
        self.tripIndex = tripIndex
    }
    
    public var coordinates2D: CLLocationCoordinate2D? {
        guard location.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
    }
}
