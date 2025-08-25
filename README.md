# OSRM API Swift client library

[OSRM](https://project-osrm.org/docs/v5.5.1/api/#general-options) (Open Source Routing Machine) is a routing engine made available through an HTTP API.

It delivers map data from **OpenStreetMap** that can:

    •    Find the best route (shortest/fastest path) between points
    •    Get travel times and distances between locations
    •    Provide turn-by-turn directions for navigation
    •    Snap GPS traces to roads (map matching)
    •    Build distance/time matrices (many-to-many travel times)
    •    Optimize trips (reorder waypoints for shortest round trip)


**OSRMSwift** is a small Swift library to connect to the [OSRM API](https://router.project-osrm.org) server.
        
**OSRMSwift** is currently for JSON **route**, **trip**, **nearest** and **match** services only.
          
                                                                    
### Usage

**OSRMSwift** is made easy to use with **SwiftUI**.
It can be used with the following OS:

- iOS 17.0+
- iPadOS 17.0+
- macOS 14.0+
- Mac Catalyst 17.0+

#### Examples

[OSRM](https://project-osrm.org/docs/v5.5.1/api/#general-options) data can be accessed with the use of the **OSRMClient**.

```swift
import SwiftUI
import MapKit
import OSRMSwift

struct ContentView: View {
    let client = OSRMClient()

    @State private var response: OSRMRouteResponse?
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.517037, longitude: 13.388860),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    var body: some View {
        Map(position: $cameraPosition) {
            if let response {
                ForEach(response.routes) { route in
                    MapPolyline(coordinates: route.geometry.coordinates2D)
                        .stroke(.blue, lineWidth: 8)
                    if let start = route.geometry.coordinates2D.first,
                       let end = route.geometry.coordinates2D.last{
                        Marker("Start", coordinate: start)
                        Marker("End", coordinate: end)
                    }
                }
            }
        }
        .task {
            let request = OSRMRequest(
                profile: .driving,
                coordinates: [
                    OSRMCoordinate(lat: 52.517037, lon: 13.388860,
                                   bearing: OSRMBearing(value: 90, range: 20),
                                   radius: 50),
                    OSRMCoordinate(lat: 52.529407, lon: 13.397634)
                ],
                service: .route,
                version: "v1",
                steps: true,
                geometries: "geojson",
                overview: "full",
                annotations: "false",
                alternatives: true,
                continueStraight: true
            )
            do {
                response = try await self.client.fetchRoute(request: request)
            } catch {
                print(error)
            }
        }
    }
}
```

### Request

The structure of various requests are described at [OSRM](https://project-osrm.org/docs/v5.5.1/api/#general-options) 

### Installation

Include the files in the **./Sources/OSRMSwift** folder into your project or preferably use **Swift Package Manager**.

#### Swift Package Manager (SPM)

Create a Package.swift file for your project and add a dependency to:

```swift
dependencies: [
  .package(url: "https://github.com/workingDog/OSRMSwift.git", branch: "main")
]
```

#### Using Xcode

    Select your project > Swift Packages > Add Package Dependency...
    https://github.com/workingDog/OSRMSwift.git

Then in your code:

```swift
import OSRMSwift
```
    
### References

-    [OSRM](https://project-osrm.org/docs/v5.5.1/api/#general-options)

### License

MIT


