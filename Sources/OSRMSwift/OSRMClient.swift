//
//  OSRMClient.swift
//  OSRMSwift
//
//  Created by Ringo Wathelet on 2025/08/24.
//
import Foundation


/*
 * represents an error during a connection
 */
public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

/*
 * a network connection to the OSRM API server
 */
public actor OSRMClient {
    
    public var sessionManager: URLSession
    public var acceptType = "application/json; charset=utf-8"
    public var contentType = "application/json; charset=utf-8"
    public var baseurl = "https://router.project-osrm.org/"
    
    public init(urlString: String = "https://router.project-osrm.org") {
        self.baseurl = urlString
        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30  // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    }
    
    /*
     * fetch data from the server.
     * The server response Data is returned.
     *
     * @request the OSRMRequest
     * @return Data
     */
    public func fetchData(request: OSRMRequest) async throws -> Data {
        
        guard !request.coordinates.isEmpty else { return Data() }
        
        // coordinates
        let coords = request.coordinates.map { "\($0.longitude),\($0.latitude)" }
            .joined(separator: ";")
        
        // base path
        guard var components = URLComponents(string: "\(baseurl)/\(request.service.rawValue)/\(request.version)/\(request.profile.rawValue)/\(coords)") else { return Data() }
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "steps", value: request.steps ? "true" : "false"),
            URLQueryItem(name: "geometries", value: request.geometries),
            URLQueryItem(name: "overview", value: request.overview),
            URLQueryItem(name: "annotations", value: request.annotations)
        ]
        
        // route only
        if request.service == .route {
            if let alternatives = request.alternatives {
                queryItems.append(URLQueryItem(name: "alternatives", value: alternatives ? "true" : "false"))
            }
            
            if let cs = request.continueStraight {
                queryItems.append(URLQueryItem(name: "continue_straight", value: cs ? "true" : "false"))
            }
        }
        
        // match only
        if request.service == .match {
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
        }
        
        // nearest only
        if request.service == .nearest {
            queryItems.removeAll()

            let radiuses = request.coordinates.map { $0.radius != nil ? "\($0.radius!)" : "" }.joined(separator: ";")
            if radiuses.contains(where: { !$0.isWhitespace }) {
                queryItems.append(URLQueryItem(name: "radiuses", value: radiuses))
            }

            if let number = request.number {
                queryItems.append(URLQueryItem(name: "number", value: "\(number)"))
            }
        }
        
        // optional per-coordinate arrays
        let bearings = request.coordinates.map {
            if let bearing = $0.bearing {
                "\(bearing.value),\(bearing.range)"
            } else {
                ""
            }
        }.joined(separator: ";")
        if bearings.contains(where: { !$0.isWhitespace }) {
            queryItems.append(URLQueryItem(name: "bearings", value: bearings))
        }

        components.queryItems = queryItems
        
        var apiRequest = URLRequest(url: components.url!)
        apiRequest.httpMethod = "GET"
        apiRequest.addValue(acceptType, forHTTPHeaderField: "Accept")
        apiRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
  //      print("---> components.url: \(components.url!) \n")
        
        do {
            let (data, response) = try await sessionManager.data(for: apiRequest)
            
   //         print("---> data: \(String(data: data, encoding: .utf8) as AnyObject)\n")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            if (httpResponse.statusCode == 400) {
                throw APIError.apiError(reason: "Error")
            }
            if (500..<600 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "Server error")
            }
            if (httpResponse.statusCode != 200) {
                throw APIError.networkError(from: URLError(.badServerResponse))
            }
            
            return data
        }
        catch let error as APIError {
            throw error
        }
        catch {
            throw APIError.unknown
        }
    }
    
    /*
     * fetch route service from the server.
     * The server response OSRMRouteResponse is returned.
     *
     * @request the OSRMRequest
     * @return OSRMRouteResponse?
     */
    @MainActor
    public func fetchRoute(request: OSRMRequest) async throws -> OSRMRouteResponse? {
        do {
            let data = try await fetchData(request: request)
            let response: OSRMRouteResponse = try JSONDecoder().decode(OSRMRouteResponse.self, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
    
    /*
     * fetch match service from the server.
     * The server OSRMMatchResponse is returned.
     *
     * @request the OSRMRequest
     * @return OSRMMatchResponse?
     */
    @MainActor
    public func fetchMatch(request: OSRMRequest) async throws -> OSRMMatchResponse? {
        do {
            let data = try await fetchData(request: request)
            let response: OSRMMatchResponse = try JSONDecoder().decode(OSRMMatchResponse.self, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
    
    /*
     * fetch trip service from the server.
     * The server OSRMTripResponse is returned.
     *
     * @request the OSRMRequest
     * @return OSRMTripResponse?
     */
    @MainActor
    public func fetchTrip(request: OSRMRequest) async throws -> OSRMTripResponse? {
        do {
            let data = try await fetchData(request: request)
            let response: OSRMTripResponse = try JSONDecoder().decode(OSRMTripResponse.self, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
    
    /*
     * fetch nearest service from the server.
     * The server OSRMNearestResponse is returned.
     *
     * @request the OSRMRequest
     * @return OSRMNearestResponse?
     */
    @MainActor
    public func fetchNearest(request: OSRMRequest) async throws -> OSRMNearestResponse? {
        do {
            let data = try await fetchData(request: request)
            let response: OSRMNearestResponse = try JSONDecoder().decode(OSRMNearestResponse.self, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
   
}
