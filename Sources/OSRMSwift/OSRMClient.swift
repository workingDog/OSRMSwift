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
 * Provides for network connections to the OSRM API server
 *
 * info at: https://project-osrm.org/docs/v5.5.1/api/#general-options
 *
 */
public actor OSRMClient {
    
    let queryMaker = OSRMQueryMaker()
    
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

        guard !request.coordinates.isEmpty else {
            throw APIError.apiError(reason: "No coordinates provided")
        }
        
        // coordinates
        let coords = request.coordinates.map { "\($0.longitude),\($0.latitude)" }
            .joined(separator: ";")
        
        let stringUrl = "\(baseurl)/\(request.service.rawValue)/\(request.version)/\(request.profile.rawValue)/\(coords)"
        
        // base path
        guard var components = URLComponents(string: stringUrl) else {
             throw APIError.apiError(reason: "Bad url: \(stringUrl)")
         }
        
        components.queryItems = await queryMaker.getQueryItems(for: request)
        
        var apiRequest = URLRequest(url: components.url!)
        apiRequest.httpMethod = "GET"
        apiRequest.addValue(acceptType, forHTTPHeaderField: "Accept")
        apiRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
  //      print("---> components.url: \(components.url!) \n")
        
        do {
            let (data, response) = try await sessionManager.data(for: apiRequest)
            
  //          print("---> data: \(String(data: data, encoding: .utf8) as AnyObject)\n")
            
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
    
    /*
     * fetch table service from the server.
     * The server OSRMTableResponse is returned.
     *
     * @request the OSRMRequest
     * @return OSRMTableResponse?
     */
    @MainActor
    public func fetchTable(request: OSRMRequest) async throws -> OSRMTableResponse? {
        do {
            let data = try await fetchData(request: request)
            let response: OSRMTableResponse = try JSONDecoder().decode(OSRMTableResponse.self, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
    
}
