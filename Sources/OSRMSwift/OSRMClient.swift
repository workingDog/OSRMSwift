//
//  OSRMProvider.swift
//  OSRMSwif
//
//  Created by Ringo Wathelet on 2025/08/24.
//
import Foundation


/**
 * provide access to the OSRM API using simple stand alone functions
 */
@MainActor
public struct OSRMProvider {
    
    public let client: OSRMClient
    
    /// default endpoint
    public init(urlString: String = "https://router.project-osrm.org/") {
        self.client = OSRMClient(urlString: urlString)
    }
    
    
    
}
