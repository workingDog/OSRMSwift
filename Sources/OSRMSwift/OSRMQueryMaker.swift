//
//  OSRMQueryMaker.swift
//  OSRMSwift
//
//  Created by Ringo Wathelet on 2025/08/26.
//
import Foundation

/*
 * create an array of URLQueryItem based on the particular service
 * of the given OSRMRequest
 */
public struct OSRMQueryMaker {

    public func getQueryItems(for request: OSRMRequest) -> [URLQueryItem] {
        
        var queryItems: [URLQueryItem] = switch request.service {
            case .route:    getRouteQuery(for: request)
            case .match:    getMatchQuery(for: request)
            case .trip:     getTripQuery(for: request)
            case .nearest:  getNearestQuery(for: request)
            case .table:    getTableQuery(for: request)
            case .tile:     getGeneralOptions(for: request)  // <-- todo
        }

        // for all services except table
        if request.service != .table,
           request.coordinates.contains(where: { $0.bearing != nil }) {
            
            let bearings = request.coordinates
                .map { $0.bearing.map { "\($0.value),\($0.range)" } ?? "" }
                .joined(separator: ";")

            queryItems.append(URLQueryItem(name: "bearings", value: bearings))
        }
        
        return queryItems
    }

    public func getGeneralOptions(for request: OSRMRequest) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "steps", value: request.steps ? "true" : "false"),
            URLQueryItem(name: "geometries", value: request.geometries),
            URLQueryItem(name: "overview", value: request.overview),
            URLQueryItem(name: "annotations", value: request.annotations)
        ]
    }
    
    public func getRouteQuery(for request: OSRMRequest) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = getGeneralOptions(for: request)
        
        if let alternatives = request.alternatives {
            queryItems.append(URLQueryItem(name: "alternatives", value: alternatives ? "true" : "false"))
        }
        if let cs = request.continueStraight {
            queryItems.append(URLQueryItem(name: "continue_straight", value: cs ? "true" : "false"))
        }
        
        return queryItems
    }
    
    public func getTripQuery(for request: OSRMRequest) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = getGeneralOptions(for: request)
        
        return queryItems
    }
    
    public func getMatchQuery(for request: OSRMRequest) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = getGeneralOptions(for: request)
        
        if let tst = request.timestamps {
            let timestamps = tst.map { "\($0)" }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "timestamps", value: timestamps))
        }
        
        if let tidy = request.tidy {
            queryItems.append(URLQueryItem(name: "tidy", value: tidy ? "true" : "false"))
        }
        
        if let snapping = request.snapping{
            queryItems.append(URLQueryItem(name: "snapping", value: snapping))
        }
        
        let radiuses = request.coordinates.map { $0.radius != nil ? "\($0.radius!)" : "" }.joined(separator: ";")
        if radiuses.contains(where: { !$0.isWhitespace }) {
            queryItems.append(URLQueryItem(name: "radiuses", value: radiuses))
        }
        
        return queryItems
    }
    
    public func getNearestQuery(for request: OSRMRequest) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        let radiuses = request.coordinates.map { $0.radius != nil ? "\($0.radius!)" : "" }.joined(separator: ";")
        if radiuses.contains(where: { !$0.isWhitespace }) {
            queryItems.append(URLQueryItem(name: "radiuses", value: radiuses))
        }
        if let number = request.number {
            queryItems.append(URLQueryItem(name: "number", value: "\(number)"))
        }
        
        return queryItems
    }
    
    public func getTableQuery(for request: OSRMRequest) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        if let src = request.sources {
            let sources = src.map { "\($0)" }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "sources", value: sources))
        }
        
        if let dest = request.destinations {
            let destinations = dest.map { "\($0)" }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "destinations", value: destinations))
        }
        
        if let number = request.fallbackSpeed {
            queryItems.append(URLQueryItem(name: "fallback_speed", value: "\(number)"))
        }
        
        if let fcoord = request.fallbackCoordinate {
            queryItems.append(URLQueryItem(name: "fallback_coordinate", value: fcoord))
        }
        
        if let number = request.scaleFactor {
            queryItems.append(URLQueryItem(name: "scale_factor", value: "\(number)"))
        }
        
        return queryItems
    }

}

