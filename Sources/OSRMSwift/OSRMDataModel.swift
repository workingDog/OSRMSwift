//
//  OSRMDataModel.swift
//  OSRMSwift
//
//  Created by Ringo Wathelet on 2025/08/26.
//
import Foundation
import SwiftUI

/*
 * Get the OSRM API server response,
 * based on the particular service of the given OSRMRequest.
 * Update the corresponding observable response for use in SwiftUI.
 *
 */
@Observable
@MainActor
public final class OSRMDataModel {
    
    let client: OSRMClient
    
    public var routeResponse: OSRMRouteResponse?
    public var matchResponse: OSRMMatchResponse?
    public var tripResponse: OSRMTripResponse?
    public var nearestResponse: OSRMNearestResponse?
    public var tableResponse: OSRMTableResponse?
    
    public init(urlString: String = "https://router.project-osrm.org") {
        self.client = OSRMClient(urlString: urlString)
    }
    
    /// the main function to retrieve and update the appropriate response
    public func getOSRMResponse(for request: OSRMRequest) async {
        switch request.service {
            case .route:   await getRouteResponse(for: request)
            case .match:   await getMatchResponse(for: request)
            case .trip:    await getTripResponse(for: request)
            case .nearest: await getNearestResponse(for: request)
            case .table:   await getTableResponse(for: request)
        }
    }
    
    public func getRouteResponse(for request: OSRMRequest) async {
        do {
            routeResponse = try await client.fetchRoute(request: request)
        } catch {
            print(error)
        }
    }
    
    public func getMatchResponse(for request: OSRMRequest) async {
        do {
            matchResponse = try await client.fetchMatch(request: request)
        } catch {
            print(error)
        }
    }
    
    public func getTripResponse(for request: OSRMRequest) async {
        do {
            tripResponse = try await client.fetchTrip(request: request)
        } catch {
            print(error)
        }
    }
    
    public func getNearestResponse(for request: OSRMRequest) async {
        do {
            nearestResponse = try await client.fetchNearest(request: request)
        } catch {
            print(error)
        }
    }
    
    public func getTableResponse(for request: OSRMRequest) async {
        do {
            tableResponse = try await client.fetchTable(request: request)
        } catch {
            print(error)
        }
    }
    
}

