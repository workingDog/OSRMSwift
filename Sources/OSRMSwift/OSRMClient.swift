//
//  OSRMClient.swift
//  OSRMSwift
//
//  Created by Ringo Wathelet on 2025/08/24.
//
import Foundation


/*
 * error during a connection
 */
public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        return switch self {
            case .unknown:  "Unknown error"
            case .apiError(let reason), .parserError(let reason): reason
            case .networkError(let from): from.localizedDescription
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

    public let sessionManager: URLSession
    public let acceptType: String
    public let contentType: String
    public let userAgent: String
    
    private let baseURL: URL

    public init(baseURL: URL = URL(string: "https://router.project-osrm.org")!) {
        self.baseURL = baseURL

        self.acceptType = "application/json; charset=utf-8"
        self.contentType = "application/json; charset=utf-8"
        self.userAgent = "OSRMSwift"

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
     * @components URLComponents
     * @return Data
     */
    private func fetchData(components: URLComponents) async throws -> Data {
        
        guard let _ = components.url else {
            throw APIError.apiError(reason: "Unable to create URL components")
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(acceptType, forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await sessionManager.data(for: request)
            
            //   print("---> data: \(String(data: data, encoding: .utf8) as AnyObject)")
            
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
     * returns a URLComponents given the path
     */
    private func makeComponents(path: String? = nil) -> URLComponents {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        if let path {
            components.path = path
        }
        return components
    }
    
    public func fetchRequestData(request: OSRMRequest) async throws -> Data {

        guard !request.coordinates.isEmpty else {
            throw APIError.apiError(reason: "No coordinates provided")
        }
        
        // coordinates
        let coords = request.coordinates.map { "\($0.longitude),\($0.latitude)" }
            .joined(separator: ";")
        
        let pathString = "/\(request.service.rawValue)/\(request.version)/\(request.profile.rawValue)/\(coords)"
        
        var components = makeComponents(path: pathString)

        components.queryItems = queryMaker.getQueryItems(for: request)
        
        return try await fetchData(components: components)
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
            let data = try await fetchRequestData(request: request)
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
            let data = try await fetchRequestData(request: request)
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
            let data = try await fetchRequestData(request: request)
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
            let data = try await fetchRequestData(request: request)
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
            let data = try await fetchRequestData(request: request)
            let response: OSRMTableResponse = try JSONDecoder().decode(OSRMTableResponse.self, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
    
}
